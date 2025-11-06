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
- **Barlines**: Single, double, final, and repeat signs using SMuFL glyphs
- **Breath Marks**: Comma, tick, and caesura marks
- **Repeat Signs**: Forward (`:||`), backward (`||:`), and both-sided (`:||:`) ritornelos

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
- **Intelligent Layout Engine**:
  - Horizontal justification (stretches measures to fill available width)
  - Automatic line breaks every 4 measures
  - Staff line optimization (no empty space)
  - Professional measure spacing

### 📊 Format Support
- **JSON**: Import and export music data
- **Programmatic API**: Build music programmatically

---

## ✨ Recent Improvements (2025-11-05)

### 🎵 Professional Barlines with SMuFL Glyphs

All barlines now use **official SMuFL glyphs** from the Bravura font for perfect typographic accuracy:

- **Single barline** (`barlineSingle` U+E030)
- **Double barline** (`barlineDouble` U+E031)  
- **Final barline** (`barlineFinal` U+E032) - fina + grossa
- **Repeat forward** (`repeatLeft` U+E040) - `:║▌`
- **Repeat backward** (`repeatRight` U+E041) - `▌║:`
- **Repeat both** (`repeatLeftRight` U+E042) - `:▌▌:`

```dart
// Simple usage - barlines are automatic!
measure9.add(Barline(type: BarlineType.repeatForward));
measure16.add(Barline(type: BarlineType.final_));
```

### 📏 Horizontal Justification

Measures now **stretch proportionally** to fill available width, matching professional engraving standards:

```
BEFORE: [M1][M2][M3][M4]___________
                        ↑ wasted space

AFTER:  [ M1 ][ M2 ][ M3 ][ M4 ]
        ←──── full width ────→
```

Algorithm distributes extra space proportionally based on element positions.

### 🔄 Repeat Signs (Ritornelo)

Full support for musical repeat signs with perfect positioning:

```dart
// Start of repeated section
measure.add(Barline(type: BarlineType.repeatForward));

// End of repeated section  
measure.add(Barline(type: BarlineType.repeatBackward));
```

### 💨 Breath Marks

Respiratory marks for wind and vocal music:

```dart
// Add breath mark (comma)
measure.add(Breath(type: BreathType.comma));

// Positioned 2.5 staff spaces above the staff
```

Supported types:
- `comma` - Most common (`,`)
- `tick` - Alternative mark
- `caesura` - Double slash (`//`)

### ✂️ Optimized Staff Lines with Configurable Margins

Staff lines now **end exactly where music ends** with **smart detection** of barline types:

```
BEFORE: ═══════════════════════════════
        [music]      [empty space]

AFTER:  ═══════════╡
        [music]  ║▌
                 ↑ ends here!
```

**🎛️ Fine-tuning available** via adjustable constants in `StaffRenderer`:

```dart
// For NORMAL barlines (single, double, dashed, etc.)
static const double systemEndMargin = -12.0;

// For FINAL barline (BarlineType.final_)
static const double finalBarlineMargin = -1.5;
```

**How it works:**
- System **detects barline type** at the end of each staff system
- Applies `systemEndMargin` for normal barlines (`BarlineType.single`, `double`, etc.)
- Applies `finalBarlineMargin` for final barlines (`BarlineType.final_`)
- **Independent control** - adjust one without affecting the other!

**Why two different values?**
- Normal barlines are thinner → need more negative margin (`-12.0`)
- Final barlines are thicker → need less negative margin (`-1.5`)
- Result: Perfect visual alignment for all barline types ✅

### 🎯 Intelligent Line Breaking

Automatic line breaks every **4 measures** with proper barlines:

```
System 1: [M1][M2][M3][M4] |
System 2: [M5][M6][M7][M8] |
System 3: [M9][M10][M11][M12] |
System 4: [M13][M14][M15][M16] ║▌
```

### 🔬 Technical: Musical Coordinate System

**Important Discovery**: The musical coordinate system is **centered on staff line 3** (B4 in treble clef):

