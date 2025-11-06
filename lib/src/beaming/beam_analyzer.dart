// lib/src/beaming/beam_analyzer.dart

import 'dart:math';
import 'package:flutter_notemus/core/note.dart';
import 'package:flutter_notemus/core/time_signature.dart';
import 'package:flutter_notemus/core/duration.dart';
import 'package:flutter_notemus/src/beaming/beam_group.dart';
import 'package:flutter_notemus/src/beaming/beam_segment.dart';
import 'package:flutter_notemus/src/beaming/beam_types.dart';

/// Analisa grupos de notas e determina geometria e estrutura de beams
class BeamAnalyzer {
  final double staffSpace;
  final double noteheadWidth;

  BeamAnalyzer({
    required this.staffSpace,
    required this.noteheadWidth,
  });

  /// Analisa um grupo de notas e retorna AdvancedBeamGroup configurado
  AdvancedBeamGroup analyzeAdvancedBeamGroup(
    List<Note> notes,
    TimeSignature timeSignature, {
    Map<Note, double>? noteXPositions,
    Map<Note, int>? noteStaffPositions,
    Map<Note, double>? noteYPositions, // ✅ NOVO: Y absoluto em pixels
  }) {
    print('      🧪 [BeamAnalyzer] analyzeAdvancedBeamGroup INICIADO');
    print('         Notas: ${notes.length}');
    print('         noteXPositions disponível: ${noteXPositions != null}');
    print('         noteStaffPositions disponível: ${noteStaffPositions != null}');
    print('         noteYPositions disponível: ${noteYPositions != null}');
    
    if (notes.isEmpty) {
      throw ArgumentError('Beam group cannot be empty');
    }

    final group = AdvancedBeamGroup(notes: notes);
    print('         ✓ AdvancedBeamGroup criado');

    // Etapa 1: Determinar direção das hastes
    print('         🔄 Etapa 1: Calculando direção das hastes...');
    group.stemDirection = _calculateStemDirection(notes, noteStaffPositions);
    print('         ✓ Direção: ${group.stemDirection}');

    // Etapa 2: Calcular posições X
    print('         📐 Etapa 2: Calculando posições X...');
    _calculateXPositions(group, noteXPositions);
    print('         ✓ Posições X calculadas');

    // Etapa 3: Calcular geometria do primary beam
    print('         📏 Etapa 3: Calculando geometria do primary beam...');
    _calculatePrimaryBeamGeometry(group, noteStaffPositions, noteYPositions);
    print('         ✓ Primary beam: leftY=${group.leftY.toStringAsFixed(2)}, rightY=${group.rightY.toStringAsFixed(2)}, slope=${group.slope.toStringAsFixed(3)}');

    // Etapa 4: Analisar beams secundários
    print('         🔍 Etapa 4: Analisando beams secundários...');
    _analyzeSecondaryBeams(group, timeSignature, noteStaffPositions);
    print('         ✓ Beam segments: ${group.beamSegments.length}');
    
    print('      ✅ [BeamAnalyzer] analyzeAdvancedBeamGroup CONCLUÍDO');

    return group;
  }

  /// Determina direção das hastes baseado na nota mais distante da linha central
  /// ✅ CORREÇÃO P3: Linha central é sempre staffPosition = 0, independente da clave
  StemDirection _calculateStemDirection(
    List<Note> notes,
    Map<Note, int>? noteStaffPositions,
  ) {
    if (noteStaffPositions == null || noteStaffPositions.isEmpty) {
      return StemDirection.up; // Padrão
    }

    // ✅ CORREÇÃO P3: Linha central é sempre staffPosition = 0
    // (independente da clave - treble, bass, alto, etc.)
    const int centerLine = 0;

    // Encontrar nota mais distante da linha central
    Note? farthest;
    int maxDistance = 0;

    for (final note in notes) {
      final pos = noteStaffPositions[note];
      if (pos != null) {
        final distance = (pos - centerLine).abs();
        if (distance > maxDistance) {
          maxDistance = distance;
          farthest = note;
        }
      }
    }

    if (farthest == null) {
      return StemDirection.up;
    }

    final farthestPos = noteStaffPositions[farthest]!;

    // ✅ staffPosition > 0: acima do centro → hastes para baixo
    // ✅ staffPosition < 0: abaixo do centro → hastes para cima
    // ✅ staffPosition = 0: exatamente no centro → hastes para baixo (convenção)
    return farthestPos >= centerLine ? StemDirection.down : StemDirection.up;
  }

