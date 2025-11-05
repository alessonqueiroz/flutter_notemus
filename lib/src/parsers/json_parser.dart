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

    final duration = Duration(_parseDurationType(durationJson['type'] ?? 'quarter'));

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
    final duration = Duration(_parseDurationType(durationJson['type'] ?? 'quarter'));
    return Rest(duration: duration);
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