// lib/src/rendering/staff_renderer.dart
// VERSÃO CORRIGIDA COM TIPOGRAFIA PROFISSIONAL
// FASE 2 REFATORAÇÃO: Usando tipos do core/

import 'package:flutter/material.dart';
import '../../core/core.dart'; // 🆕 Tipos do core
import '../layout/layout_engine.dart';
import '../smufl/smufl_metadata_loader.dart';
import '../theme/music_score_theme.dart';
import 'renderers/articulation_renderer.dart';
import 'renderers/bar_element_renderer.dart';
import 'renderers/barline_renderer.dart';
import 'renderers/chord_renderer.dart';
import 'renderers/glyph_renderer.dart';
import 'renderers/group_renderer.dart';
import 'renderers/note_renderer.dart';
import 'renderers/ornament_renderer.dart';
import 'renderers/rest_renderer.dart';
import 'renderers/symbol_and_text_renderer.dart';
import 'renderers/tuplet_renderer.dart';
import 'smufl_positioning_engine.dart';
import 'staff_coordinate_system.dart';

class StaffRenderer {
  final StaffCoordinateSystem coordinates;
  final SmuflMetadata metadata;
  final MusicScoreTheme theme;

  late final double glyphSize;
  late final double staffLineThickness;
  late final double stemThickness;
  late final SMuFLPositioningEngine positioningEngine;

  Clef? currentClef;

  late final GlyphRenderer glyphRenderer;
  late final ArticulationRenderer articulationRenderer;
  late final BarElementRenderer barElementRenderer;
  late final BarlineRenderer barlineRenderer;
  late final ChordRenderer chordRenderer;
  late final GroupRenderer groupRenderer;
  late final NoteRenderer noteRenderer;
  late final OrnamentRenderer ornamentRenderer;
  late final RestRenderer restRenderer;
  late final SymbolAndTextRenderer symbolAndTextRenderer;
  late final TupletRenderer tupletRenderer;

  StaffRenderer({
    required this.coordinates,
    required this.metadata,
    required this.theme,
  }) {
    // CORREÇÃO TIPOGRÁFICA: Tamanho correto do glifo baseado em SMuFL
    glyphSize = coordinates.staffSpace * 4.0;

    // CORREÇÃO: Usar valores corretos do metadata Bravura
    staffLineThickness =
        metadata.getEngravingDefault('staffLineThickness') *
        coordinates.staffSpace;
    stemThickness =
        metadata.getEngravingDefault('stemThickness') * coordinates.staffSpace;

    // Initialize SMuFL positioning engine with already loaded metadata
    positioningEngine = SMuFLPositioningEngine(metadataLoader: metadata);

    // Initialize all the specialized renderers
    glyphRenderer = GlyphRenderer(metadata: metadata);

    ornamentRenderer = OrnamentRenderer(
      coordinates: coordinates,
      metadata: metadata,
      theme: theme,
      glyphSize: glyphSize,
      staffLineThickness: staffLineThickness,
    );

    articulationRenderer = ArticulationRenderer(
      coordinates: coordinates,
      metadata: metadata,
      theme: theme,
      glyphSize: glyphSize,
    );

    barElementRenderer = BarElementRenderer(
      coordinates: coordinates,
      metadata: metadata,
      theme: theme,
      glyphSize: glyphSize,
    );

    barlineRenderer = BarlineRenderer(
      coordinates: coordinates,
      metadata: metadata,
      theme: theme,
    );

    noteRenderer = NoteRenderer(
      coordinates: coordinates,
      metadata: metadata,
      theme: theme,
      glyphSize: glyphSize,
      staffLineThickness: staffLineThickness,
      stemThickness: stemThickness,
      articulationRenderer: articulationRenderer,
      ornamentRenderer: ornamentRenderer,
      positioningEngine: positioningEngine,
    );

    chordRenderer = ChordRenderer(
      coordinates: coordinates,
      metadata: metadata,
      theme: theme,
      glyphSize: glyphSize,
      staffLineThickness: staffLineThickness,
      stemThickness: stemThickness,
      noteRenderer: noteRenderer,
    );

    restRenderer = RestRenderer(
      coordinates: coordinates,
      metadata: metadata,
      theme: theme,
      glyphSize: glyphSize,
      ornamentRenderer: ornamentRenderer,
    );

    symbolAndTextRenderer = SymbolAndTextRenderer(
      coordinates: coordinates,
      metadata: metadata,
      theme: theme,
      glyphSize: glyphSize,
    );

    groupRenderer = GroupRenderer(
      coordinates: coordinates,
      metadata: metadata,
      theme: theme,
      glyphSize: glyphSize,
      staffLineThickness: staffLineThickness,
      stemThickness: stemThickness,
    );

    tupletRenderer = TupletRenderer(
      coordinates: coordinates,
      metadata: metadata,
      theme: theme,
      glyphSize: glyphSize,
      noteRenderer: noteRenderer,
      restRenderer: restRenderer,
    );
  }

