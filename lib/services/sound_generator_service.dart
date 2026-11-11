import 'dart:io';
import 'dart:math' as math;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
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
  bool _contextInitialized = false;

  bool get isPlaying => _isPlaying;
  String? get currentRingtoneId => _currentRingtoneId;

  static const Set<String> _builtInAssetIds = {
    'samy_dawn',
    'samy_chime',
    'samy_radar',
    'samy_thunder',
    'samy_royal',
    'samy_cyber',
  };

  Future<void> _ensureAudioContext() async {
    if (_contextInitialized) return;
    _contextInitialized = true;
    try {
      await AudioPlayer.global.setAudioContext(
        AudioContext(
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.playback,
            options: const {
              AVAudioSessionOptions.mixWithOthers,
              AVAudioSessionOptions.defaultToSpeaker,
            },
          ),
          android: const AudioContextAndroid(
            isSpeakerphoneOn: true,
            stayAwake: true,
            contentType: AndroidContentType.sonification,
            usageType: AndroidUsageType.alarm,
            audioFocus: AndroidAudioFocus.gain,
          ),
        ),
      );
      await _alarmPlayer.setVolume(1.0);
      await _fxPlayer.setVolume(1.0);
    } catch (_) {}
  }

  /// Synthesizes a 44.1kHz Stereo 16-bit PCM WAV buffer for custom melodies
  Uint8List generateMelodyWav({
    required List<double> frequencies,
    int noteDurationMs = 200,
    int loops = 3,
    double volume = 0.92,
  }) {
    const int sampleRate = 44100;
    final int samplesPerNote = ((sampleRate * noteDurationMs) / 1000).round();
    final int totalNotes = frequencies.length * loops;
    final int totalSamples = samplesPerNote * totalNotes;
    const int numChannels = 2; // Stereo
    const int blockAlign = numChannels * 2;
    const int byteRate = sampleRate * blockAlign;
    final int dataSize = totalSamples * blockAlign;
    final int fileSize = 44 + dataSize;

    final ByteData buffer = ByteData(fileSize);

    _writeString(buffer, 0, 'RIFF');
    buffer.setUint32(4, fileSize - 8, Endian.little);
    _writeString(buffer, 8, 'WAVE');

    _writeString(buffer, 12, 'fmt ');
    buffer.setUint32(16, 16, Endian.little);
    buffer.setUint16(20, 1, Endian.little);
    buffer.setUint16(22, numChannels, Endian.little);
    buffer.setUint32(24, sampleRate, Endian.little);
    buffer.setUint32(28, byteRate, Endian.little);
    buffer.setUint16(32, blockAlign, Endian.little);
    buffer.setUint16(34, 16, Endian.little);

    _writeString(buffer, 36, 'data');
    buffer.setUint32(40, dataSize, Endian.little);

    int offset = 44;
    for (int l = 0; l < loops; l++) {
      for (int n = 0; n < frequencies.length; n++) {
        final double freq = frequencies[n];
        for (int i = 0; i < samplesPerNote; i++) {
          final double t = i / sampleRate;
          final double progress = i / samplesPerNote;

          double envelope = 1.0;
          if (progress < 0.06) {
            envelope = progress / 0.06;
          } else if (progress > 0.74) {
            envelope = (1.0 - progress) / 0.26;
          }

          final double w1 = math.sin(2 * math.pi * freq * t);
          final double w2 = 0.40 * math.sin(2 * math.pi * (freq * 2.0) * t);
          final double w3 = 0.20 * math.sin(2 * math.pi * (freq * 1.5) * t);
          final double w4 = 0.12 * math.sin(2 * math.pi * (freq * 3.0) * t);

          final double combined =
              ((w1 + w2 + w3 + w4) / 1.72) * envelope * volume;
          final int sample =
              (combined * 32767).round().clamp(-32768, 32767);

          buffer.setInt16(offset, sample, Endian.little);
          buffer.setInt16(offset + 2, sample, Endian.little);
          offset += 4;
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
      await _ensureAudioContext();
      await stopRingtone();
      _isPlaying = true;
      _currentRingtoneId = ringtone.id;

      await _alarmPlayer.setVolume(1.0);
      await _alarmPlayer.setReleaseMode(
        loop ? ReleaseMode.loop : ReleaseMode.stop,
      );

      if (ringtone.isCustom &&
          ringtone.customFilePath != null &&
          ringtone.customFilePath!.isNotEmpty) {
        await _alarmPlayer.play(DeviceFileSource(ringtone.customFilePath!));
      } else if (_builtInAssetIds.contains(ringtone.id)) {
        await _alarmPlayer.play(AssetSource('sounds/${ringtone.id}.wav'));
      } else {
        final wavBytes = generateMelodyWav(
          frequencies: ringtone.melodyFrequencies,
          noteDurationMs: ringtone.noteDurationMs,
          loops: loop ? 4 : 2,
        );
        if (kIsWeb) {
          await _alarmPlayer.play(
            BytesSource(wavBytes, mimeType: 'audio/wav'),
          );
        } else {
          final tempFile = File(
            '${Directory.systemTemp.path}/samy_tone_${ringtone.id.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '')}.wav',
          );
          await tempFile.writeAsBytes(wavBytes, flush: true);
          await _alarmPlayer.play(DeviceFileSource(tempFile.path));
        }
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
      SystemSound.play(SystemSoundType.alert);
    }
  }

  Future<void> stopRingtone() async {
    try {
      _isPlaying = false;
      _currentRingtoneId = null;
      await _alarmPlayer.stop();
    } catch (_) {}
  }

  Future<void> playStartupChime() async {
    try {
      await _ensureAudioContext();
      await _fxPlayer.stop();
      await _fxPlayer.setVolume(0.9);
      await _fxPlayer.play(AssetSource('sounds/samy_startup.wav'));
    } catch (_) {}
  }

  Future<void> playSuccessChime() async {
    try {
      await _ensureAudioContext();
      HapticFeedback.heavyImpact();
      await _fxPlayer.stop();
      await _fxPlayer.setVolume(1.0);
      await _fxPlayer.play(AssetSource('sounds/samy_success.wav'));
    } catch (_) {}
  }

  Future<void> playErrorBuzz() async {
    try {
      await _ensureAudioContext();
      HapticFeedback.vibrate();
      await _fxPlayer.stop();
      await _fxPlayer.setVolume(1.0);
      await _fxPlayer.play(AssetSource('sounds/samy_error.wav'));
    } catch (_) {}
  }
}
