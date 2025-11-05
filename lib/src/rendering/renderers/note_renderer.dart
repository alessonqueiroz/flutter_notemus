// lib/src/rendering/renderers/note_renderer.dart
// VERSÃO REFATORADA: Usa StaffPositionCalculator e BaseGlyphRenderer
//
// MELHORIAS IMPLEMENTADAS:
// ✅ Usa StaffPositionCalculator unificado para cálculo de posições
// ✅ Usa BaseGlyphRenderer.drawGlyphWithBBox para renderização consistente
// ✅ Elimina código duplicado de _calculateStaffPosition
// ✅ Elimina uso de centerVertically/centerHorizontally inconsistente
// ✅ Cache de TextPainters para melhor performance

import 'package:flutter/material.dart';
import '../../../core/core.dart'; // 🆕 Tipos do core
import '../../smufl/smufl_metadata_loader.dart';
import '../../theme/music_score_theme.dart';
import '../smufl_positioning_engine.dart';
import '../staff_coordinate_system.dart';
import '../staff_position_calculator.dart';
import 'articulation_renderer.dart';
import 'base_glyph_renderer.dart';
import 'ornament_renderer.dart';
import 'primitives/accidental_renderer.dart';
import 'primitives/dot_renderer.dart';
import 'primitives/flag_renderer.dart';
import 'primitives/ledger_line_renderer.dart';
import 'primitives/stem_renderer.dart';
import 'symbol_and_text_renderer.dart';

class NoteRenderer extends BaseGlyphRenderer {
  final MusicScoreTheme theme;
  final ArticulationRenderer articulationRenderer;
  final OrnamentRenderer ornamentRenderer;
  final SMuFLPositioningEngine positioningEngine;
  
  // 🆕 COMPONENTES ESPECIALIZADOS (SRP)
  late final DotRenderer dotRenderer;
  late final LedgerLineRenderer ledgerLineRenderer;
  late final StemRenderer stemRenderer;
  late final FlagRenderer flagRenderer;
  late final AccidentalRenderer accidentalRenderer;
  late final SymbolAndTextRenderer symbolAndTextRenderer;

  NoteRenderer({
    required StaffCoordinateSystem coordinates,
    required SmuflMetadata metadata,
    required this.theme,
    required double glyphSize,
    required double staffLineThickness,
    required double stemThickness,
    required this.articulationRenderer,
    required this.ornamentRenderer,
    required this.positioningEngine,
  }) : super(
          coordinates: coordinates,
          metadata: metadata,
          glyphSize: glyphSize,
        ) {
    // 🆕 Inicializar componentes especializados
    dotRenderer = DotRenderer(
      metadata: metadata,
      theme: theme,
      coordinates: coordinates,
      glyphSize: glyphSize,
    );
    
    ledgerLineRenderer = LedgerLineRenderer(
      metadata: metadata,
      theme: theme,
      coordinates: coordinates,
      glyphSize: glyphSize,
      staffLineThickness: staffLineThickness,
    );
    
    stemRenderer = StemRenderer(
      metadata: metadata,
      theme: theme,
      coordinates: coordinates,
      glyphSize: glyphSize,
      stemThickness: stemThickness,
      positioningEngine: positioningEngine,
    );
    
    flagRenderer = FlagRenderer(
      metadata: metadata,
      theme: theme,
      coordinates: coordinates,
      glyphSize: glyphSize,
      positioningEngine: positioningEngine,
    );
    
    accidentalRenderer = AccidentalRenderer(
      metadata: metadata,
      theme: theme,
      coordinates: coordinates,
      glyphSize: glyphSize,
      positioningEngine: positioningEngine,
    );
    
    symbolAndTextRenderer = SymbolAndTextRenderer(
      coordinates: coordinates,
      metadata: metadata,
      theme: theme,
      glyphSize: glyphSize,
    );
  }