  void renderStaff(Canvas canvas, List<PositionedElement> elements, Size size) {
    _drawStaffLines(canvas, size.width);
    currentClef = Clef(clefType: ClefType.treble); // Default clef

    // Primeira passagem: renderizar elementos individuais
    for (final positioned in elements) {
      _renderElement(canvas, positioned);
    }

    // Segunda passagem: renderizar elementos de grupo (beams, ties, slurs)
    if (currentClef != null) {
      groupRenderer.renderBeams(canvas, elements, currentClef!);
      groupRenderer.renderTies(canvas, elements, currentClef!);
      groupRenderer.renderSlurs(canvas, elements, currentClef!);
    }
  }

  void _drawStaffLines(Canvas canvas, double width) {
    final paint = Paint()
      ..color = theme.staffLineColor
      ..strokeWidth = staffLineThickness
      ..style = PaintingStyle.stroke;

    for (int line = 1; line <= 5; line++) {
      final y = coordinates.getStaffLineY(line);
      canvas.drawLine(
        Offset(coordinates.staffBaseline.dx, y),
        Offset(width - 20, y),
        paint,
      );
    }
  }

  void _renderElement(Canvas canvas, PositionedElement positioned) {
    final element = positioned.element;
    final basePosition = positioned.position;

    if (element is Clef) {
      currentClef = element;
      barElementRenderer.renderClef(canvas, element, basePosition);
    } else if (element is KeySignature && currentClef != null) {
      barElementRenderer.renderKeySignature(
        canvas,
        element,
        currentClef!,
        basePosition,
      );
    } else if (element is TimeSignature) {
      barElementRenderer.renderTimeSignature(canvas, element, basePosition);
    } else if (element is Note && currentClef != null) {
      // CORREÇÃO: Não renderizar notas com beam aqui
      if (element.beam == null) {
        noteRenderer.render(canvas, element, basePosition, currentClef!);
      }
    } else if (element is Rest) {
      restRenderer.render(canvas, element, basePosition);
    } else if (element is Barline) {
      barlineRenderer.render(canvas, element, basePosition);
    } else if (element is Chord && currentClef != null) {
      chordRenderer.render(canvas, element, basePosition, currentClef!);
    } else if (element is Tuplet && currentClef != null) {
      tupletRenderer.render(canvas, element, basePosition, currentClef!);
    } else if (element is RepeatMark) {
      symbolAndTextRenderer.renderRepeatMark(canvas, element, basePosition);
    } else if (element is Dynamic) {
      symbolAndTextRenderer.renderDynamic(canvas, element, basePosition);
    } else if (element is MusicText) {
      symbolAndTextRenderer.renderMusicText(canvas, element, basePosition);
    } else if (element is TempoMark) {
      symbolAndTextRenderer.renderTempoMark(canvas, element, basePosition);
    } else if (element is Breath) {
      symbolAndTextRenderer.renderBreath(canvas, element, basePosition);
    } else if (element is Caesura) {
      symbolAndTextRenderer.renderCaesura(canvas, element, basePosition);
    } else if (element is OctaveMark) {
      symbolAndTextRenderer.renderOctaveMark(canvas, element, basePosition);
    }
  }
}