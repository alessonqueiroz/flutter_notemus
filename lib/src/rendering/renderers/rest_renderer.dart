// lib/src/rendering/renderers/rest_renderer.dart
// VERSÃO REFATORADA: Herda de BaseGlyphRenderer
//
// MELHORIAS IMPLEMENTADAS (Fase 2):
// ✅ Herda de BaseGlyphRenderer para renderização consistente
// ✅ Usa drawGlyphWithBBox para 100% conformidade SMuFL
// ✅ Cache automático de TextPainters para melhor performance
// ✅ Elimina método _drawGlyph duplicado (30 linhas)

import 'package:flutter/material.dart';
import '../../../core/core.dart'; // 🆕 Tipos do core
import '../../layout/collision_detector.dart'; // CORREÇÃO: Import collision detector
import '../../smufl/smufl_metadata_loader.dart';
import '../../theme/music_score_theme.dart';
import '../staff_coordinate_system.dart';
import 'base_glyph_renderer.dart';
import 'ornament_renderer.dart';

class RestRenderer extends BaseGlyphRenderer {
  final MusicScoreTheme theme;
  final OrnamentRenderer ornamentRenderer;

  // ignore: use_super_parameters
  RestRenderer({
    required StaffCoordinateSystem coordinates,
    required SmuflMetadata metadata,
    required this.theme,
    required double glyphSize,
    required this.ornamentRenderer,
    CollisionDetector? collisionDetector, // CORREÇÃO: Adicionar collision detector
  }) : super(
         coordinates: coordinates,
         metadata: metadata,
         glyphSize: glyphSize,
         collisionDetector: collisionDetector, // CORREÇÃO: Passar para super
       );

  void render(Canvas canvas, Rest rest, Offset position) {
    String glyphName;
    // CORREÇÃO: Usar staffPosition relativo ao centro da pauta
    // staffPosition 0 = linha do meio (linha 3)
    // Positive = acima, Negative = abaixo
    int staffPosition;

    switch (rest.duration.type) {
      case DurationType.whole:
        glyphName = 'restWhole';
        // CORREÇÃO MUSICOLÓGICA: Pausa de semibreve fica ABAIXO da 4ª linha
        // staffPosition = 2 (4ª linha, contando de baixo)
        staffPosition = 2;
        break;
      case DurationType.half:
        glyphName = 'restHalf';
        // CORREÇÃO MUSICOLÓGICA: Pausa de mínima fica EM CIMA da 3ª linha (linha do meio)
        // staffPosition = 0 (linha central da pauta)
        staffPosition = 0;
        break;
      case DurationType.quarter:
        glyphName = 'restQuarter';
        // Pausa de semínima centrada
        staffPosition = 0;
        break;
      case DurationType.eighth:
        glyphName = 'rest8th';
        // Pausas menores centradas
        staffPosition = 0;
        break;
      case DurationType.sixteenth:
        glyphName = 'rest16th';
        staffPosition = 0;
        break;
      case DurationType.thirtySecond:
        glyphName = 'rest32nd';
        staffPosition = 0;
        break;
      case DurationType.sixtyFourth:
        glyphName = 'rest64th';
        staffPosition = 0;
        break;
      default:
        glyphName = 'restQuarter';
        staffPosition = 0;
    }

    // Calcular Y baseado no staff position (mesmo método usado para notas)
    final restY =
        coordinates.staffBaseline.dy -
        (staffPosition * coordinates.staffSpace * 0.5);

    final restPosition = Offset(position.dx, restY);

    // MELHORIA: Usar drawGlyphWithBBox herdado de BaseGlyphRenderer
    // Isso automaticamente aplica o ajuste de bounding box SMuFL
    drawGlyphWithBBox(
      canvas,
      glyphName: glyphName,
      position: restPosition,
      color: theme.restColor,
      options: GlyphDrawOptions.restDefault,
    );

    // Renderizar ornamentos se presentes
    if (rest.ornaments.isNotEmpty) {
      final placeholderNote = Note(
        pitch: Pitch(step: 'B', octave: 4), // Posição central da pauta
        duration: rest.duration,
        ornaments: rest.ornaments,
      );
      ornamentRenderer.renderForNote(canvas, placeholderNote, restPosition, 0);
    }
  }
}
