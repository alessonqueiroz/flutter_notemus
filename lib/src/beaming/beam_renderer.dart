// lib/src/beaming/beam_renderer.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_notemus/src/beaming/beam_group.dart';
import 'package:flutter_notemus/src/beaming/beam_segment.dart';
import 'package:flutter_notemus/src/beaming/beam_types.dart';
import 'package:flutter_notemus/src/theme/music_score_theme.dart';

/// Renderiza beams (ligaduras de colcheia) geometricamente
class BeamRenderer {
  final MusicScoreTheme theme;
  final double staffSpace;
  final double noteheadWidth;

  // Métricas SMuFL
  late final double beamThickness;
  late final double beamGap;
  late final double stemThickness;

  BeamRenderer({
    required this.theme,
    required this.staffSpace,
    required this.noteheadWidth,
  }) {
    // SMuFL specifications
    beamThickness = 0.5 * staffSpace;
    beamGap = 0.25 * staffSpace;
    stemThickness = 0.12 * staffSpace;
  }

  /// Renderiza um beam group completo (apenas hastes e beams)
  /// Noteheads são renderizados pelo NoteRenderer
  void renderAdvancedBeamGroup(
    Canvas canvas,
    AdvancedBeamGroup group, {
    Map<dynamic, double>? noteYPositions,
  }) {
    print('      🎨 [BeamRenderer] renderAdvancedBeamGroup INICIADO');
    print('         leftX: ${group.leftX.toStringAsFixed(2)}, rightX: ${group.rightX.toStringAsFixed(2)}');
    print('         leftY: ${group.leftY.toStringAsFixed(2)}, rightY: ${group.rightY.toStringAsFixed(2)}');
    print('         stemDirection: ${group.stemDirection}');
    print('         beamSegments: ${group.beamSegments.length}');
    print('         noteYPositions disponível: ${noteYPositions != null && noteYPositions.isNotEmpty}');

    final paint = Paint()
      ..color = theme.beamColor ?? theme.stemColor
      ..style = PaintingStyle.fill;

    // 1. Renderizar hastes
    print('         🔹 Renderizando hastes...');
    _renderStems(canvas, group, paint, noteYPositions);

    // 2. Renderizar todos os segmentos de beam
    print('         🔹 Renderizando ${group.beamSegments.length} beam segments...');
    for (final segment in group.beamSegments) {
      _renderBeamSegment(canvas, group, segment, paint);
    }
    print('      ✅ [BeamRenderer] renderAdvancedBeamGroup CONCLUÍDO');
  }

