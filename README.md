# 🎵 Flutter Notemus

[![Flutter](https://img.shields.io/badge/Flutter-3.8.1+-blue.svg)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.8.1+-blue.svg)](https://dart.dev/)
[![SMuFL](https://img.shields.io/badge/SMuFL-1.40-green.svg)](https://w3c.github.io/smufl/latest/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**A powerful Flutter package for professional music notation rendering with complete SMuFL support.**

Flutter Notemus provides a comprehensive solution for rendering high-quality music notation in Flutter applications. Built on the SMuFL (Standard Music Font Layout) specification, it offers precise, professional-grade music engraving.

---

## ✨ Features

### 🎼 Complete Music Notation
- **2932 SMuFL glyphs** from the Bravura font
- **Professional engraving** following industry standards
- **Precise positioning** using SMuFL anchors and bounding boxes
- **Typography-aware rendering** with optical centers

### 🎹 Musical Elements
- **Notes & Rests**: All durations from whole notes to 1024th notes
- **Clefs**: Treble, bass, alto, tenor, percussion, and tablature
- **Key Signatures**: All major and minor keys with accidentals
- **Time Signatures**: Simple, compound, and complex meters
- **Accidentals**: Natural, sharp, flat, double sharp/flat, and microtones
- **Articulations**: Staccato, accent, tenuto, marcato, and more
- **Ornaments**: Trills, turns, mordents, grace notes
- **Dynamics**: pp to ff, crescendo, diminuendo, sforzando
- **Chords**: Multi-note chords with proper stem alignment
- **Beams**: Automatic beaming for note groups
- **Tuplets**: Triplets, quintuplets, septuplets, etc.
- **Slurs & Ties**: Curved connectors between notes
- **Ledger Lines**: Automatic for notes outside the staff

### 🏗️ Architecture
- **Single Responsibility Principle**: Specialized renderers for each element
- **Modular Design**: Easy to extend and customize
- **Staff Position Calculator**: Unified pitch-to-position conversion
- **Collision Detection**: Smart spacing and layout
- **Theme System**: Customizable colors and styles

### 📊 Format Support
- **JSON**: Import and export music data
- **Programmatic API**: Build music programmatically

---

## 🚀 Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_notemus: ^0.1.0
```

Then run:

```bash
flutter pub get
```

---

## 📖 Quick Start

```dart
import 'package:flutter/material.dart';
import 'package:flutter_notemus/flutter_notemus.dart';

class SimpleMusicExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Create a staff
    final staff = Staff();
    final measure = Measure();

    // Add clef, key signature, and time signature
    measure.add(Clef(clefType: ClefType.treble));
    measure.add(KeySignature(fifths: 0)); // C major
    measure.add(TimeSignature(numerator: 4, denominator: 4));

    // Add notes: C, D, E, F
    measure.add(Note(
      pitch: Pitch(step: 'C', octave: 4),
      duration: NoteDuration(type: DurationType.quarter),
    ));
    measure.add(Note(
      pitch: Pitch(step: 'D', octave: 4),
      duration: NoteDuration(type: DurationType.quarter),
    ));
    measure.add(Note(
      pitch: Pitch(step: 'E', octave: 4),
      duration: NoteDuration(type: DurationType.quarter),
    ));
    measure.add(Note(
      pitch: Pitch(step: 'F', octave: 4),
      duration: NoteDuration(type: DurationType.quarter),
    ));

    staff.add(measure);

    // Render the staff
    return MusicScore(
      staff: staff,
      theme: MusicScoreTheme(),
      staffSpace: 12.0,
    );
  }
}
```

---

## 🎼 Advanced Examples

### Chords

```dart
Chord(
  notes: [
    Note(
      pitch: Pitch(step: 'C', octave: 4),
      duration: NoteDuration(type: DurationType.quarter),
    ),
    Note(
      pitch: Pitch(step: 'E', octave: 4),
      duration: NoteDuration(type: DurationType.quarter),
    ),
    Note(
      pitch: Pitch(step: 'G', octave: 4),
      duration: NoteDuration(type: DurationType.quarter),
    ),
  ],
  duration: NoteDuration(type: DurationType.quarter),
)
```

### Augmentation Dots

```dart
Note(
  pitch: Pitch(step: 'C', octave: 4),
  duration: NoteDuration(
    type: DurationType.quarter,
    dots: 2, // Double-dotted quarter note
  ),
)
```

### Accidentals

```dart
Note(
  pitch: Pitch(
    step: 'F',
    octave: 4,
    accidental: AccidentalType.sharp,
  ),
  duration: NoteDuration(type: DurationType.quarter),
)
```

### Articulations

```dart
Note(
  pitch: Pitch(step: 'C', octave: 4),
  duration: NoteDuration(type: DurationType.quarter),
  articulations: [
    Articulation(type: ArticulationType.staccato),
    Articulation(type: ArticulationType.accent),
  ],
)
```

### Dynamics

```dart
measure.add(Dynamic(
  type: DynamicType.forte,
  customText: 'f',
));

// Crescendo (hairpin)
measure.add(Dynamic(
  type: DynamicType.crescendo,
  isHairpin: true,
  length: 120.0,
));
```

---

## 🎨 Themes

Flutter Notemus supports customizable themes:

```dart
MusicScore(
  staff: staff,
  theme: MusicScoreTheme(
    noteheadColor: Colors.blue,
    stemColor: Colors.blue,
    staffLineColor: Colors.black,
    accidentalColor: Colors.red,
    ornamentColor: Colors.green,
    showLedgerLines: true,
  ),
)
```

---

## 📚 Documentation

- **[API Reference](docs/api-reference.md)** - Complete API documentation
- **[Architecture](docs/architecture.md)** - System design and principles
- **[Examples](example/)** - Complete working examples
- **[SMuFL Spec](https://w3c.github.io/smufl/latest/)** - SMuFL standard reference

---

## 🏗️ Architecture Highlights

Flutter Notemus follows **Single Responsibility Principle** with specialized renderers:

- **`NoteRenderer`** - Note heads
- **`StemRenderer`** - Note stems
- **`FlagRenderer`** - Note flags
- **`DotRenderer`** - Augmentation dots
- **`LedgerLineRenderer`** - Ledger lines
- **`AccidentalRenderer`** - Accidentals (sharps, flats, etc.)
- **`ChordRenderer`** - Multi-note chords
- **`DynamicRenderer`** - Dynamic markings
- **`RepeatMarkRenderer`** - Repeat signs (coda, segno)
- **`TextRenderer`** - Musical text

Each renderer has a **single, well-defined responsibility**, making the codebase maintainable and testable.

---

## 🧪 Testing

Run tests:

```bash
flutter test
```

Run example app:

```bash
cd example
flutter run
```

---

## 📦 What's Included

- ✅ Complete SMuFL glyph support (Bravura font)
- ✅ Professional music engraving engine
- ✅ Specialized renderers following SRP
- ✅ Staff position calculator
- ✅ Collision detection system
- ✅ Theme system
- ✅ JSON parser
- ✅ Comprehensive examples
- ✅ Full documentation

---

## 🤝 Contributing

Contributions are welcome! Please read our [Contributing Guide](docs/contributing.md) for details.

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Credits

- **Bravura Font** by [Steinberg Media Technologies](https://www.smufl.org/fonts/)
- **SMuFL Standard** by [W3C Music Notation Community Group](https://www.w3.org/community/music-notation/)
- Engraving principles from:
  - "Behind Bars" by Elaine Gould
  - "The Art of Music Engraving" by Ted Ross

---

## 🌟 Why Flutter Notemus?

| Feature | Flutter Notemus | Others |
|---------|----------------|--------|
| **SMuFL Compliant** | ✅ Full support | ⚠️ Partial |
| **Professional Engraving** | ✅ Typography-aware | ❌ Basic |
| **Modular Architecture** | ✅ SRP-based | ❌ Monolithic |
| **Collision Detection** | ✅ Smart spacing | ❌ Manual |
| **Customizable Themes** | ✅ Full control | ⚠️ Limited |
| **Active Development** | ✅ Yes | ⚠️ Varies |

---

**Flutter Notemus** - Professional music notation for Flutter 🎵

Made with ♥ by the Flutter community
