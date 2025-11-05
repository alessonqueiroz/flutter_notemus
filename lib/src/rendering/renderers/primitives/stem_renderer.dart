// lib/src/rendering/renderers/primitives/stem_renderer.dart

import 'package:flutter/material.dart';
import '../../../theme/music_score_theme.dart';
import '../../smufl_positioning_engine.dart';
import '../base_glyph_renderer.dart';

/// Renderizador especializado APENAS para hastes (stems) de notas.
///
/// Responsabilidade única: desenhar hastes de notas usando
/// âncoras SMuFL para posicionamento preciso.
class StemRenderer extends BaseGlyphRenderer {
  final MusicScoreTheme theme;
  final double stemThickness;
  final SMuFLPositioningEngine positioningEngine;

  StemRenderer({
    required super.metadata,
    required this.theme,
    required super.coordinates,
    required super.glyphSize,
    required this.stemThickness,
    required this.positioningEngine,
  });

  /// Renderiza haste de uma nota.
  ///
  /// Retorna o Offset do final da haste (onde a bandeirola deve ser desenhada).
  ///
  /// [canvas] - Canvas onde desenhar
  /// [notePosition] - Posição da cabeça da nota
  /// [noteheadGlyph] - Glifo da cabeça da nota
  /// [staffPosition] - Posição da nota na pauta
  /// [stemUp] - Se a haste vai para cima
  /// [beamCount] - Número de barras (0 para notas sem barra)
  Offset render(
    Canvas canvas,
    Offset notePosition,
    String noteheadGlyph,
    int staffPosition,
    bool stemUp,
    int beamCount,
  ) {
    // Obter âncora SMuFL da cabeça de nota
    final stemAnchor = stemUp
        ? positioningEngine.getStemUpAnchor(noteheadGlyph)
        : positioningEngine.getStemDownAnchor(noteheadGlyph);

    // Converter âncora de staff spaces para pixels
    // CORREÇÃO CRÍTICA: SMuFL usa Y+ para cima, Flutter usa Y+ para baixo
    final stemAnchorPixels = Offset(
      stemAnchor.dx * coordinates.staffSpace,
      -stemAnchor.dy * coordinates.staffSpace, // INVERTER Y!
    );

    // Posição inicial da haste
    final stemX = notePosition.dx + stemAnchorPixels.dx;
    final stemStartY = notePosition.dy + stemAnchorPixels.dy;

    // Calcular comprimento da haste
    final stemLength =
        positioningEngine.calculateStemLength(
          staffPosition: staffPosition,
          stemUp: stemUp,
          beamCount: beamCount,
          isBeamed: false,
        ) *
        coordinates.staffSpace;

    final stemEndY = stemUp ? stemStartY - stemLength : stemStartY + stemLength;

    // Desenhar haste
    final stemPaint = Paint()
      ..color = theme.stemColor
      ..strokeWidth = stemThickness
      ..strokeCap = StrokeCap.butt;

    canvas.drawLine(
      Offset(stemX, stemStartY),
      Offset(stemX, stemEndY),
      stemPaint,
    );

    // Retornar posição do final da haste (para bandeirola)
    return Offset(stemX, stemEndY);
  }
}
