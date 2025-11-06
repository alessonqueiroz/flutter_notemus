// lib/src/parsers/json_parser.dart

import 'dart:convert';
import '../../core/core.dart'; // Tipos do core

/// Parser para converter JSON em objetos musicais
class JsonMusicParser {

  /// Converte um JSON de partitura para um objeto Staff
  static Staff parseStaff(String jsonString) {
    final Map<String, dynamic> json = jsonDecode(jsonString);
    return _parseStaffFromMap(json);
  }

  static Staff _parseStaffFromMap(Map<String, dynamic> json) {
    final staff = Staff();

    if (json['measures'] != null) {
      for (final measureJson in json['measures']) {
        final measure = _parseMeasureFromMap(measureJson);
        staff.add(measure);
      }
    }

    return staff;
  }

  static Measure _parseMeasureFromMap(Map<String, dynamic> json) {
    final measure = Measure();

    if (json['elements'] != null) {
      for (final elementJson in json['elements']) {
        final element = _parseElementFromMap(elementJson);
        if (element != null) {
          measure.add(element);
        }
      }
    }

    return measure;
  }

  static MusicalElement? _parseElementFromMap(Map<String, dynamic> json) {
    final String type = json['type'] ?? '';

    switch (type) {
      case 'clef':
        return Clef(type: json['clefType'] ?? 'g');

      case 'keySignature':
        return KeySignature(json['count'] ?? 0);

      case 'timeSignature':
        return TimeSignature(
          numerator: json['numerator'] ?? 4,
          denominator: json['denominator'] ?? 4,
        );

      case 'note':
        return _parseNoteFromMap(json);

      case 'rest':
        return _parseRestFromMap(json);

      case 'barline':
        return _parseBarlineFromMap(json);

      case 'dynamic':
        return _parseDynamicFromMap(json);

      case 'tempo':
        return _parseTempoFromMap(json);

      case 'breath':
        return _parseBreathFromMap(json);

      case 'caesura':
        return Caesura(type: _parseBreathType(json['breathType'] ?? 'caesura'));

      case 'chord':
        return _parseChordFromMap(json);

      case 'text':
        return _parseTextFromMap(json);

      default:
        return null;
    }
  }

  static Note _parseNoteFromMap(Map<String, dynamic> json) {
    final pitchJson = json['pitch'] ?? {};
    final durationJson = json['duration'] ?? {};

    final pitch = Pitch(
      step: pitchJson['step'] ?? 'C',
      octave: pitchJson['octave'] ?? 4,
      alter: pitchJson['alter']?.toDouble() ?? 0.0,
    );

    final duration = Duration(
      _parseDurationType(durationJson['type'] ?? 'quarter'),
      dots: durationJson['dots'] ?? 0,
    );

    // Parse opcional de articulações
    List<ArticulationType> articulations = [];
    if (json['articulations'] != null) {
      for (final articulation in json['articulations']) {
        switch (articulation) {
          case 'staccato':
            articulations.add(ArticulationType.staccato);
            break;
          case 'accent':
            articulations.add(ArticulationType.accent);
            break;
          case 'tenuto':
            articulations.add(ArticulationType.tenuto);
            break;
        }
      }
    }

    // Parse opcional de tie e slur
    TieType? tie;
    if (json['tie'] != null) {
      tie = json['tie'] == 'start' ? TieType.start : TieType.end;
    }

    SlurType? slur;
    if (json['slur'] != null) {
      slur = json['slur'] == 'start' ? SlurType.start : SlurType.end;
    }

    return Note(
      pitch: pitch,
      duration: duration,
      articulations: articulations,
      tie: tie,
      slur: slur,
    );
  }

  static Rest _parseRestFromMap(Map<String, dynamic> json) {
    final durationJson = json['duration'] ?? {};
    final duration = Duration(
      _parseDurationType(durationJson['type'] ?? 'quarter'),
      dots: durationJson['dots'] ?? 0,
    );
    return Rest(duration: duration);
  }

  static Barline _parseBarlineFromMap(Map<String, dynamic> json) {
    final String barlineTypeString = json['barlineType'] ?? 'single';
    final BarlineType barlineType = _parseBarlineType(barlineTypeString);
    return Barline(type: barlineType);
  }