  /// Calcula posições X do início e fim do beam
  void _calculateXPositions(
    AdvancedBeamGroup group,
    Map<Note, double>? noteXPositions,
  ) {
    if (noteXPositions == null || noteXPositions.isEmpty) {
      // Espaçamento padrão
      group.leftX = 0;
      group.rightX = (group.notes.length - 1) * staffSpace * 2;
      return;
    }

    final firstNote = group.notes.first;
    final lastNote = group.notes.last;

    group.leftX = noteXPositions[firstNote] ?? 0;
    group.rightX = (noteXPositions[lastNote] ?? 0) + noteheadWidth;
  }

  /// Calcula geometria do primary beam (ângulo e posições Y)
  void _calculatePrimaryBeamGeometry(
    AdvancedBeamGroup group,
    Map<Note, int>? noteStaffPositions,
    Map<Note, double>? noteYPositions, // ✅ NOVO: Y absoluto em pixels
  ) {
    final firstNote = group.notes.first;
    final lastNote = group.notes.last;

    // ✅ PRIORIDADE 1: Usar Y absoluto se disponível
    if (noteYPositions != null && noteYPositions.isNotEmpty) {
      final firstNoteY = noteYPositions[firstNote];
      final lastNoteY = noteYPositions[lastNote];
      
      if (firstNoteY != null && lastNoteY != null) {
        // Calcular Y do beam baseado na posição real da nota
        final stemLength = 3.5 * staffSpace;
        
        if (group.stemDirection == StemDirection.up) {
          group.leftY = firstNoteY - stemLength;
          group.rightY = lastNoteY - stemLength;
        } else {
          group.leftY = firstNoteY + stemLength;
          group.rightY = lastNoteY + stemLength;
        }
        
        // slope é calculado automaticamente pelo getter
        print('         ✅ Usando Y ABSOLUTO! firstY=${firstNoteY.toStringAsFixed(2)}, lastY=${lastNoteY.toStringAsFixed(2)}');
        print('         beam leftY=${group.leftY.toStringAsFixed(2)}, rightY=${group.rightY.toStringAsFixed(2)}');
        return;
      }
    }

    // ✅ FALLBACK: Usar staff positions (sistema antigo)
    if (noteStaffPositions == null || noteStaffPositions.isEmpty) {
      // Posições padrão horizontais
      final y = staffSpace * 2.0;
      group.leftY = y;
      group.rightY = y;
      print('         ⚠️  FALLBACK: Usando posições padrão');
      return;
    }

    // ✅ CORREÇÃO P3: Fallback para 0 (linha central), não 6
    final firstPos = noteStaffPositions[firstNote] ?? 0;
    final lastPos = noteStaffPositions[lastNote] ?? 0;

    // Determinar se deve ser horizontal
    final shouldBeHorizontal = _shouldBeHorizontal(
      group.notes,
      noteStaffPositions,
    );

    if (shouldBeHorizontal) {
      // Beam horizontal
      final y = _calculateHorizontalBeamY(
        group.notes,
        noteStaffPositions,
        group.stemDirection,
      );
      group.leftY = y;
      group.rightY = y;
    } else {
      // Beam inclinado
      final slant = _calculateBeamSlant(
        firstPos,
        lastPos,
        group.notes.length,
        group.rightX - group.leftX,
      );

      // Calcular Y base para a primeira nota
      final baseY = _calculateBeamYForNote(
        firstPos,
        group.stemDirection,
      );

      if (firstPos < lastPos) {
        // Ascending
        group.leftY = baseY;
        group.rightY = baseY + slant * (group.stemDirection == StemDirection.up ? -1 : 1);
      } else {
        // Descending
        group.leftY = baseY;
        group.rightY = baseY - slant * (group.stemDirection == StemDirection.up ? -1 : 1);
      }
    }

    // Ajustar para snap às linhas da pauta
    group.leftY = _snapBeamToStaffLine(group.leftY, group.stemDirection);
    group.rightY = _snapBeamToStaffLine(group.rightY, group.stemDirection);
  }

  /// Determina se beam deve ser horizontal
  bool _shouldBeHorizontal(
    List<Note> notes,
    Map<Note, int> noteStaffPositions,
  ) {
    if (notes.length < 2) return true;

    final firstPos = noteStaffPositions[notes.first] ?? 0;
    final lastPos = noteStaffPositions[notes.last] ?? 0;

    // Mesma altura: horizontal
    if (firstPos == lastPos) return true;

    // Verificar se é côncavo/convexo (notas internas mais extremas)
    // Por simplicidade, vamos considerar apenas primeira e última
    return false;
  }

