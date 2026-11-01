/// Centralized copy for alert dialogs (see: ALERT MESSAGES / DIALOGS in UI flow).
class AlertStrings {
  // 1. Permission Dialog
  static const permissionTitle = 'Permission Required';
  static const permissionBody =
      'Microphone permission is required to record engine sound.';
  static const permissionCancel = 'Cancel';
  static const permissionAllow = 'Allow';

  // 2. Short Recording Alert
  static const shortRecordingTitle = 'Recording Stopped';
  static const shortRecordingBody =
      'Recording is too short.\nPlease record for at least 5 seconds.';

  // 3. High Noise Alert
  static const highNoiseTitle = 'High Noise Detected';
  static const highNoiseBody =
      'Too much background noise detected. Please move to a quieter place and try again.';

  // 4. Processing Error Alert
  static const processingFailedTitle = 'Processing Failed';
  static const processingFailedBody = 'Failed to process audio. Please try again.';

  // 5. Model Error Alert
  static const modelNotAvailableTitle = 'Model Not Available';
  static const modelNotAvailableBody =
      'AI model is not available. Please check app resources.';

  static const ok = 'OK';

  // 6. No Internet Connection
  static const noInternetTitle = 'No Internet Connection';
  static const noInternetBody =
      'This feature requires an internet connection. Please check your network and try again.';

  // 7. Storage Full
  static const storageFullTitle = 'Storage Full';
  static const storageFullBody =
      'Not enough storage to save the recording. Please free up space and try again.';
}

/// Centralized strings for the Recording Screen
class RecordingStrings {
  static const title = 'Recording...';
  static const subtitle = 'Please keep your device\nnear the engine.';
  static const startRecording = 'Start Recording';
  static const stopRecording = 'Stop Recording';
  static const tipsTitle = 'Tips';
  static const tipsBody =
      'Record for up to 30 seconds in an environment with less noise. '
      'Your recording is analyzed in 5-second segments.';
  static const timerTotalFormat = '00:30';
}

/// Centralized strings for the Processing Screen
class ProcessingStrings {
  static const title = 'Processing...';
  static const subtitle = 'Analyzing engine sound in 5-second segments';
  static const noiseReductionStep = 'Noise Reduction';
  static const melSpectrogramStep = 'Mel Spectrogram';
  static const aiClassificationStep = 'AI Classification';
  static const tipsBody = 'Please wait, this may take\nfew seconds.';
}

/// Centralized strings for the Result Screens
class ResultStrings {
  static const faultDetected = 'Fault Detected';
  static const healthyDetected = 'Engine Healthy';
  static const noFaultDetected = 'No Fault Detected';
  static const uncertainResult = 'Uncertain Result';
  static const recordAgain = 'Record Again';
  static const tryAgain = 'Try Again';
  static const viewDetails = 'View Details';
  static const viewTips = 'View Tips';
}