  static BarlineType _parseBarlineType(String type) {
    switch (type) {
      case 'single':
        return BarlineType.single;
      case 'double':
        return BarlineType.double;
      case 'final_':
        return BarlineType.final_;
      case 'heavy':
        return BarlineType.heavy;
      case 'repeatForward':
        return BarlineType.repeatForward;
      case 'repeatBackward':
        return BarlineType.repeatBackward;
      case 'repeatBoth':
        return BarlineType.repeatBoth;
      case 'dashed':
        return BarlineType.dashed;
      case 'tick':
        return BarlineType.tick;
      case 'short_':
        return BarlineType.short_;
      case 'lightLight':
        return BarlineType.lightLight;
      case 'lightHeavy':
        return BarlineType.lightHeavy;
      case 'heavyLight':
        return BarlineType.heavyLight;
      case 'heavyHeavy':
        return BarlineType.heavyHeavy;
      case 'none':
        return BarlineType.none;
      default:
        return BarlineType.single;
    }
  }

  static DurationType _parseDurationType(String type) {
    switch (type) {
      case 'whole':
        return DurationType.whole;
      case 'half':
        return DurationType.half;
      case 'quarter':
        return DurationType.quarter;
      case 'eighth':
        return DurationType.eighth;
      case 'sixteenth':
        return DurationType.sixteenth;
      default:
        return DurationType.quarter;
    }
  }

  // === PARSERS PARA ELEMENTOS ADICIONAIS ===

  static Dynamic _parseDynamicFromMap(Map<String, dynamic> json) {
    final String dynamicTypeString = json['dynamicType'] ?? 'mezzoForte';
    final DynamicType dynamicType = _parseDynamicType(dynamicTypeString);
    
    return Dynamic(
      type: dynamicType,
      customText: json['customText'],
      isHairpin: json['isHairpin'] ?? false,
      length: (json['length'] ?? 0.0).toDouble(),
    );
  }

  static DynamicType _parseDynamicType(String type) {
    switch (type) {
      case 'pianissimo': return DynamicType.pianissimo;
      case 'piano': return DynamicType.piano;
      case 'mezzoPiano': return DynamicType.mezzoPiano;
      case 'mezzoForte': return DynamicType.mezzoForte;
      case 'forte': return DynamicType.forte;
      case 'fortissimo': return DynamicType.fortissimo;
      case 'sforzando': return DynamicType.sforzando;
      case 'crescendo': return DynamicType.crescendo;
      case 'diminuendo': return DynamicType.diminuendo;
      case 'pp': return DynamicType.pp;
      case 'p': return DynamicType.p;
      case 'mp': return DynamicType.mp;
      case 'mf': return DynamicType.mf;
      case 'f': return DynamicType.f;
      case 'ff': return DynamicType.ff;
      default: return DynamicType.mezzoForte;
    }
  }

  static TempoMark _parseTempoFromMap(Map<String, dynamic> json) {
    return TempoMark(
      text: json['text'],
      beatUnit: _parseDurationType(json['beatUnit'] ?? 'quarter'),
      bpm: json['bpm'],
    );
  }

  static Breath _parseBreathFromMap(Map<String, dynamic> json) {
    final String breathTypeString = json['breathType'] ?? 'comma';
    return Breath(type: _parseBreathType(breathTypeString));
  }

  static BreathType _parseBreathType(String type) {
    switch (type) {
      case 'comma': return BreathType.comma;
      case 'tick': return BreathType.tick;
      case 'upbow': return BreathType.upbow;
      case 'caesura': return BreathType.caesura;
      default: return BreathType.comma;
    }
  }

  static Chord _parseChordFromMap(Map<String, dynamic> json) {
    final durationJson = json['duration'] ?? {};
    final duration = Duration(
      _parseDurationType(durationJson['type'] ?? 'quarter'),
      dots: durationJson['dots'] ?? 0,
    );

    final List<Note> notes = [];
    if (json['notes'] != null) {
      for (final noteJson in json['notes']) {
        final pitch = Pitch(
          step: noteJson['step'] ?? 'C',
          octave: noteJson['octave'] ?? 4,
          alter: noteJson['alter']?.toDouble() ?? 0.0,
        );
        notes.add(Note(pitch: pitch, duration: duration));
      }
    }

    // Parse articulations
    List<ArticulationType> articulations = [];
    if (json['articulations'] != null) {
      for (final articulation in json['articulations']) {
        switch (articulation) {
          case 'staccato':
            articulations.add(ArticulationType.staccato);
            break;
          case 'accent':
            articulations.add(ArticulationType.accent);
            break;
          case 'tenuto':
            articulations.add(ArticulationType.tenuto);
            break;
          case 'marcato':
            articulations.add(ArticulationType.marcato);
            break;
        }
      }
    }

    return Chord(
      notes: notes,
      duration: duration,
      articulations: articulations,
    );
  }

