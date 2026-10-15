import 'dart:io';
import 'dart:typed_data';

/// Splits a recorded WAV file into consecutive fixed-length WAV chunks so
/// each chunk can be sent to the backend and classified independently.
///
/// Works directly on the raw PCM bytes produced by [AudioRecordingService]
/// (16-bit PCM WAV, 32kHz mono) — no native audio decoding needed, since we
/// wrote the file ourselves in that exact format.
class AudioChunkService {
  /// Splits the WAV file at [sourcePath] into consecutive chunks of
  /// [chunkSeconds] length each (default 5s). Returns the paths to the
  /// newly written chunk files, in chronological order.
  ///
  /// A trailing chunk shorter than [minTrailingSeconds] is dropped instead
  /// of being sent to the model as a near-silent sliver.
  Future<List<String>> splitIntoChunks(
    String sourcePath, {
    int chunkSeconds = 5,
    double minTrailingSeconds = 1.0,
  }) async {
    final file = File(sourcePath);
    final bytes = await file.readAsBytes();
    final wav = _WavData.parse(bytes);

    final bytesPerSecond =
        wav.sampleRate * wav.numChannels * (wav.bitsPerSample ~/ 8);
    final chunkByteLen = bytesPerSecond * chunkSeconds;
    final minTrailingBytes = (bytesPerSecond * minTrailingSeconds).round();

    final chunkPaths = <String>[];
    final baseName =
        sourcePath.toLowerCase().endsWith('.wav')
            ? sourcePath.substring(0, sourcePath.length - 4)
            : sourcePath;

    var offset = 0;
    var index = 0;

    while (offset < wav.data.length) {
      final remaining = wav.data.length - offset;
      final len = remaining < chunkByteLen ? remaining : chunkByteLen;

      // Drop a trailing sliver that's too short to be a meaningful window.
      if (len < minTrailingBytes) break;

      final chunkPcm = wav.data.sublist(offset, offset + len);
      final chunkBytes = _WavData.buildWavBytes(
        pcm: chunkPcm,
        sampleRate: wav.sampleRate,
        numChannels: wav.numChannels,
        bitsPerSample: wav.bitsPerSample,
      );

      final chunkPath = '${baseName}_chunk$index.wav';
      await File(chunkPath).writeAsBytes(chunkBytes, flush: true);
      chunkPaths.add(chunkPath);

      offset += len;
      index++;
    }

    return chunkPaths;
  }

  /// Deletes the temporary chunk files created by [splitIntoChunks].
  Future<void> cleanupChunks(List<String> chunkPaths) async {
    for (final path in chunkPaths) {
      try {
        final f = File(path);
        if (await f.exists()) {
          await f.delete();
        }
      } catch (_) {
        // Best-effort cleanup only; leftover temp files aren't fatal.
      }
    }
  }
}

/// Minimal WAV (RIFF/PCM) reader & writer — just enough to locate the
/// `fmt ` and `data` chunks of a recorded file and re-wrap raw PCM byte
/// ranges with a fresh 44-byte canonical header.
class _WavData {
  final int sampleRate;
  final int numChannels;
  final int bitsPerSample;
  final Uint8List data;

  _WavData({
    required this.sampleRate,
    required this.numChannels,
    required this.bitsPerSample,
    required this.data,
  });

  factory _WavData.parse(Uint8List bytes) {
    if (bytes.length < 12 ||
        String.fromCharCodes(bytes.sublist(0, 4)) != 'RIFF' ||
        String.fromCharCodes(bytes.sublist(8, 12)) != 'WAVE') {
      throw const FormatException('Not a valid WAV file.');
    }

    final byteData = ByteData.sublistView(bytes);

    int sampleRate = 32000;
    int numChannels = 1;
    int bitsPerSample = 16;
    Uint8List? pcmData;

    var offset = 12;
    while (offset + 8 <= bytes.length) {
      final chunkId = String.fromCharCodes(bytes.sublist(offset, offset + 4));
      final chunkSize = byteData.getUint32(offset + 4, Endian.little);
      final chunkStart = offset + 8;

      if (chunkId == 'fmt ') {
        numChannels = byteData.getUint16(chunkStart + 2, Endian.little);
        sampleRate = byteData.getUint32(chunkStart + 4, Endian.little);
        bitsPerSample = byteData.getUint16(chunkStart + 14, Endian.little);
      } else if (chunkId == 'data') {
        final end = (chunkStart + chunkSize) <= bytes.length
            ? chunkStart + chunkSize
            : bytes.length;
        pcmData = bytes.sublist(chunkStart, end);
      }

      // RIFF chunks are word-aligned (padded to an even byte count).
      offset = chunkStart + chunkSize + (chunkSize.isOdd ? 1 : 0);
    }

    if (pcmData == null) {
      throw const FormatException('WAV file has no data chunk.');
    }

    return _WavData(
      sampleRate: sampleRate,
      numChannels: numChannels,
      bitsPerSample: bitsPerSample,
      data: pcmData,
    );
  }

  static Uint8List buildWavBytes({
    required Uint8List pcm,
    required int sampleRate,
    required int numChannels,
    required int bitsPerSample,
  }) {
    final blockAlign = numChannels * (bitsPerSample ~/ 8);
    final byteRate = sampleRate * blockAlign;
    final dataLen = pcm.length;
    final header = ByteData(44);

    void writeString(int offset, String s) {
      for (var i = 0; i < s.length; i++) {
        header.setUint8(offset + i, s.codeUnitAt(i));
      }
    }

    writeString(0, 'RIFF');
    header.setUint32(4, 36 + dataLen, Endian.little);
    writeString(8, 'WAVE');
    writeString(12, 'fmt ');
    header.setUint32(16, 16, Endian.little); // PCM fmt chunk size
    header.setUint16(20, 1, Endian.little); // format = PCM
    header.setUint16(22, numChannels, Endian.little);
    header.setUint32(24, sampleRate, Endian.little);
    header.setUint32(28, byteRate, Endian.little);
    header.setUint16(32, blockAlign, Endian.little);
    header.setUint16(34, bitsPerSample, Endian.little);
    writeString(36, 'data');
    header.setUint32(40, dataLen, Endian.little);

    final out = BytesBuilder();
    out.add(header.buffer.asUint8List());
    out.add(pcm);
    return out.toBytes();
  }
}
