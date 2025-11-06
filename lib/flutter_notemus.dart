// lib/flutter_notemus.dart
// VERSÃO CORRIGIDA: Widget principal com todas as melhorias

import 'package:flutter/material.dart';
import 'core/core.dart'; // 🆕 Usar tipos do core
import 'src/layout/layout_engine.dart';
import 'src/rendering/staff_renderer.dart';
import 'src/rendering/staff_coordinate_system.dart';
import 'src/smufl/smufl_metadata_loader.dart';
import 'src/theme/music_score_theme.dart';

// 🆕 NOVA ARQUITETURA - Toda teoria musical em core/
export 'core/core.dart';

// Public API exports
export 'src/theme/music_score_theme.dart';
export 'src/layout/layout_engine.dart';
export 'src/parsers/json_parser.dart';
export 'src/smufl/glyph_categories.dart';
export 'src/smufl/smufl_metadata_loader.dart';
export 'src/rendering/staff_position_calculator.dart';
export 'src/rendering/staff_coordinate_system.dart';
export 'src/rendering/staff_renderer.dart';
export 'src/rendering/renderers/base_glyph_renderer.dart';
export 'src/layout/collision_detector.dart';

/// Widget principal para renderização de partituras musicais
/// VERSÃO CORRIGIDA E COMPLETA
class MusicScore extends StatefulWidget {
  final Staff staff;
  final MusicScoreTheme theme;
  final double staffSpace;

  const MusicScore({
    super.key,
    required this.staff,
    this.theme = const MusicScoreTheme(),
    this.staffSpace = 12.0,
  });

  @override
  State<MusicScore> createState() => _MusicScoreState();
}

class _MusicScoreState extends State<MusicScore> {
  late Future<void> _metadataFuture;

  @override
  void initState() {
    super.initState();
    _metadataFuture = SmuflMetadata().load();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _metadataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Erro ao carregar metadados: ${snapshot.error}'),
          );
        }

        return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final layoutEngine = LayoutEngine(
              widget.staff,
              availableWidth: constraints.maxWidth,
              staffSpace: widget.staffSpace,
            );

            final positionedElements = layoutEngine.layout();

            if (positionedElements.isEmpty) {
              return const Center(child: Text('Partitura vazia'));
            }

            final totalHeight = _calculateTotalHeight(positionedElements);

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: CustomPaint(
                  size: Size(constraints.maxWidth, totalHeight),
                  painter: MusicScorePainter(
                    positionedElements: positionedElements,
                    metadata: SmuflMetadata(),
                    theme: widget.theme,
                    staffSpace: widget.staffSpace,
                    layoutEngine: layoutEngine,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  double _calculateTotalHeight(List<PositionedElement> elements) {
    if (elements.isEmpty) return 200;

    int maxSystem = 0;
    for (final element in elements) {
      if (element.system > maxSystem) {
        maxSystem = element.system;
      }
    }

    final systemHeight = widget.staffSpace * 10;
    final margins = widget.staffSpace * 6;

    return margins + ((maxSystem + 1) * systemHeight);
  }
}

/// Painter customizado para renderização da partitura
/// VERSÃO CORRIGIDA: Usa StaffRenderer melhorado
class MusicScorePainter extends CustomPainter {
  final List<PositionedElement> positionedElements;
  final SmuflMetadata metadata;
  final MusicScoreTheme theme;
  final double staffSpace;
  final LayoutEngine? layoutEngine;

  MusicScorePainter({
    required this.positionedElements,
    required this.metadata,
    required this.theme,
    required this.staffSpace,
    this.layoutEngine,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (metadata.isNotLoaded || positionedElements.isEmpty) return;

    // Agrupar elementos por sistema
    final Map<int, List<PositionedElement>> systemGroups = {};

    for (final element in positionedElements) {
      systemGroups.putIfAbsent(element.system, () => []).add(element);
    }

    // Renderizar cada sistema
    for (final entry in systemGroups.entries) {
      final systemIndex = entry.key;
      final elements = entry.value;

      final systemY = (systemIndex * staffSpace * 10) + (staffSpace * 5);
      final staffBaseline = Offset(0, systemY);

      final coordinates = StaffCoordinateSystem(
        staffSpace: staffSpace,
        staffBaseline: staffBaseline,
      );

      final renderer = StaffRenderer(
        coordinates: coordinates,
        metadata: metadata,
        theme: theme,
      );

      renderer.renderStaff(canvas, elements, size, layoutEngine: layoutEngine);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is! MusicScorePainter) return true;

    return oldDelegate.positionedElements.length != positionedElements.length ||
        oldDelegate.theme != theme ||
        oldDelegate.staffSpace != staffSpace;
  }
}