  void render(Canvas canvas, Note note, Offset basePosition, Clef currentClef) {
    // MELHORIA: Usar StaffPositionCalculator unificado
    final staffPosition = StaffPositionCalculator.calculate(note.pitch, currentClef);

    // Converter posição da pauta para coordenada Y em pixels
    final noteY = StaffPositionCalculator.toPixelY(
      staffPosition,
      coordinates.staffSpace,
      coordinates.staffBaseline.dy,
    );

    // Preparar glyph da cabeça de nota
    final noteheadGlyph = note.duration.type.glyphName;
    
    // 🆕 Delegar para LedgerLineRenderer
    ledgerLineRenderer.render(canvas, basePosition.dx, staffPosition, noteheadGlyph);

    // Preparar posição da cabeça de nota
    // A correção de baseline SMuFL é aplicada automaticamente em drawGlyphWithBBox
    final notePos = Offset(basePosition.dx, noteY);

    // CORREÇÃO CRÍTICA: Calcular o centro horizontal da cabeça de nota
    // Como noteheads usam centerHorizontally: false, notePos.dx é a borda ESQUERDA
    // Mas articulações, ornamentos, etc. usam centerHorizontally: true e esperam o CENTRO
    final noteheadInfo = metadata.getGlyphInfo(noteheadGlyph);
    final bbox = noteheadInfo?.boundingBox;
    final centerX = bbox != null
        ? ((bbox.bBoxSwX + bbox.bBoxNeX) / 2) * coordinates.staffSpace
        : (1.18 / 2) * coordinates.staffSpace; // Fallback para noteheadBlack
    
    final noteCenter = Offset(basePosition.dx + centerX, noteY);

    // 🆕 Delegar para AccidentalRenderer
    accidentalRenderer.render(canvas, note, notePos, staffPosition.toDouble());

    // MELHORIA: Desenhar cabeça de nota usando BaseGlyphRenderer
    // Usa drawGlyphWithBBox que automaticamente aplica bounding box SMuFL
    drawGlyphWithBBox(
      canvas,
      glyphName: noteheadGlyph,
      position: notePos,
      color: theme.noteheadColor,
      options: GlyphDrawOptions.noteheadDefault,
    );

    // 🆕 Delegar para StemRenderer e FlagRenderer
    if (note.duration.type != DurationType.whole && note.beam == null) {
      final stemUp = staffPosition <= 0;
      final beamCount = _getBeamCount(note.duration.type);
      
      final stemEnd = stemRenderer.render(
        canvas,
        notePos,
        noteheadGlyph,
        staffPosition,
        stemUp,
        beamCount,
      );
      
      // Desenhar bandeirola se necessário
      if (note.duration.type.value < 0.25) {
        flagRenderer.render(canvas, stemEnd, note.duration.type, stemUp);
      }
    }

    // Renderizar articulações usando o CENTRO da cabeça de nota
    articulationRenderer.render(
      canvas,
      note.articulations,
      noteCenter,
      staffPosition,
    );

    // Renderizar ornamentos usando o CENTRO da cabeça de nota
    ornamentRenderer.renderForNote(
      canvas,
      note,
      noteCenter,
      staffPosition,
    );

    // Renderizar dinâmicas se presente
    if (note.dynamicElement != null) {
      _renderDynamic(canvas, note.dynamicElement!, basePosition, staffPosition);
    }

    // 🆕 Delegar para DotRenderer
    if (note.duration.dots > 0) {
      dotRenderer.render(canvas, note, noteCenter, staffPosition);
    }
  }

  // 🆕 Método auxiliar: calcular número de barras
  int _getBeamCount(DurationType duration) {
    return switch (duration) {
      DurationType.eighth => 1,
      DurationType.sixteenth => 2,
      DurationType.thirtySecond => 3,
      DurationType.sixtyFourth => 4,
      _ => 0,
    };
  }

  /// Renderizar dinâmica associada à nota
  void _renderDynamic(
    Canvas canvas,
    Dynamic dynamic,
    Offset basePosition,
    int staffPosition,
  ) {
    symbolAndTextRenderer.renderDynamic(canvas, dynamic, basePosition);
  }
}
