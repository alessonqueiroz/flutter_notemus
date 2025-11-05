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
- **Measure Validation**: Automatic music theory-based validation
  - Prevents overfilled measures
  - Real-time capacity checking
  - Detailed error messages
  - Tuplet-aware calculations

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

## ⚠️ Measure Validation System

**IMPORTANT:** Flutter Notemus includes a **strict measure validation system** that enforces musical correctness based on music theory rules.

### 🛡️ Automatic Validation

When you add notes to a measure with a `TimeSignature`, the system automatically validates that the total duration doesn't exceed the measure's capacity:

```dart
final measure = Measure(
  inheritedTimeSignature: TimeSignature(numerator: 4, denominator: 4),
);

// ✅ VALID: 4 quarter notes = 1.0 units (fits in 4/4)
measure.add(Note(pitch: Pitch(step: 'C', octave: 4), 
                 duration: Duration(DurationType.quarter))); // 0.25
measure.add(Note(pitch: Pitch(step: 'D', octave: 4), 
                 duration: Duration(DurationType.quarter))); // 0.25
measure.add(Note(pitch: Pitch(step: 'E', octave: 4), 
                 duration: Duration(DurationType.quarter))); // 0.25
measure.add(Note(pitch: Pitch(step: 'F', octave: 4), 
                 duration: Duration(DurationType.quarter))); // 0.25
```

### ❌ Validation Errors

**If you try to add more notes than the measure can hold, an exception will be thrown:**

```dart
final measure = Measure(
  inheritedTimeSignature: TimeSignature(numerator: 4, denominator: 4),
);

measure.add(Note(pitch: Pitch(step: 'C', octave: 4), 
                 duration: Duration(DurationType.half, dots: 1))); // 0.75
measure.add(Note(pitch: Pitch(step: 'D', octave: 4), 
                 duration: Duration(DurationType.eighth))); // 0.125

// ❌ ERROR: This will throw MeasureCapacityException!
measure.add(Note(pitch: Pitch(step: 'E', octave: 4), 
                 duration: Duration(DurationType.whole))); // 1.0

// Total would be: 0.75 + 0.125 + 1.0 = 1.875 units
// But 4/4 capacity is only 1.0 units!
// EXCESS: 0.875 units ← BLOCKED!
```

**Error Message:**
```
MeasureCapacityException: Não é possível adicionar Note ao compasso!
Compasso 4/4 (capacidade: 1 unidades)
Valor atual: 0.875 unidades
Tentando adicionar: 1 unidades
Total seria: 1.875 unidades
EXCESSO: 0.8750 unidades
❌ OPERAÇÃO BLOQUEADA - Remova figuras ou crie novo compasso!
```

### 📊 How Duration Works

The system calculates durations based on **music theory**:

| Figure | Base Value | With Single Dot | With Double Dot |
|--------|------------|----------------|-----------------|
| Whole (Semibreve) | 1.0 | 1.5 | 1.75 |
| Half (Mínima) | 0.5 | 0.75 | 0.875 |
| Quarter (Semínima) | 0.25 | 0.375 | 0.4375 |
| Eighth (Colcheia) | 0.125 | 0.1875 | 0.21875 |
| Sixteenth (Semicolcheia) | 0.0625 | 0.09375 | 0.109375 |

**Formula for dotted notes:**
- Single dot: `duration × 1.5`
- Double dot: `duration × 1.75`
- Multiple dots: `duration × (2 - 2^(-dots))`

### 🎯 Tuplets Support

Tuplets are automatically calculated with correct proportions:

```dart
// Triplet: 3 notes in the time of 2
Tuplet(
  actualNotes: 3,
  normalNotes: 2,
  elements: [
    Note(duration: Duration(DurationType.eighth)), // 0.125
    Note(duration: Duration(DurationType.eighth)), // 0.125
    Note(duration: Duration(DurationType.eighth)), // 0.125
  ],
) // Total: (0.125 × 3) × (2/3) = 0.25 units
```

### 🔄 TimeSignature Inheritance

Measures without explicit `TimeSignature` can inherit from previous measures:

```dart
final measure1 = Measure();
measure1.add(TimeSignature(numerator: 4, denominator: 4));
// ... add notes

final measure2 = Measure(
  inheritedTimeSignature: TimeSignature(numerator: 4, denominator: 4),
);
// measure2 inherits 4/4 from measure1 for validation
```

### ✅ Best Practices

1. **Always set TimeSignature** - Either in the measure or as inherited
2. **Check remaining space** - Use `measure.remainingValue` before adding notes
3. **Use try-catch** - Wrap `measure.add()` in try-catch for user input:

```dart
try {
  measure.add(Note(
    pitch: Pitch(step: 'C', octave: 4),
    duration: Duration(DurationType.quarter),
  ));
} on MeasureCapacityException catch (e) {
  print('Cannot add note: ${e.message}');
  // Show error to user or handle gracefully
}
```

4. **Validate before rendering** - The `MeasureValidator` provides detailed reports:

```dart
final validation = MeasureValidator.validateWithTimeSignature(
  measure,
  timeSignature,
);

if (!validation.isValid) {
  print('Invalid measure: ${validation.errors}');
  print('Expected: ${validation.expectedCapacity}');
  print('Actual: ${validation.actualDuration}');
}
```

### 🎵 Musical Correctness

This validation system ensures your notation follows **professional music engraving standards**:

- ✅ **No overfilled measures** - Prevents rhythmic errors
- ✅ **Clear error messages** - Shows exactly what's wrong
- ✅ **Theory-based** - Follows music theory rules
- ✅ **Preventive** - Catches errors BEFORE rendering
- ✅ **Tuplet-aware** - Correctly handles complex rhythms

