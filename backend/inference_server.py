import io
import os
import numpy as np
import librosa
import torch
import torch.nn as nn
import joblib
from fastapi import FastAPI, UploadFile, File, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from panns_inference import AudioTagging

SR = 32000
DURATION = 3
TARGET_LEN = SR * DURATION
DEVICE = torch.device('cuda' if torch.cuda.is_available() else 'cpu')

MODEL_WEIGHTS = "best_dual_head_panns.pt"
SCALER_PATH = "scaler_panns_dual.joblib"
ENCODER_PATH = "encoder_panns_dual.joblib"

# Defines the neural network architecture for car fault classification
class DualHeadResidualClassifier(nn.Module):
    # Initializes neural network layers and skip connections
    def __init__(self, in_features=2116, num_classes=13):
        super().__init__()
        self.fc1 = nn.Linear(in_features, 1024)
        self.bn1 = nn.BatchNorm1d(1024)
        self.drop1 = nn.Dropout(0.4)

        self.fc2 = nn.Linear(1024, 512)
        self.bn2 = nn.BatchNorm1d(512)
        self.drop2 = nn.Dropout(0.3)

        self.skip_proj = nn.Linear(in_features, 512)
        self.out = nn.Linear(512, num_classes)

    # Passes input features through layers to calculate class scores
    def forward(self, x):
        residual = self.skip_proj(x)
        h = torch.relu(self.bn1(self.fc1(x)))
        h = self.drop1(h)
        h = self.bn2(self.fc2(h))
        h = torch.relu(h + residual)
        h = self.drop2(h)
        return self.out(h)

# Extracts audio frequency and harmonic features from sound waveform
def extract_harmonic_spectral_deltas(y, sr):
    feats = []
    mfccs = librosa.feature.mfcc(y=y, sr=sr, n_mfcc=16)
    feats.extend(np.mean(mfccs, axis=1))
    feats.extend(np.std(mfccs, axis=1))

    delta1 = librosa.feature.delta(mfccs)
    feats.extend(np.mean(delta1, axis=1))

    flatness = librosa.feature.spectral_flatness(y=y)
    feats.extend([np.mean(flatness), np.std(flatness)])

    contrast = librosa.feature.spectral_contrast(y=y, sr=sr)
    feats.extend(np.mean(contrast, axis=1))
    feats.extend(np.std(contrast, axis=1))

    rolloff = librosa.feature.spectral_rolloff(y=y, sr=sr, roll_percent=0.15)
    feats.extend([np.mean(rolloff), np.std(rolloff)])

    zcr = librosa.feature.zero_crossing_rate(y=y)
    feats.extend([np.mean(zcr), np.std(zcr)])

    return np.array(feats, dtype=np.float32)