  static MusicText _parseTextFromMap(Map<String, dynamic> json) {
    final String textTypeString = json['textType'] ?? 'expression';
    final TextType textType = _parseTextType(textTypeString);
    
    final String placementString = json['placement'] ?? 'above';
    final TextPlacement placement = _parseTextPlacement(placementString);

    return MusicText(
      text: json['text'] ?? '',
      type: textType,
      placement: placement,
      fontSize: (json['fontSize'] ?? 12.0).toDouble(),
    );
  }

  static TextType _parseTextType(String type) {
    switch (type) {
      case 'expression': return TextType.expression;
      case 'instruction': return TextType.instruction;
      case 'lyrics': return TextType.lyrics;
      case 'rehearsal': return TextType.rehearsal;
      case 'chord': return TextType.chord;
      case 'tempo': return TextType.tempo;
      case 'dynamics': return TextType.dynamics;
      case 'title': return TextType.title;
      case 'subtitle': return TextType.subtitle;
      case 'composer': return TextType.composer;
      default: return TextType.expression;
    }
  }

  static TextPlacement _parseTextPlacement(String placement) {
    switch (placement) {
      case 'above': return TextPlacement.above;
      case 'below': return TextPlacement.below;
      case 'inside': return TextPlacement.inside;
      default: return TextPlacement.above;
    }
  }

  /// Converte um Staff para JSON
  static String staffToJson(Staff staff) {
    final Map<String, dynamic> json = {
      'measures': staff.measures.map((measure) => _measureToMap(measure)).toList(),
    };
    return jsonEncode(json);
  }

  static Map<String, dynamic> _measureToMap(Measure measure) {
    return {
      'elements': measure.elements.map((element) => _elementToMap(element)).toList(),
    };
  }

  static Map<String, dynamic> _elementToMap(MusicalElement element) {
    if (element is Clef) {
      return {'type': 'clef', 'clefType': element.actualClefType.name};
    } else if (element is KeySignature) {
      return {'type': 'keySignature', 'count': element.count};
    } else if (element is TimeSignature) {
      return {
        'type': 'timeSignature',
        'numerator': element.numerator,
        'denominator': element.denominator,
      };
    } else if (element is Note) {
      return _noteToMap(element);
    } else if (element is Rest) {
      return _restToMap(element);
    }
    return {'type': 'unknown'};
  }

  static Map<String, dynamic> _noteToMap(Note note) {
    return {
      'type': 'note',
      'pitch': {
        'step': note.pitch.step,
        'octave': note.pitch.octave,
        'alter': note.pitch.alter,
      },
      'duration': {
        'type': _durationTypeToString(note.duration.type),
      },
      'articulations': note.articulations.map((a) => _articulationToString(a)).toList(),
      if (note.tie != null) 'tie': note.tie == TieType.start ? 'start' : 'end',
      if (note.slur != null) 'slur': note.slur == SlurType.start ? 'start' : 'end',
    };
  }

  static Map<String, dynamic> _restToMap(Rest rest) {
    return {
      'type': 'rest',
      'duration': {
        'type': _durationTypeToString(rest.duration.type),
      },
    };
  }

  static String _durationTypeToString(DurationType type) {
    switch (type) {
      case DurationType.whole:
        return 'whole';
      case DurationType.half:
        return 'half';
      case DurationType.quarter:
        return 'quarter';
      case DurationType.eighth:
        return 'eighth';
      case DurationType.sixteenth:
        return 'sixteenth';
      case DurationType.thirtySecond:
        return 'thirtySecond';
      case DurationType.sixtyFourth:
        return 'sixtyFourth';
      case DurationType.oneHundredTwentyEighth:
        return 'oneHundredTwentyEighth';
    }
  }

  static String _articulationToString(ArticulationType type) {
    switch (type) {
      case ArticulationType.staccato:
        return 'staccato';
      case ArticulationType.staccatissimo:
        return 'staccatissimo';
      case ArticulationType.accent:
        return 'accent';
      case ArticulationType.strongAccent:
        return 'strongAccent';
      case ArticulationType.tenuto:
        return 'tenuto';
      case ArticulationType.marcato:
        return 'marcato';
      case ArticulationType.legato:
        return 'legato';
      case ArticulationType.portato:
        return 'portato';
      case ArticulationType.upBow:
        return 'upBow';
      case ArticulationType.downBow:
        return 'downBow';
      case ArticulationType.harmonics:
        return 'harmonics';
      case ArticulationType.pizzicato:
        return 'pizzicato';
      case ArticulationType.snap:
        return 'snap';
      case ArticulationType.thumb:
        return 'thumb';
      case ArticulationType.stopped:
        return 'stopped';
      case ArticulationType.open:
        return 'open';
      case ArticulationType.halfStopped:
        return 'halfStopped';
    }
  }
}