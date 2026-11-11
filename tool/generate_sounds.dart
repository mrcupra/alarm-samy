import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

Uint8List buildRichWav({
  required List<double> frequencies,
  required int noteDurationMs,
  required int loops,
  double volume = 0.92,
  bool isSiren = false,
}) {
  const int sampleRate = 44100;
  final int samplesPerNote = ((sampleRate * noteDurationMs) / 1000).round();
  final int totalNotes = frequencies.length * loops;
  final int totalSamples = samplesPerNote * totalNotes;
  final int numChannels = 2; // Stereo for full, rich playback on Windows & iOS
  final int bytesPerSample = 2; // 16-bit PCM
  final int blockAlign = numChannels * bytesPerSample;
  final int byteRate = sampleRate * blockAlign;
  final int dataSize = totalSamples * blockAlign;
  final int fileSize = 44 + dataSize;

  final ByteData buffer = ByteData(fileSize);

  void writeStr(int offset, String s) {
    for (int i = 0; i < s.length; i++) {
      buffer.setUint8(offset + i, s.codeUnitAt(i));
    }
  }

  writeStr(0, 'RIFF');
  buffer.setUint32(4, fileSize - 8, Endian.little);
  writeStr(8, 'WAVE');
  writeStr(12, 'fmt ');
  buffer.setUint32(16, 16, Endian.little);
  buffer.setUint16(20, 1, Endian.little); // PCM = 1
  buffer.setUint16(22, numChannels, Endian.little);
  buffer.setUint32(24, sampleRate, Endian.little);
  buffer.setUint32(28, byteRate, Endian.little);
  buffer.setUint16(32, blockAlign, Endian.little);
  buffer.setUint16(34, 16, Endian.little);
  writeStr(36, 'data');
  buffer.setUint32(40, dataSize, Endian.little);

  int offset = 44;
  for (int l = 0; l < loops; l++) {
    for (int n = 0; n < frequencies.length; n++) {
      final double baseFreq = frequencies[n];
      final double nextFreq = frequencies[(n + 1) % frequencies.length];

      for (int i = 0; i < samplesPerNote; i++) {
        final double t = i / sampleRate;
        final double progress = i / samplesPerNote;

        final double freq = isSiren
            ? baseFreq + (nextFreq - baseFreq) * progress
            : baseFreq;

        double envelope = 1.0;
        if (progress < 0.06) {
          envelope = progress / 0.06;
        } else if (progress > 0.75) {
          envelope = (1.0 - progress) / 0.25;
        }

        // Rich harmonic synthesis
        final double w1 = math.sin(2 * math.pi * freq * t);
        final double w2 = 0.40 * math.sin(2 * math.pi * (freq * 2.0) * t);
        final double w3 = 0.20 * math.sin(2 * math.pi * (freq * 1.5) * t);
        final double w4 = 0.12 * math.sin(2 * math.pi * (freq * 3.0) * t);

        final double raw = ((w1 + w2 + w3 + w4) / 1.72) * envelope * volume;
        final int sample = (raw * 32767).round().clamp(-32768, 32767);

        // Left & Right channels
        buffer.setInt16(offset, sample, Endian.little);
        buffer.setInt16(offset + 2, sample, Endian.little);
        offset += 4;
      }
    }
  }

  return buffer.buffer.asUint8List();
}

void main() async {
  final outDir = Directory('assets/sounds');
  if (!outDir.existsSync()) {
    outDir.createSync(recursive: true);
  }

  final tones = <String, Map<String, dynamic>>{
    'samy_dawn': {
      'freqs': [523.25, 659.25, 783.99, 1046.50, 783.99, 1046.50, 1318.51, 1046.50],
      'ms': 210,
      'loops': 3,
      'siren': false,
    },
    'samy_chime': {
      'freqs': [587.33, 739.99, 880.00, 1174.66, 880.00, 1174.66, 1479.98, 1174.66],
      'ms': 190,
      'loops': 3,
      'siren': false,
    },
    'samy_radar': {
      'freqs': [880.0, 987.77, 1046.50, 987.77, 880.0, 1174.66, 1046.50, 1318.51],
      'ms': 160,
      'loops': 3,
      'siren': false,
    },
    'samy_thunder': {
      'freqs': [784.0, 1318.51, 784.0, 1567.98, 880.0, 1760.0],
      'ms': 150,
      'loops': 4,
      'siren': true,
    },
    'samy_royal': {
      'freqs': [440.0, 554.37, 659.25, 880.0, 659.25, 880.0, 1108.73, 1318.51],
      'ms': 200,
      'loops': 3,
      'siren': false,
    },
    'samy_cyber': {
      'freqs': [329.63, 493.88, 659.25, 987.77, 783.99, 1174.66, 1318.51, 1567.98],
      'ms': 145,
      'loops': 3,
      'siren': false,
    },
    'samy_success': {
      'freqs': [523.25, 659.25, 783.99, 1046.50],
      'ms': 115,
      'loops': 1,
      'siren': false,
    },
    'samy_error': {
      'freqs': [240.0, 180.0],
      'ms': 160,
      'loops': 1,
      'siren': false,
    },
    'samy_startup': {
      'freqs': [440.0, 554.37, 659.25, 880.0, 1108.73],
      'ms': 130,
      'loops': 1,
      'siren': false,
    },
    'samy_keepalive': {
      'freqs': [30.0, 30.0, 30.0, 30.0],
      'ms': 500,
      'loops': 2,
      'siren': false,
    },
  };

  for (final entry in tones.entries) {
    final wav = buildRichWav(
      frequencies: (entry.value['freqs'] as List<num>).map((e) => e.toDouble()).toList(),
      noteDurationMs: entry.value['ms'] as int,
      loops: entry.value['loops'] as int,
      isSiren: entry.value['siren'] as bool,
    );
    final file = File('assets/sounds/${entry.key}.wav');
    await file.writeAsBytes(wav, flush: true);
    stdout.writeln('Generated ${file.path} (${wav.length} bytes)');
  }
}