app = FastAPI(title="Car Fault Sound Classifier API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

_state = {}

# Loads the AI model weights, scaler, and class encoder when the server starts
@app.on_event("startup")
def load_artifacts():
    for path in (MODEL_WEIGHTS, SCALER_PATH, ENCODER_PATH):
        if not os.path.exists(path):
            raise RuntimeError(
                f"Missing required artifact: '{path}'. "
                f"Copy it into the server's working directory before starting."
            )

    print("[Startup] Loading PANNs Cnn14...")
    _state["panns"] = AudioTagging(checkpoint_path=None, device=str(DEVICE))

    print("[Startup] Loading scaler & encoder...")
    _state["scaler"] = joblib.load(SCALER_PATH)
    _state["encoder"] = joblib.load(ENCODER_PATH)
    class_names = list(_state["encoder"].classes_)
    _state["class_names"] = class_names

    print("[Startup] Loading classifier weights...")
    fused_dim = _state["scaler"].mean_.shape[0] + 2048
    model = DualHeadResidualClassifier(in_features=fused_dim, num_classes=len(class_names)).to(DEVICE)
    model.load_state_dict(torch.load(MODEL_WEIGHTS, map_location=DEVICE))
    model.eval()
    _state["model"] = model

    print(f"[Startup] Ready. Classes: {class_names}")

# Calculates prediction probabilities and checks vehicle sound relevance for a 3-second window
def _probs_for_window(window: np.ndarray, temperature: float) -> tuple[np.ndarray, bool]:
    with torch.no_grad():
        clipwise_output, cnn_emb = _state["panns"].inference(window[None, :])

    VEHICLE_MECHANICAL_CLASSES = {
        300, 306, 307, 317, 327, 343, 344, 348, 349, 350, 351, 361, 476,
        404, 405, 409, 412, 486, 491, 492
    }
    SPEECH_MUSIC_CLASSES = {0, 1, 2, 3, 4, 108, 137}
    
    max_vm_p = float(max(clipwise_output[0][idx] for idx in VEHICLE_MECHANICAL_CLASSES))
    max_speech_music_p = float(max(clipwise_output[0][idx] for idx in SPEECH_MUSIC_CLASSES))
    silence_p = float(clipwise_output[0][500])
    max_amp = float(np.max(np.abs(window))) if len(window) else 0.0

    harm_emb = extract_harmonic_spectral_deltas(window, SR)
    harm_scaled = _state["scaler"].transform(harm_emb[None, :])
    fused = np.hstack((cnn_emb, harm_scaled)).astype(np.float32)

    with torch.no_grad():
        inputs = torch.tensor(fused, dtype=torch.float32).to(DEVICE)
        logits = _state["model"](inputs)
        probs = torch.softmax(logits / temperature, dim=1).cpu().numpy()[0]

    top_prob = float(np.max(probs))

    is_relevant = True
    if silence_p > 0.40 or max_amp < 0.01:
        is_relevant = False
    elif max_speech_music_p > 0.35 and max_vm_p < 0.10:
        is_relevant = False
    elif max_vm_p < 0.04 and top_prob < 0.30:
        is_relevant = False

    return probs, is_relevant

# Splits full audio into overlapping windows and averages predictions for final diagnosis
def predict_from_waveform(audio: np.ndarray, temperature: float = 1.2) -> dict:
    class_names = _state["class_names"]

    if len(audio) <= TARGET_LEN:
        windows = [np.pad(audio, (0, TARGET_LEN - len(audio)))]
    else:
        hop = TARGET_LEN // 2
        windows = [
            audio[start: start + TARGET_LEN]
            for start in range(0, len(audio) - TARGET_LEN + 1, hop)
        ]
        if not windows:
            windows = [audio[:TARGET_LEN]]

    results = [_probs_for_window(w, temperature) for w in windows]
    all_probs = [r[0] for r in results]
    relevance_flags = [r[1] for r in results]

    avg_probs = np.mean(all_probs, axis=0)
    pred_idx = int(np.argmax(avg_probs))

    relevance_ratio = sum(relevance_flags) / len(relevance_flags)
    is_overall_relevant = relevance_ratio >= 0.5

    predicted_class = class_names[pred_idx]
    confidence = float(avg_probs[pred_idx])

    if not is_overall_relevant or confidence < 0.20:
        predicted_class = "inconclusive"

    return {
        "predicted_class": predicted_class,
        "confidence": confidence,
        "all_probabilities": {
            class_names[i]: float(avg_probs[i]) for i in range(len(class_names))
        },
        "windows_used": len(windows),
        "relevance_ratio": relevance_ratio,
    }

# Checks server health status and returns available class list
@app.get("/health")
def health():
    return {"status": "ok", "classes": _state.get("class_names", [])}

# Receives audio file upload from the app and returns car fault prediction
@app.post("/predict")
async def predict(file: UploadFile = File(...)):
    if not file.filename.lower().endswith((".wav", ".m4a", ".mp3", ".ogg", ".flac")):
        raise HTTPException(status_code=400, detail="Unsupported audio format.")

    try:
        raw_bytes = await file.read()

        debug_dir = "debug_uploads"
        os.makedirs(debug_dir, exist_ok=True)
        debug_path = os.path.join(debug_dir, f"upload_{int(__import__('time').time())}.wav")
        with open(debug_path, "wb") as f:
            f.write(raw_bytes)
        print(f"[DEBUG] Saved incoming upload to: {debug_path} ({len(raw_bytes)} bytes)")

        audio, _ = librosa.load(io.BytesIO(raw_bytes), sr=SR)
        print(f"[DEBUG] Decoded audio: {len(audio)} samples ({len(audio)/SR:.2f}s), max amplitude: {max(abs(audio)) if len(audio) else 0:.6f}")
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Could not decode audio: {e}")

    result = predict_from_waveform(audio)

    print(f"[DEBUG] PREDICTION -> class: {result['predicted_class']}  "
          f"confidence: {result['confidence']*100:.2f}%  "
          f"(over {result['windows_used']} window(s))")
    all_sorted = sorted(result['all_probabilities'].items(), key=lambda x: -x[1])
    print(f"[DEBUG] All classes (sorted):")
    for name, p in all_sorted:
        bar = "#" * int(p * 40)
        print(f"  {name:<50s} {p*100:5.1f}%  {bar}")

    return result