```
Line 1 ═══  Y = +2 SS (above center)
Line 2 ═══  Y = +1 SS
Line 3 ═══  Y = 0 (CENTER!)
Line 4 ═══  Y = -1 SS
Line 5 ═══  Y = -2 SS (below center)
```

**SMuFL Glyphs**:
- Have origin (0,0) at **baseline** (typographic convention)
- Use **specific anchors** from metadata.json (not geometric center)
- Follow OpenType standards with Y-axis growing upward
- Flutter's Y-axis is inverted (grows downward)

This explains why `barlineYOffset = -2.0` is correct:
- Positions baseline 2 staff spaces below center (line 5)
- Glyph height of 4.0 SS makes it reach line 1
- Perfect coverage of all 5 staff lines! ✅

See `BARLINE_CALIBRATION_GUIDE.md` for technical details.

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

## 📊 JSON Format Reference

### Complete JSON Structure

Flutter Notemus supports a **professional JSON format** for importing and exporting music notation. This format is compatible with the core music model and supports all musical elements.

#### 🎼 Basic Structure

```json
{
  "measures": [
    {
      "elements": [
        // Musical elements here
      ]
    }
  ]
}
```

---

### 📋 Valid Element Types

#### 1️⃣ **Clef** (`"type": "clef"`)

```json
{"type": "clef", "clefType": "treble"}
```

**Valid `clefType` values:**
- `"treble"` - Clave de Sol (G clef)
- `"bass"` - Clave de Fá (F clef)
- `"alto"` - Clave de Dó na 3ª linha (C clef on 3rd line)
- `"tenor"` - Clave de Dó na 4ª linha (C clef on 4th line)
- `"percussion"` - Clave de percussão
- `"tab6"` - Tablatura de 6 cordas
- `"tab4"` - Tablatura de 4 cordas

---

#### 2️⃣ **Key Signature** (`"type": "keySignature"`)

```json
{"type": "keySignature", "count": 2}
```

**`count` values:**
- **Positive numbers** = sustenidos (sharps): `1` a `7`
  - `1` = Sol Maior / Mi menor (G major / E minor)
  - `2` = Ré Maior / Si menor (D major / B minor)
  - `7` = Dó# Maior / Lá# menor (C# major / A# minor)
- **Negative numbers** = bemóis (flats): `-1` a `-7`
  - `-1` = Fá Maior / Ré menor (F major / D minor)
  - `-2` = Sib Maior / Sol menor (Bb major / G minor)
  - `-7` = Dób Maior / Láb menor (Cb major / Ab minor)
- **Zero** = `0` = Dó Maior / Lá menor (C major / A minor)

---

#### 3️⃣ **Time Signature** (`"type": "timeSignature"`)

```json
{"type": "timeSignature", "numerator": 4, "denominator": 4}
```

**Fields:**
- `"numerator"`: Número de tempos (beats per measure)
- `"denominator"`: Valor da unidade de tempo (note value that gets one beat)

**Common examples:**
- `4/4` - Compasso quaternário simples
- `3/4` - Compasso ternário (waltz)
- `6/8` - Compasso composto
- `2/2` - Alla breve

---

#### 4️⃣ **Note** (`"type": "note"`)

```json
{
  "type": "note",
  "pitch": {
    "step": "F",
    "octave": 5,
    "alter": 0.0
  },
  "duration": {
    "type": "quarter",
    "dots": 1
  }
}
```

**Pitch fields:**
- `"step"`: Nota diatônica (diatonic note name)
  - Valid: `"C"`, `"D"`, `"E"`, `"F"`, `"G"`, `"A"`, `"B"`
- `"octave"`: Oitava (octave number)
  - Valid: `0` a `9` (C4 = middle C / Dó central)
- `"alter"`: Alteração cromática (chromatic alteration)
  - `0.0` = natural
  - `1.0` = sustenido (sharp) #
  - `-1.0` = bemol (flat) ♭
  - `2.0` = dobrado sustenido (double sharp) 𝄪
  - `-2.0` = dobrado bemol (double flat) 𝄫

