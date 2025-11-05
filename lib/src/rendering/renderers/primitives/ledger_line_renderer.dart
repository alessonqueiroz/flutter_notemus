// lib/src/rendering/renderers/primitives/ledger_line_renderer.dart

import 'package:flutter/material.dart';
import '../../../theme/music_score_theme.dart';
import '../../staff_position_calculator.dart';
import '../base_glyph_renderer.dart';

/// Renderizador especializado APENAS para linhas suplementares (ledger lines).
///
/// Responsabilidade única: desenhar linhas suplementares para notas
/// fora do pentagrama.
class LedgerLineRenderer extends BaseGlyphRenderer {
  final MusicScoreTheme theme;
  final double staffLineThickness;

  LedgerLineRenderer({
    required super.metadata,
    required this.theme,
    required super.coordinates,
    required super.glyphSize,
    required this.staffLineThickness,
  });

  /// Renderiza linhas suplementares para uma nota.
  ///
  /// [canvas] - Canvas onde desenhar
  /// [notePosition] - Posição X da nota
  /// [staffPosition] - Posição da nota na pauta
  /// [noteheadGlyph] - Glifo da cabeça da nota (para calcular largura)
  void render(
    Canvas canvas,
    double notePosition,
    int staffPosition,
    String noteheadGlyph,
  ) {
    if (!theme.showLedgerLines) return;

    // Verificar se a nota precisa de linhas suplementares
    if (!StaffPositionCalculator.needsLedgerLines(staffPosition)) return;

    final paint = Paint()
      ..color = theme.staffLineColor
      ..strokeWidth = staffLineThickness;

    // Calcular centro horizontal baseado no bounding box da nota
    final noteheadInfo = metadata.getGlyphInfo(noteheadGlyph);
    final bbox = noteheadInfo?.boundingBox;

    final centerX = bbox != null
        ? ((bbox.bBoxSwX + bbox.bBoxNeX) / 2) * coordinates.staffSpace
        : (1.18 / 2) * coordinates.staffSpace; // Fallback

    final centerPosition = notePosition + centerX;

    // Calcular largura da linha baseada no glifo real
    final noteWidth =
        bbox?.widthInPixels(coordinates.staffSpace) ??
        (coordinates.staffSpace * 1.18);

    // Extensão das linhas suplementares
    final extension = coordinates.staffSpace * 0.6;
    final totalWidth = noteWidth + (2 * extension);

    // Obter posições das linhas suplementares
    final ledgerPositions = StaffPositionCalculator.getLedgerLinePositions(
      staffPosition,
    );

    // Desenhar cada linha suplementar
    for (final pos in ledgerPositions) {
      final y = StaffPositionCalculator.toPixelY(
        pos,
        coordinates.staffSpace,
        coordinates.staffBaseline.dy,
      );

      // NÃO aplicar correção de baseline!
      // As linhas do pentagrama não recebem correção,
      // então as linhas suplementares também não devem receber.
      canvas.drawLine(
        Offset(centerPosition - totalWidth / 2, y),
        Offset(centerPosition + totalWidth / 2, y),
        paint,
      );
    }
  }
}
