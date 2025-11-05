// lib/core/voice.dart

import 'musical_element.dart';
import 'measure.dart';

/// Representa uma voz em notação polifônica
class Voice {
  final int number;
  final List<MusicalElement> elements;
  final String? name;

  Voice({required this.number, this.elements = const [], this.name});

  void add(MusicalElement element) => elements.add(element);
}

/// Compasso com múltiplas vozes
class MultiVoiceMeasure extends Measure {
  final Map<int, Voice> voices = {};

  void addVoice(Voice voice) {
    voices[voice.number] = voice;
  }

  Voice? getVoice(int number) => voices[number];

  List<int> get voiceNumbers => voices.keys.toList()..sort();
}
