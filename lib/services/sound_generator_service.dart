import 'dart:math' as math;
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import '../models/alarm_models.dart';

class SoundGeneratorService {
  static final SoundGeneratorService _instance =
      SoundGeneratorService._internal();
  factory SoundGeneratorService() => _instance;
  SoundGeneratorService._internal();

  final AudioPlayer _alarmPlayer = AudioPlayer();
  final AudioPlayer _fxPlayer = AudioPlayer();
  bool _isPlaying = false;
  String? _currentRingtoneId;

  bool get isPlaying => _isPlaying;
  String? get currentRingtoneId => _currentRingtoneId;

  /// Synthesizes a rich polyphonic 16-bit PCM WAV byte buffer from frequencies
  Uint8List generateMelodyWav({
    required List<double> frequencies,
    int noteDurationMs = 220,
    int loops = 3,
    double volume = 0.85,
  }) {
    const int sampleRate = 22050;
    final int samplesPerNote = ((sampleRate * noteDurationMs) / 1000).round();
    final int totalNotes = frequencies.length * loops;
    final int totalSamples = samplesPerNote * totalNotes;
    final int dataSize = totalSamples * 2; // 16-bit mono
    final int fileSize = 44 + dataSize;

    final ByteData buffer = ByteData(fileSize);

    // RIFF Header
    _writeString(buffer, 0, 'RIFF');
    buffer.setUint32(4, fileSize - 8, Endian.little);
    _writeString(buffer, 8, 'WAVE');

    // fmt subchunk
    _writeString(buffer, 12, 'fmt ');
    buffer.setUint32(16, 16, Endian.little); // Subchunk1Size (16 for PCM)
    buffer.setUint16(20, 1, Endian.little); // AudioFormat (1 = PCM)
    buffer.setUint16(22, 1, Endian.little); // NumChannels (1 = mono)
    buffer.setUint32(24, sampleRate, Endian.little);
    buffer.setUint32(28, sampleRate * 2, Endian.little); // ByteRate
    buffer.setUint16(32, 2, Endian.little); // BlockAlign
    buffer.setUint16(34, 16, Endian.little); // BitsPerSample

    // data subchunk
    _writeString(buffer, 36, 'data');
    buffer.setUint32(40, dataSize, Endian.little);

    int offset = 44;
    for (int l = 0; l < loops; l++) {
      for (int n = 0; n < frequencies.length; n++) {
        final double freq = frequencies[n];
        for (int i = 0; i < samplesPerNote; i++) {
          final double t = i / sampleRate;
          final double progress = i / samplesPerNote;

          // Smooth attack & decay envelope for warm bell/synth tone
          double envelope = 1.0;
          if (progress < 0.08) {
            envelope = progress / 0.08;
          } else if (progress > 0.72) {
            envelope = (1.0 - progress) / 0.28;
          }

          // Fundamental + octave + fifth overtone for rich harmonic sound
          final double wave1 = math.sin(2 * math.pi * freq * t);
          final double wave2 = 0.35 * math.sin(2 * math.pi * (freq * 2.0) * t);
          final double wave3 = 0.15 * math.sin(2 * math.pi * (freq * 1.5) * t);

          final double combined =
              ((wave1 + wave2 + wave3) / 1.5) * envelope * volume;
          final int sample =
              (combined * 32767).round().clamp(-32768, 32767);

          buffer.setInt16(offset, sample, Endian.little);
          offset += 2;
        }
      }
    }

    return buffer.buffer.asUint8List();
  }

  void _writeString(ByteData data, int offset, String value) {
    for (int i = 0; i < value.length; i++) {
      data.setUint8(offset + i, value.codeUnitAt(i));
    }
  }

  Future<void> playRingtone(RingtoneItem ringtone, {bool loop = false}) async {
    try {
      await stopRingtone();
      _isPlaying = true;
      _currentRingtoneId = ringtone.id;

      await _alarmPlayer.setReleaseMode(
        loop ? ReleaseMode.loop : ReleaseMode.stop,
      );

      if (ringtone.isCustom &&
          ringtone.customFilePath != null &&
          ringtone.customFilePath!.isNotEmpty) {
        await _alarmPlayer.play(DeviceFileSource(ringtone.customFilePath!));
      } else {
        final wavBytes = generateMelodyWav(
          frequencies: ringtone.melodyFrequencies,
          noteDurationMs: ringtone.noteDurationMs,
          loops: loop ? 4 : 2,
        );
        await _alarmPlayer.play(BytesSource(wavBytes));
      }

      HapticFeedback.mediumImpact();

      if (!loop) {
        _alarmPlayer.onPlayerComplete.first.then((_) {
          if (_currentRingtoneId == ringtone.id) {
            _isPlaying = false;
            _currentRingtoneId = null;
          }
        });
      }
    } catch (_) {
      _isPlaying = false;
      _currentRingtoneId = null;
    }
  }

  Future<void> stopRingtone() async {
    try {
      _isPlaying = false;
      _currentRingtoneId = null;
      await _alarmPlayer.stop();
    } catch (_) {}
  }

  Future<void> playSuccessChime() async {
    try {
      HapticFeedback.heavyImpact();
      final bytes = generateMelodyWav(
        frequencies: const [523.25, 659.25, 783.99, 1046.50],
        noteDurationMs: 110,
        loops: 1,
        volume: 0.75,
      );
      await _fxPlayer.stop();
      await _fxPlayer.play(BytesSource(bytes));
    } catch (_) {}
  }

  Future<void> playErrorBuzz() async {
    try {
      HapticFeedback.vibrate();
      final bytes = generateMelodyWav(
        frequencies: const [220.0, 185.0],
        noteDurationMs: 140,
        loops: 1,
        volume: 0.8,
      );
      await _fxPlayer.stop();
      await _fxPlayer.play(BytesSource(bytes));
    } catch (_) {}
  }
}