**Duration fields:**
- `"type"`: Tipo de duração (duration type)
  - Valid: `"whole"`, `"half"`, `"quarter"`, `"eighth"`, `"sixteenth"`, `"thirtySecond"`, `"sixtyFourth"`
- `"dots"`: Pontos de aumento (augmentation dots) - **OPTIONAL**
  - `0` = sem ponto (no dot)
  - `1` = um ponto (single dot) - aumenta 50%
  - `2` = dois pontos (double dot) - aumenta 75%

**Examples:**

Semínima pontuada (Dotted quarter note):
```json
{
  "type": "note",
  "pitch": {"step": "E", "octave": 5, "alter": 0.0},
  "duration": {"type": "quarter", "dots": 1}
}
```

Colcheia (Eighth note):
```json
{
  "type": "note",
  "pitch": {"step": "D", "octave": 5, "alter": 0.0},
  "duration": {"type": "eighth"}
}
```

---

#### 5️⃣ **Rest** (`"type": "rest"`)

```json
{
  "type": "rest",
  "duration": {
    "type": "quarter",
    "dots": 0
  }
}
```

**Same duration fields as notes.**

---

#### 6️⃣ **Barline** (`"type": "barline"`)

```json
{"type": "barline", "barlineType": "final_"}
```

**Valid `barlineType` values:**
- `"single"` - Barra simples (single barline) `|`
- `"double"` - Barra dupla (double barline) `||`
- `"final_"` - Barra final dupla (final double barline) `||` (thick)
- `"heavy"` - Barra grossa (heavy barline)
- `"repeatForward"` - Ritornelo à frente (repeat forward) `:||`
- `"repeatBackward"` - Ritornelo atrás (repeat backward) `||:`
- `"repeatBoth"` - Ritornelo ambos lados (repeat both) `:||:`
- `"dashed"` - Barra tracejada (dashed barline)
- `"tick"` - Tick barline
- `"short_"` - Barra curta (short barline)
- `"none"` - Sem barra (invisible barline)

**⚠️ IMPORTANT:** Barlines são **OPCIONAIS** no JSON!
- Se você **NÃO incluir** barlines, elas são adicionadas **automaticamente** entre compassos
- Se você **INCLUIR** uma barline explícita no JSON, o sistema **respeita** e não duplica
- **Recomendação:** Adicione apenas a **barra final** (`"final_"`) no último compasso

---

#### 7️⃣ **Dynamic** (`"type": "dynamic"`)

```json
{"type": "dynamic", "dynamicType": "forte"}
```

**Valid `dynamicType` values:**
- **Básicas:** `"pp"`, `"p"`, `"mp"`, `"mf"`, `"f"`, `"ff"`
- **Completas:** `"pianissimo"`, `"piano"`, `"mezzoPiano"`, `"mezzoForte"`, `"forte"`, `"fortissimo"`
- **Especiais:** `"sforzando"`, `"crescendo"`, `"diminuendo"`

**Com hairpin (crescendo/diminuendo):**
```json
{
  "type": "dynamic",
  "dynamicType": "crescendo",
  "isHairpin": true,
  "length": 120.0
}
```

---

#### 8️⃣ **Tempo** (`"type": "tempo"`)

```json
{
  "type": "tempo",
  "text": "Allegro",
  "beatUnit": "quarter",
  "bpm": 120
}
```

**Fields:**
- `"text"`: Texto descritivo (ex: "Allegro", "Andante")
- `"beatUnit"`: Unidade de tempo (same as duration types)
- `"bpm"`: Batidas por minuto (opcional)

---

#### 9️⃣ **Breath Mark** (`"type": "breath"`)

```json
{"type": "breath", "breathType": "comma"}
```