  /// Calcula Y para beam horizontal
  double _calculateHorizontalBeamY(
    List<Note> notes,
    Map<Note, int> noteStaffPositions,
    StemDirection stemDirection,
  ) {
    // ✅ CORREÇÃO P3: Fallback para 0 (linha central), não 6
    // Encontrar nota mais extrema
    int extremePos = noteStaffPositions[notes.first] ?? 0;

    for (final note in notes) {
      final pos = noteStaffPositions[note] ?? 0;
      if (stemDirection == StemDirection.up) {
        extremePos = min(extremePos, pos); // Mais baixa
      } else {
        extremePos = max(extremePos, pos); // Mais alta
      }
    }

    return _calculateBeamYForNote(extremePos, stemDirection);
  }

  /// Calcula posição Y do beam para uma nota específica
  double _calculateBeamYForNote(int staffPosition, StemDirection stemDirection) {
    // Comprimento padrão de haste: 3.5 staff spaces
    final stemLength = 3.5 * staffSpace;
    
    // Converter staff position para Y
    // Staff position 0 = linha inferior, valores pares = linhas, ímpares = espaços
    final noteY = staffPosition * (staffSpace / 2);

    if (stemDirection == StemDirection.up) {
      // Haste para cima: beam fica acima da nota
      return noteY - stemLength;
    } else {
      // Haste para baixo: beam fica abaixo da nota
      return noteY + stemLength;
    }
  }

  /// Calcula inclinação (slant) do beam
  /// ✅ CORREÇÃO P5: Cálculo correto da inclinação baseado em Elaine Gould
  double _calculateBeamSlant(
    int firstPos,
    int lastPos,
    int noteCount,
    double spacing,
  ) {
    // staffPosition já está em half staff spaces (cada unidade = 0.5 SS)
    // Converter diferença para pixels
    final intervalPixels = (lastPos - firstPos).abs() * (staffSpace / 2);

    double maxSlant;

    // Regra de Gould: limitar inclinação baseado no número de notas
    if (noteCount <= 3) {
      maxSlant = 0.5 * staffSpace;
    } else {
      maxSlant = 1.25 * staffSpace;
    }

    // ✅ CORREÇÃO P5: Usar uma proporção maior do intervalo
    // Proporção típica: 50-75% do intervalo real
    // Aqui usamos 0.5 para um slant moderado
    double slant = min(intervalPixels * 0.5, maxSlant);

    // Notas muito próximas: ângulo mínimo
    if (spacing < 3 * staffSpace) {
      slant = min(slant, 0.5 * staffSpace);
    }

    return slant;
  }

  /// Ajusta Y do beam para snap em linhas da pauta
  double _snapBeamToStaffLine(double rawY, StemDirection stemDirection) {
    final lineHeight = staffSpace;
    final nearestLine = (rawY / lineHeight).round();
    final lineY = nearestLine * lineHeight;

    // Pequena tolerância para centrar
    if ((rawY - lineY).abs() < staffSpace * 0.125) {
      return lineY; // Centrado
    }

    if (stemDirection == StemDirection.up) {
      // Beam pode pendurar ou centrar
      return lineY + (staffSpace * 0.5); // Pendurado
    } else {
      // Beam pode sentar ou centrar
      return lineY - (staffSpace * 0.5); // Sentado
    }
  }

  /// Analisa beams secundários e cria BeamSegments
  void _analyzeSecondaryBeams(
    AdvancedBeamGroup group,
    TimeSignature timeSignature,
    Map<Note, int>? noteStaffPositions,
  ) {
    // Primary beam: sempre completo
    group.beamSegments.add(BeamSegment(
      level: 1,
      startNoteIndex: 0,
      endNoteIndex: group.notes.length - 1,
      isFractional: false,
    ));

    // Determinar número máximo de beams necessários
    int maxLevel = 1;
    for (final note in group.notes) {
      final beamCount = _getBeamCount(note.duration);
      if (beamCount > maxLevel) {
        maxLevel = beamCount;
      }
    }

    // Analisar cada nível de beam secundário
    for (int level = 2; level <= maxLevel; level++) {
      _analyzeBeamLevel(group, level, timeSignature);
    }
  }

