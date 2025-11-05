// lib/core/tuplet.dart

import 'musical_element.dart';
import 'note.dart';

/// Razão de uma quiáltera
class TupletRatio {
  final int actualNotes;
  final int normalNotes;

  const TupletRatio(this.actualNotes, this.normalNotes);
}

/// Representa uma quiáltera (tercina, quintina, etc.)
class Tuplet extends MusicalElement {
  final int actualNotes;
  final int normalNotes;
  final List<MusicalElement> elements;
  final List<Note> notes;
  final bool showBracket;
  final bool showNumber;
  final TupletRatio ratio;
  final bool bracket;

  Tuplet({
    required this.actualNotes,
    required this.normalNotes,
    required this.elements,
    List<Note>? notes,
    this.showBracket = true,
    this.showNumber = true,
    TupletRatio? ratio,
    bool? bracket,
  }) : notes = notes ?? elements.whereType<Note>().toList(),
       ratio = ratio ?? TupletRatio(actualNotes, normalNotes),
       bracket = bracket ?? showBracket;
}
