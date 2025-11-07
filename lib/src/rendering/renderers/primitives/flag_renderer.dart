// lib/src/rendering/renderers/primitives/flag_renderer.dart

import 'package:flutter/material.dart';
import '../../../../core/core.dart';
import '../../../theme/music_score_theme.dart';
import '../../smufl_positioning_engine.dart';
import '../base_glyph_renderer.dart';

/// Renderizador especializado APENAS para bandeirolas (flags) de notas.
///
/// Responsabilidade única: desenhar bandeirolas usando
/// âncoras SMuFL para posicionamento preciso.
class FlagRenderer extends BaseGlyphRenderer {
  final MusicScoreTheme theme;
  final SMuFLPositioningEngine positioningEngine;

  FlagRenderer({
    required super.metadata,
    required this.theme,
    required super.coordinates,
    required super.glyphSize,
    required this.positioningEngine,
  });

  /// Renderiza bandeirola de uma nota.
  ///
  /// [canvas] - Canvas onde desenhar
  /// [stemEnd] - Posição do final da haste
  /// [duration] - Duração da nota
  /// [stemUp] - Se a haste vai para cima
  void render(
    Canvas canvas,
    Offset stemEnd,
    DurationType duration,
    bool stemUp,
  ) {
    final flagGlyph = _getFlagGlyph(duration, stemUp);
    if (flagGlyph == null) return;

    // Obter âncora da bandeirola
    final flagAnchor = positioningEngine.getFlagAnchor(flagGlyph);

    // Converter âncora de spaces para pixels
    // CORREÇÃO CRÍTICA: SMuFL usa Y+ para cima, Flutter usa Y+ para baixo
    final flagAnchorPixels = Offset(
      flagAnchor.dx * coordinates.staffSpace,
      -flagAnchor.dy * coordinates.staffSpace, // INVERTER Y!
    );

    // ✅ CORREÇÃO: Removidos offsets empíricos em pixels (flagUpXOffset, flagDownYOffset, etc)
    // Os anchors SMuFL já fornecem posicionamento preciso e escalável.
    final flagX = stemEnd.dx - flagAnchorPixels.dx;
    final flagY = stemEnd.dy - flagAnchorPixels.dy;

    // Desenhar bandeirola usando âncora SMuFL
    drawGlyphWithBBox(
      canvas,
      glyphName: flagGlyph,
      position: Offset(flagX, flagY),
      color: theme.stemColor,
      options: const GlyphDrawOptions(), // Sem centralização - anchor faz o trabalho
    );
  }

  /// Retorna o glifo SMuFL correto para a bandeirola.
  String? _getFlagGlyph(DurationType duration, bool stemUp) {
    return switch (duration) {
      DurationType.eighth => stemUp ? 'flag8thUp' : 'flag8thDown',
      DurationType.sixteenth => stemUp ? 'flag16thUp' : 'flag16thDown',
      DurationType.thirtySecond => stemUp ? 'flag32ndUp' : 'flag32ndDown',
      DurationType.sixtyFourth => stemUp ? 'flag64thUp' : 'flag64thDown',
      _ => null,
    };
  }
}