  /// Renderiza as hastes do grupo
  void _renderStems(
    Canvas canvas,
    AdvancedBeamGroup group,
    Paint paint,
    Map<dynamic, double>? noteYPositions,
  ) {
    final stemPaint = Paint()
      ..color = theme.stemColor
      ..strokeWidth = stemThickness
      ..strokeCap = StrokeCap.butt
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < group.notes.length; i++) {
      final note = group.notes[i];

      // Calcular posição X da haste (centro da nota)
      final noteX = _getNoteX(group, i);
      final stemX = noteX + (noteheadWidth / 2);

      // ✅ CORREÇÃO P1: Usar posição Y real da nota do layout
      final noteY = noteYPositions?[note] ?? _estimateNoteY(note, group);

      // Calcular posição Y do fim da haste (onde encontra o beam)
      final beamY = group.interpolateBeamY(stemX);

      // Ajustar início da haste para sair corretamente da cabeça da nota
      double stemStartY;
      if (group.stemDirection == StemDirection.up) {
        stemStartY = noteY - (staffSpace * 0.25); // Sair do topo da cabeça
      } else {
        stemStartY = noteY + (staffSpace * 0.25); // Sair da base da cabeça
      }

      // Desenhar haste
      canvas.drawLine(
        Offset(stemX, stemStartY),
        Offset(stemX, beamY),
        stemPaint,
      );
    }
  }

  /// Renderiza um segmento de beam
  void _renderBeamSegment(
    Canvas canvas,
    AdvancedBeamGroup group,
    BeamSegment segment,
    Paint paint,
  ) {
    // Calcular offset vertical para este nível de beam
    final levelOffset = _calculateLevelOffset(segment.level, group.stemDirection);

    if (segment.isFractional) {
      _renderFractionalBeam(canvas, group, segment, paint, levelOffset);
    } else {
      _renderFullBeam(canvas, group, segment, paint, levelOffset);
    }
  }

  /// Calcula offset Y para um nível de beam
  double _calculateLevelOffset(int level, StemDirection stemDirection) {
    final offset = (level - 1) * (beamThickness + beamGap);
    
    // Inverter direção para hastes para baixo
    return stemDirection == StemDirection.down ? -offset : offset;
  }

  /// Renderiza beam completo
  void _renderFullBeam(
    Canvas canvas,
    AdvancedBeamGroup group,
    BeamSegment segment,
    Paint paint,
    double levelOffset,
  ) {
    // Calcular posições X
    final leftX = _getNoteX(group, segment.startNoteIndex) + (noteheadWidth / 2);
    final rightX = _getNoteX(group, segment.endNoteIndex) + (noteheadWidth / 2);

    // Calcular posições Y ao longo da inclinação do beam
    final leftY = group.interpolateBeamY(leftX) + levelOffset;
    final rightY = group.interpolateBeamY(rightX) + levelOffset;

    // Desenhar retângulo do beam
    final beamPath = Path();
    
    if (group.stemDirection == StemDirection.up) {
      // Hastes para cima: beam fica embaixo
      beamPath.moveTo(leftX, leftY);
      beamPath.lineTo(rightX, rightY);
      beamPath.lineTo(rightX, rightY + beamThickness);
      beamPath.lineTo(leftX, leftY + beamThickness);
    } else {
      // Hastes para baixo: beam fica em cima
      beamPath.moveTo(leftX, leftY - beamThickness);
      beamPath.lineTo(rightX, rightY - beamThickness);
      beamPath.lineTo(rightX, rightY);
      beamPath.lineTo(leftX, leftY);
    }
    
    beamPath.close();
    canvas.drawPath(beamPath, paint);
  }

  /// Renderiza fractional beam (broken beam/stub)
  void _renderFractionalBeam(
    Canvas canvas,
    AdvancedBeamGroup group,
    BeamSegment segment,
    Paint paint,
    double levelOffset,
  ) {
    final noteIndex = segment.startNoteIndex;
    final centerX = _getNoteX(group, noteIndex) + (noteheadWidth / 2);

    // Calcular Y na posição da nota
    final centerY = group.interpolateBeamY(centerX) + levelOffset;

    // Comprimento do fractional beam
    final length = segment.fractionalLength ?? noteheadWidth;

    double leftX, rightX;
    if (segment.fractionalSide == FractionalBeamSide.right) {
      leftX = centerX;
      rightX = centerX + length;
    } else {
      leftX = centerX - length;
      rightX = centerX;
    }

    // Interpolar Y para seguir inclinação
    final leftY = group.interpolateBeamY(leftX) + levelOffset;
    final rightY = group.interpolateBeamY(rightX) + levelOffset;

    // Desenhar retângulo do fractional beam
    final beamPath = Path();
    
    if (group.stemDirection == StemDirection.up) {
      beamPath.moveTo(leftX, leftY);
      beamPath.lineTo(rightX, rightY);
      beamPath.lineTo(rightX, rightY + beamThickness);
      beamPath.lineTo(leftX, leftY + beamThickness);
    } else {
      beamPath.moveTo(leftX, leftY - beamThickness);
      beamPath.lineTo(rightX, rightY - beamThickness);
      beamPath.lineTo(rightX, rightY);
      beamPath.lineTo(leftX, leftY);
    }
    
    beamPath.close();
    canvas.drawPath(beamPath, paint);
  }

  /// Obtém posição X de uma nota no grupo
  double _getNoteX(AdvancedBeamGroup group, int noteIndex) {
    // Interpolação linear entre leftX e rightX
    final totalNotes = group.notes.length - 1;
    if (totalNotes == 0) return group.leftX;

    final progress = noteIndex / totalNotes;
    return group.leftX + (progress * (group.rightX - group.leftX - noteheadWidth));
  }

  /// ✅ CORREÇÃO: Requer integração com layout engine para posição Y das notas
  /// Esta função agora lança erro se noteYPositions não estiver disponível,
  /// em vez de retornar aproximação que causa problemas tipográficos.
  double _estimateNoteY(dynamic note, AdvancedBeamGroup group) {
    // ❌ ERRO: Sistema de layout deve fornecer posições Y reais
    // Retornar aproximação causa beams desenhados em posições incorretas
    throw StateError(
      'noteYPositions deve ser fornecido ao BeamRenderer. '
      'O layout engine deve calcular e passar as posições Y reais das notas. '
      'Aproximações causam problemas tipográficos.',
    );
  }

  /// Calcula altura total necessária para múltiplos beams
  double calculateTotalBeamHeight(int beamCount) {
    if (beamCount == 0) return 0;
    return beamThickness + ((beamCount - 1) * (beamThickness + beamGap));
  }
}