**Valid `breathType` values:**
- `"comma"` - Vírgula de respiração (,)
- `"tick"` - Tick mark (')
- `"upbow"` - Arco para cima
- `"caesura"` - Cesura (//)

---

#### 🔟 **Caesura** (`"type": "caesura"`)

```json
{"type": "caesura"}
```

Marca de pausa longa entre frases (//). Similar a breath, mas mais enfático.

---

#### 1️⃣1️⃣ **Chord** (`"type": "chord"`)

```json
{
  "type": "chord",
  "notes": [
    {"step": "C", "octave": 4, "alter": 0.0},
    {"step": "E", "octave": 4, "alter": 0.0},
    {"step": "G", "octave": 4, "alter": 0.0}
  ],
  "duration": {"type": "quarter", "dots": 0},
  "articulations": ["staccato", "accent"]
}
```

**Fields:**
- `"notes"`: Array de pitches (notes sem duration individual)
- `"duration"`: Duration aplicada a todas as notas
- `"articulations"`: Array opcional de articulações

**Valid articulations:**
- `"staccato"`, `"accent"`, `"tenuto"`, `"marcato"`

---

#### 1️⃣2️⃣ **Text** (`"type": "text"`)

```json
{
  "type": "text",
  "text": "dolce",
  "textType": "expression",
  "placement": "above",
  "fontSize": 12.0
}
```

**Valid `textType` values:**
- `"expression"` - Expressões musicais (dolce, espressivo)
- `"instruction"` - Instruções técnicas (pizz., arco)
- `"lyrics"` - Letra da música
- `"rehearsal"` - Marcas de ensaio (A, B, C)
- `"chord"` - Cifras (C, Am, G7)
- `"tempo"` - Indicações de andamento
- `"title"`, `"subtitle"`, `"composer"` - Metadados

**Valid `placement` values:**
- `"above"` - Acima da pauta
- `"below"` - Abaixo da pauta
- `"inside"` - Dentro da pauta

---

### 📄 Complete Example: Ode à Alegria (8 compassos)

```json
{
  "measures": [
    {
      "elements": [
        {"type": "clef", "clefType": "treble"},
        {"type": "keySignature", "count": 2},
        {"type": "timeSignature", "numerator": 4, "denominator": 4},
        {"type": "note", "pitch": {"step": "F", "octave": 5, "alter": 0.0}, "duration": {"type": "quarter"}},
        {"type": "note", "pitch": {"step": "F", "octave": 5, "alter": 0.0}, "duration": {"type": "quarter"}},
        {"type": "note", "pitch": {"step": "G", "octave": 5, "alter": 0.0}, "duration": {"type": "quarter"}},
        {"type": "note", "pitch": {"step": "A", "octave": 5, "alter": 0.0}, "duration": {"type": "quarter"}}
      ]
    },
    {
      "elements": [
        {"type": "note", "pitch": {"step": "A", "octave": 5, "alter": 0.0}, "duration": {"type": "quarter"}},
        {"type": "note", "pitch": {"step": "G", "octave": 5, "alter": 0.0}, "duration": {"type": "quarter"}},
        {"type": "note", "pitch": {"step": "F", "octave": 5, "alter": 0.0}, "duration": {"type": "quarter"}},
        {"type": "note", "pitch": {"step": "E", "octave": 5, "alter": 0.0}, "duration": {"type": "quarter"}}
      ]
    },
    {
      "elements": [
        {"type": "note", "pitch": {"step": "E", "octave": 5, "alter": 0.0}, "duration": {"type": "quarter", "dots": 1}},
        {"type": "note", "pitch": {"step": "D", "octave": 5, "alter": 0.0}, "duration": {"type": "eighth"}},
        {"type": "note", "pitch": {"step": "D", "octave": 5, "alter": 0.0}, "duration": {"type": "half"}},
        {"type": "barline", "barlineType": "final_"}
      ]
    }
  ]
}
```

---

### 💻 Usage in Code

```dart
import 'package:flutter_notemus/src/parsers/json_parser.dart';

// Parse JSON string to Staff
final jsonString = '{"measures": [...]}';
final staff = JsonMusicParser.parseStaff(jsonString);

// Render
MusicScore(
  staff: staff,
  theme: MusicScoreTheme(
    noteheadColor: Colors.black,
    stemColor: Colors.black,
    staffLineColor: Colors.black87,
    barlineColor: Colors.black,
  ),
  staffSpace: 14.0,
)
```

---

### ✅ JSON Validation Rules

1. **Measure Capacity:** O total de durações das notas não pode exceder a capacidade do compasso definida pela fórmula de compasso.
   - Exemplo: Em 4/4, o total deve ser ≤ 1.0 (4 semínimas)

2. **Required Fields:**
   - Cada elemento deve ter `"type"`
   - Notes requerem `"pitch"` e `"duration"`
   - Pitch requer `"step"` e `"octave"`
   - Duration requer `"type"`

3. **Optional Fields:**
   - `"dots"` na duration (padrão: 0)
   - `"alter"` no pitch (padrão: 0.0)

4. **Automatic Features:**
   - Barlines automáticas entre compassos
   - Barra final dupla no último compasso (se não especificada)
   - Layout inteligente com quebras de linha

---

### 🔗 Related Documentation

- Ver também: `PARSERS_GUIDE.md` para exemplos avançados
- Exemplo completo: `example/professional_json_example.dart`

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

## ⚙️ Advanced Customization

### Staff Line Margins

If you need to fine-tune where staff lines end in relation to barlines, you can adjust the constants in `lib/src/rendering/staff_renderer.dart`:

```dart
class StaffRenderer {
  // 🎚️ MANUAL ADJUSTMENT CONSTANTS
  
  // Margin after NORMAL barlines (single, double, dashed, etc.)
  // Negative values move lines closer to the barline
  // -12.0 = Lines end exactly at normal barlines ✅
  static const double systemEndMargin = -12.0;
  
  // Margin after FINAL barline (BarlineType.final_)
  // -1.5 = Lines end exactly at final barline ✅
  static const double finalBarlineMargin = -1.5;
}
```

**When to adjust:**
- Different font sizes may require different values
- Custom barline implementations
- Specific visual preferences

**How to test:**
1. Modify the constant values
2. Run `flutter run` with hot reload
3. Visually inspect barline alignment
4. Adjust incrementally (0.5 pixel steps recommended)

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
- ✅ **Horizontal justification** (proportional spacing)
- ✅ **Barlines with SMuFL glyphs** (all types)
- ✅ **Repeat signs** (ritornelo forward/backward/both)
- ✅ **Breath marks** (comma, tick, caesura)
- ✅ **Optimized staff lines** (no empty space)
- ✅ **Configurable staff line margins** (type-aware: normal vs final barlines)
- ✅ **Intelligent line breaking** (4 measures per system)
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

1. **Understand the coordinate system** - The musical staff is **centered on line 3** (Y=0)
2. **SMuFL baseline vs geometric center** - Glyphs use **baseline** (0,0 at bottom-left), not center!
3. **Check metadata.json** - Use SMuFL **anchors** for precise positioning
4. **Account for Y-axis inversion** - Flutter (↓) vs OpenType (↑)
5. **Test with multiple staff positions** - Verify alignment on lines AND spaces
6. **Document empirical values** - Explain mathematically, not just "it works"
7. **Refer to technical guides**:
   - `SOLUCAO_FINAL_PONTOS.md` - Dot positioning case study
   - `BARLINE_CALIBRATION_GUIDE.md` - Barline positioning
   - `VISUAL_ADJUSTMENTS_FINAL.md` - Stem/flag alignment

**Key principles:**
- Musical coordinate system: **line 3 = Y:0** (center)
- SMuFL glyphs: **baseline = (0,0)** (typographic)
- All "magic numbers" are **mathematical compensations** - document them!
- Always verify against professional notation software (Finale, Sibelius, Dorico)
- **Staff line margins** are type-aware:
  - `systemEndMargin` for normal barlines (thinner)
  - `finalBarlineMargin` for final barlines (thicker)
  - System detects barline type automatically (`BarlineType.final_` vs others)

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
- Technical insights:
  - OpenType specification
  - SMuFL metadata.json anchors
  - ChatGPT for baseline/coordinate system clarification

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