  /// Analisa um nível específico de beam
  void _analyzeBeamLevel(
    AdvancedBeamGroup group,
    int level,
    TimeSignature timeSignature,
  ) {
    int? segmentStart;

    for (int i = 0; i < group.notes.length; i++) {
      final note = group.notes[i];
      final noteBeams = _getBeamCount(note.duration);

      if (noteBeams >= level) {
        // Esta nota precisa deste nível de beam
        segmentStart ??= i;

        // Verificar se deve quebrar beam secundário
        final shouldBreak = _shouldBreakSecondaryBeam(
          group,
          i,
          level,
          timeSignature,
        );

        if (shouldBreak && segmentStart != i) {
          // Finalizar segmento anterior
          group.beamSegments.add(BeamSegment(
            level: level,
            startNoteIndex: segmentStart,
            endNoteIndex: i - 1,
            isFractional: false,
          ));
          segmentStart = i;
        }
      } else {
        // Esta nota não precisa deste nível
        if (segmentStart != null) {
          if (segmentStart == i - 1) {
            // Apenas uma nota: fractional beam
            group.beamSegments.add(_createFractionalBeam(
              group,
              segmentStart,
              i,
              level,
            ));
          } else {
            // Segmento normal
            group.beamSegments.add(BeamSegment(
              level: level,
              startNoteIndex: segmentStart,
              endNoteIndex: i - 1,
              isFractional: false,
            ));
          }
          segmentStart = null;
        }
      }
    }

    // Finalizar último segmento
    if (segmentStart != null) {
      if (segmentStart == group.notes.length - 1) {
        // Última nota sozinha: fractional beam à esquerda
        group.beamSegments.add(_createFractionalBeam(
          group,
          segmentStart,
          group.notes.length,
          level,
        ));
      } else {
        group.beamSegments.add(BeamSegment(
          level: level,
          startNoteIndex: segmentStart,
          endNoteIndex: group.notes.length - 1,
          isFractional: false,
        ));
      }
    }
  }

  /// Determina se deve quebrar beam secundário nesta posição
  bool _shouldBreakSecondaryBeam(
    AdvancedBeamGroup group,
    int noteIndex,
    int beamLevel,
    TimeSignature timeSignature,
  ) {
    if (noteIndex == 0) return false;

    // Implementar regra "dois níveis acima"
    int smallestBeams = 1;
    for (final note in group.notes) {
      final beams = _getBeamCount(note.duration);
      if (beams > smallestBeams) {
        smallestBeams = beams;
      }
    }

    final breakAtLevel = smallestBeams - 2;

    // Não quebrar beams de nível muito baixo
    if (beamLevel < breakAtLevel) {
      return false;
    }

    // Por simplicidade, quebrar a cada 2 notas em níveis altos
    // TODO: Implementar lógica mais sofisticada baseada em beat positions
    return noteIndex % 2 == 0 && beamLevel >= 2;
  }

  /// Cria fractional beam (broken beam/stub)
  BeamSegment _createFractionalBeam(
    AdvancedBeamGroup group,
    int noteIndex,
    int nextNoteIndex,
    int level,
  ) {
    // Determinar direção
    FractionalBeamSide side;

    if (noteIndex == 0) {
      side = FractionalBeamSide.right;
    } else if (nextNoteIndex >= group.notes.length) {
      side = FractionalBeamSide.left;
    } else {
      // No meio: verificar contexto (ritmo pontuado)
      final note = group.notes[noteIndex];
      final prevNote = group.notes[noteIndex - 1];

      if (_getDurationValue(note.duration) < _getDurationValue(prevNote.duration)) {
        side = FractionalBeamSide.right;
      } else {
        side = FractionalBeamSide.left;
      }
    }

    return BeamSegment(
      level: level,
      startNoteIndex: noteIndex,
      endNoteIndex: noteIndex,
      isFractional: true,
      fractionalSide: side,
      fractionalLength: noteheadWidth,
    );
  }

  /// Retorna número de beams para uma duração
  int _getBeamCount(Duration duration) {
    switch (duration.type) {
      case DurationType.eighth:
        return 1;
      case DurationType.sixteenth:
        return 2;
      case DurationType.thirtySecond:
        return 3;
      case DurationType.sixtyFourth:
        return 4;
      case DurationType.oneHundredTwentyEighth:
        return 5;
      default:
        return 0;
    }
  }

  /// Retorna valor numérico da duração (para comparação)
  double _getDurationValue(Duration duration) {
    switch (duration.type) {
      case DurationType.whole:
        return 1.0;
      case DurationType.half:
        return 0.5;
      case DurationType.quarter:
        return 0.25;
      case DurationType.eighth:
        return 0.125;
      case DurationType.sixteenth:
        return 0.0625;
      case DurationType.thirtySecond:
        return 0.03125;
      case DurationType.sixtyFourth:
        return 0.015625;
      case DurationType.oneHundredTwentyEighth:
        return 0.0078125;
      default:
        return 0.25;
    }
  }
}
