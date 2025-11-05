// lib/core/measure.dart

import 'musical_element.dart';
import 'note.dart';
import 'rest.dart';
import 'time_signature.dart';
import 'duration.dart';

/// Representa um compasso, que contém elementos musicais.
class Measure {
  final List<MusicalElement> elements = [];

  /// Controla se as notas devem ser automaticamente agrupadas com beams
  /// true = auto-beaming ativo (padrão)
  /// false = usar bandeirolas individuais (flags)
  bool autoBeaming;

  /// Estratégia específica de beaming para casos especiais
  BeamingMode beamingMode;

  /// Grupos manuais de beams - lista de listas de índices de notas a serem agrupadas
  /// Exemplo: [[0, 1, 2], [3, 4]] = agrupa notas 0,1,2 em um beam e 3,4 em outro
  List<List<int>> manualBeamGroups;

  Measure({
    this.autoBeaming = true,
    this.beamingMode = BeamingMode.automatic,
    this.manualBeamGroups = const [],
  });

  void add(MusicalElement element) => elements.add(element);

  /// Calcula o valor total atual das figuras musicais no compasso.
  double get currentMusicalValue {
    double total = 0.0;
    for (final element in elements) {
      if (element is Note) {
        total += element.duration.realValue;
      } else if (element is Rest) {
        total += element.duration.realValue;
      } else if (element.runtimeType.toString() == 'Chord') {
        // Usar reflexão para evitar import circular
        final dynamic chord = element;
        if (chord.duration != null) {
          total += chord.duration.realValue;
        }
      } else if (element.runtimeType.toString() == 'Tuplet') {
        // Calcular valor da quiáltera baseado na razão
        final dynamic tuplet = element;
        double tupletValue = 0.0;

        // Somar duração de todas as notas da quiáltera
        for (final tupletElement in tuplet.elements) {
          if (tupletElement is Note) {
            tupletValue += tupletElement.duration.realValue;
          } else if (tupletElement.runtimeType.toString() == 'Chord') {
            final dynamic chord = tupletElement;
            if (chord.duration != null) {
              tupletValue += chord.duration.realValue;
            }
          }
        }

        // Aplicar a razão da quiáltera (normalNotes / actualNotes)
        if (tuplet.actualNotes > 0) {
          tupletValue = tupletValue * (tuplet.normalNotes / tuplet.actualNotes);
        }

        total += tupletValue;
      }
    }
    return total;
  }

  /// Obtém a fórmula de compasso ativa neste compasso.
  TimeSignature? get timeSignature {
    for (final element in elements) {
      if (element is TimeSignature) {
        return element;
      }
    }
    return null;
  }

  /// Verifica se o compasso está corretamente preenchido.
  bool get isValidlyFilled {
    final ts = timeSignature;
    if (ts == null) return true; // Sem fórmula = sem validação
    return currentMusicalValue == ts.measureValue;
  }

  /// Verifica se ainda há espaço para adicionar uma duração específica.
  bool canAddDuration(Duration duration) {
    final ts = timeSignature;
    if (ts == null) return true; // Sem fórmula = sempre pode adicionar
    return currentMusicalValue + duration.realValue <= ts.measureValue;
  }

  /// Calcula quanto tempo ainda resta no compasso.
  double get remainingValue {
    final ts = timeSignature;
    if (ts == null) return double.infinity;
    return ts.measureValue - currentMusicalValue;
  }
}