**Remember:** The validation is your friend! It prevents creating invalid musical notation that would confuse performers.

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
- ✅ **Automatic measure validation system**
- ✅ Theme system
- ✅ JSON parser
- ✅ Comprehensive examples
- ✅ Full documentation

---

## ⚙️ Technical Notes: Flutter TextPainter & SMuFL

### 🔍 Understanding Baseline Corrections

**Important for contributors and advanced users!**

Flutter Notemus implements several baseline corrections to compensate for fundamental differences between Flutter's text rendering system and the SMuFL specification. Understanding these differences is crucial for maintaining and extending the library.

---

### 📐 The Core Issue

#### SMuFL Coordinate System
```
SMuFL uses precise glyph-based coordinates:
- Baseline: Center line of the glyph
- Bounding boxes: Exact per-glyph dimensions
- Example (noteheadBlack):
  bBoxSwY: -0.5 staff spaces
  bBoxNeY: +0.5 staff spaces
  Height: 1.0 staff space
```

#### Flutter TextPainter System
```
Flutter uses font-wide metrics (OpenType hhea table):
- ascent: ~2.5 staff spaces
- descent: ~2.5 staff spaces
- Total height: ~5.0 staff spaces (5× the actual glyph!)
```

**Why?** The font metrics must accommodate the **largest possible glyph** (clefs, ornaments, etc.), not individual noteheads.

---

### 🎯 Baseline Correction Formula

```dart
baselineCorrection = -textPainter.height * 0.5
                   = -(5.0 staff spaces) * 0.5
                   = -2.5 staff spaces
```

This correction:
1. ✅ Moves glyphs from Flutter's "top of box" coordinate to SMuFL's "baseline" coordinate
2. ✅ Ensures noteheads align precisely with staff lines
3. ✅ Maintains compatibility with SMuFL anchors (stemUpSE, stemDownNW)

---

### 📊 Impact on Components

#### Noteheads
```dart
// base_glyph_renderer.dart
static const GlyphDrawOptions noteheadDefault = GlyphDrawOptions(
  centerVertically: false,
  disableBaselineCorrection: false, // ← Correction ENABLED
);
```
**Result:** Noteheads render at correct staff positions ✅

#### Augmentation Dots
```dart
// dot_renderer.dart
double _calculateDotY(double noteY, int staffPosition) {
  // noteY already has -2.5 SS baseline correction applied
  // Compensate to position dots correctly:
  
  if (staffPosition.isEven) {
    return noteY - (coordinates.staffSpace * 2.5); // Compensate
  } else {
    return noteY - (coordinates.staffSpace * 2.0); // Compensate
  }
}
```
**Result:** Dots align perfectly in staff spaces ✅

---

### 🔬 Mathematical Proof

For a note on **staff line 2** (G4 in treble clef):

```
Without correction:
  staffPosition = -2
  noteY = 72.0px (baseline)
  TextPainter renders at: 72.0px ← TOO LOW!

With correction:
  staffPosition = -2
  noteY = 72.0px
  baselineCorrection = -30.0px (-2.5 SS)
  Final Y = 72.0 - 30.0 = 42.0px ← CORRECT!

Dot position:
  dotY = noteY - (2.5 × staffSpace)
       = 72.0 - 30.0
       = 42.0px
  Then add 0.5 SS to move to space above line
  Final dotY = 42.0 - 6.0 = 36.0px ← PERFECT!
```

---

### 🏗️ Design Decisions

#### Why Not Modify the Font?
- ❌ Would break compatibility with standard Bravura distribution
- ❌ Would lose updates and improvements from SMuFL team
- ❌ Wouldn't solve the fundamental Flutter/SMuFL difference

#### Why Not Use Canvas.drawParagraph Directly?
- ❌ More complex API
- ❌ Loses Flutter's text rendering optimizations
- ❌ More difficult to maintain

#### Why TextPainter + Corrections? ✅
- ✅ Uses Flutter's native, optimized text rendering
- ✅ Works with any SMuFL-compliant font
- ✅ Mathematical corrections are predictable and documentable
- ✅ Well-tested and proven approach

---

### 📚 References

- **SMuFL Specification**: [https://w3c.github.io/smufl/latest/](https://w3c.github.io/smufl/latest/)
- **OpenType hhea Table**: [https://docs.microsoft.com/en-us/typography/opentype/spec/hhea](https://docs.microsoft.com/en-us/typography/opentype/spec/hhea)
- **"Behind Bars"** by Elaine Gould - Music engraving best practices
- **Flutter TextPainter**: [https://api.flutter.dev/flutter/painting/TextPainter-class.html](https://api.flutter.dev/flutter/painting/TextPainter-class.html)

---

### 💡 For Contributors

When adding new renderers or modifying existing ones:

1. **Understand the coordinate system** - Are you working with SMuFL baseline or Flutter top-of-box?
2. **Check if baseline correction is enabled** - Most glyphs need it for proper positioning
3. **Test with multiple staff positions** - Verify alignment on lines AND spaces
4. **Document empirical values** - If you need corrections, explain why mathematically
5. **Refer to `SOLUCAO_FINAL_PONTOS.md`** - Detailed case study of the dot positioning solution

**Key principle:** All "magic numbers" in this library are actually **mathematical compensations** for the Flutter/SMuFL coordinate difference. They're documented and proven!

---

## 🤝 Contributing

Contributions are welcome! Please read our [Contributing Guide](docs/contributing.md) for details.

When contributing, please:
- Read the **Technical Notes** section above
- Maintain mathematical precision in positioning
- Document any empirical values with explanations
- Test visual output against professional notation software

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

Developed with dedication by Alesson Lucas Oliveira de Queiroz
