// lib/src/rendering/renderers/primitives/dot_renderer.dart

import 'package:flutter/material.dart';
import '../../../../core/core.dart';
import '../../../theme/music_score_theme.dart';
import '../base_glyph_renderer.dart';

/// Renderizador especializado APENAS para pontos de aumento.
///
/// Responsabilidade única: desenhar pontos de aumento seguindo
/// a especificação SMuFL.
///
/// Regras SMuFL:
/// - Notas em LINHAS (staffPosition PAR): ponto na mesma linha
/// - Notas em ESPAÇOS (staffPosition ÍMPAR): ponto no espaço acima
class DotRenderer extends BaseGlyphRenderer {
  final MusicScoreTheme theme;

  DotRenderer({
    required super.metadata,
    required this.theme,
    required super.coordinates,
    required super.glyphSize,
  });

  /// Renderiza pontos de aumento para uma nota.
  /// 
  /// [canvas] - Canvas onde desenhar
  /// [note] - Nota com pontos de aumento
  /// [notePosition] - Posição da cabeça da nota (centro)
  /// [staffPosition] - Posição da nota na pauta (em meios de staff space)
  void render(
    Canvas canvas,
    Note note,
    Offset notePosition,
    int staffPosition,
  ) {
    if (note.duration.dots == 0) return;

    // Posição X: simples offset à direita da nota
    // notePosition já é o CENTRO da nota, então apenas adicionar espaçamento
    final dotStartX = notePosition.dx + (coordinates.staffSpace * 0.6);

    // CORREÇÃO CRÍTICA: Usar a posição Y REAL da nota, apenas ajustar se espaço
    final dotY = _calculateDotY(notePosition.dy, staffPosition);

    // Desenhar cada ponto
    for (int i = 0; i < note.duration.dots; i++) {
      final dotX = dotStartX + (i * coordinates.staffSpace * 0.4);
      
      _drawDot(canvas, Offset(dotX, dotY));
    }
  }

  /// Calcula a posição Y do ponto seguindo especificação SMuFL.
  /// 
  /// [noteY] - Posição Y REAL da nota (em pixels)
  /// [staffPosition] - Posição da nota no pentagrama
  double _calculateDotY(double noteY, int staffPosition) {
    // ESPECIFICAÇÃO SMUFL:
    // - Notas em LINHAS (staffPosition PAR): ponto fica na mesma linha
    // - Notas em ESPAÇOS (staffPosition ÍMPAR): ponto fica no espaço ACIMA
    
    if (staffPosition.isEven) {
      // Nota em LINHA: ponto na mesma posição
      return noteY;
    } else {
      // Nota em ESPAÇO: ponto no espaço ACIMA
      // "Acima" = meio staff space para cima = -0.5 * staffSpace
      return noteY - (coordinates.staffSpace / 2);
    }
  }

  /// Desenha um único ponto de aumento.
  void _drawDot(Canvas canvas, Offset position) {
    drawGlyphWithBBox(
      canvas,
      glyphName: 'augmentationDot',
      position: position,
      color: theme.noteheadColor,
      options: const GlyphDrawOptions(
        centerHorizontally: true,
        centerVertically: true, // Centralizar na posição calculada
        size: null,
        scale: 0.8, // 80% do tamanho normal
      ),
    );
  }
}
