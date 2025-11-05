// example/lib/examples/complete_music_piece.dart
// Peça musical completa demonstrando todos os recursos do flutter_notemus

import 'package:flutter/material.dart';
import 'package:flutter_notemus/flutter_notemus.dart';

class CompleteMusicPieceExample extends StatelessWidget {
  const CompleteMusicPieceExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 32),
            _buildPieceInfo(),
            const SizedBox(height: 24),
            _createFullScore(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Exemplo de Composição Completa',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Demonstração de todos os elementos SMuFL em contexto musical real',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[700],
          ),
        ),
        const Divider(height: 32),
      ],
    );
  }

  Widget _buildPieceInfo() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.music_note, color: Colors.deepPurple, size: 32),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pequena Peça Demonstrativa',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Compositor: SMuFL Renderer Team',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow('Tonalidade:', 'Ré Maior (2 sustenidos)'),
            _buildInfoRow('Compasso:', '4/4 (Comum)'),
            _buildInfoRow('Andamento:', 'Moderato ♩= 100'),
            _buildInfoRow('Elementos:', 'Claves, Armaduras, Ornamentos, Articulações, Dinâmicas, Ligaduras'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _createFullScore() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Partitura Completa',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              padding: const EdgeInsets.all(16),
              child: _createMusicScore(),
            ),
            const SizedBox(height: 16),
            _buildLegend(),
          ],
        ),
      ),
    );
  }

  Widget _createMusicScore() {
    final staff = Staff();

    // === COMPASSO 1: Introdução com ornamentos ===
    final measure1 = Measure();
    measure1.add(Clef(clefType: ClefType.treble));
    measure1.add(KeySignature(2)); // Ré Maior
    measure1.add(TimeSignature(numerator: 4, denominator: 4));
    measure1.add(TempoMark(
      text: 'Moderato',
      beatUnit: DurationType.quarter,
      bpm: 100,
    ));

    // Frase de abertura com ligadura de expressão
    measure1.add(Note(
      pitch: const Pitch(step: 'D', octave: 5),
      duration: const Duration(DurationType.quarter),
      dynamicElement: Dynamic(type: DynamicType.mezzoPiano),
      slur: SlurType.start,
      ornaments: [Ornament(type: OrnamentType.trill)],
    ));

    measure1.add(Note(
      pitch: Pitch.withAccidental(step: 'F', octave: 5, accidentalType: AccidentalType.sharp),
      duration: const Duration(DurationType.eighth),
    ));

    measure1.add(Note(
      pitch: const Pitch(step: 'E', octave: 5),
      duration: const Duration(DurationType.eighth),
    ));

    measure1.add(Note(
      pitch: const Pitch(step: 'D', octave: 5),
      duration: const Duration(DurationType.quarter),
      slur: SlurType.end,
      articulations: [ArticulationType.tenuto],
    ));

    measure1.add(Note(
      pitch: const Pitch(step: 'A', octave: 4),
      duration: const Duration(DurationType.quarter),
      articulations: [ArticulationType.staccato],
    ));

    // === COMPASSO 2: Tercinas e crescendo ===
    final measure2 = Measure();

    // Tercina de colcheias com ligadura
    measure2.add(Tuplet(
      actualNotes: 3,
      normalNotes: 2,
      elements: [
        Note(
          pitch: const Pitch(step: 'B', octave: 4),
          duration: const Duration(DurationType.eighth),
          slur: SlurType.start,
        ),
        Note(
          pitch: Pitch.withAccidental(step: 'C', octave: 5, accidentalType: AccidentalType.sharp),
          duration: const Duration(DurationType.eighth),
        ),
        Note(
          pitch: const Pitch(step: 'D', octave: 5),
          duration: const Duration(DurationType.eighth),
          slur: SlurType.end,
        ),
      ],
      showBracket: true,
      showNumber: true,
    ));

    measure2.add(Note(
      pitch: const Pitch(step: 'E', octave: 5),
      duration: const Duration(DurationType.quarter),
      articulations: [ArticulationType.accent],
    ));

    measure2.add(Note(
      pitch: Pitch.withAccidental(step: 'F', octave: 5, accidentalType: AccidentalType.sharp),
      duration: const Duration(DurationType.half),
      ornaments: [Ornament(type: OrnamentType.turn)],
    ));

    // Crescendo
    measure2.add(Dynamic(
      type: DynamicType.crescendo,
      isHairpin: true,
      length: 100,
    ));

    // === COMPASSO 3: Acorde e clímax ===
    final measure3 = Measure();

    // Acorde forte no clímax
    measure3.add(Chord(
      notes: [
        Note(
          pitch: const Pitch(step: 'A', octave: 4),
          duration: const Duration(DurationType.half),
        ),
        Note(
          pitch: const Pitch(step: 'D', octave: 5),
          duration: const Duration(DurationType.half),
        ),
        Note(
          pitch: Pitch.withAccidental(step: 'F', octave: 5, accidentalType: AccidentalType.sharp),
          duration: const Duration(DurationType.half),
        ),
      ],
      duration: const Duration(DurationType.half),
      dynamic: Dynamic(type: DynamicType.forte),
      articulations: [ArticulationType.marcato],
    ));

    measure3.add(Breath(type: BreathType.comma));

    // Resposta suave
    measure3.add(Note(
      pitch: const Pitch(step: 'G', octave: 5),
      duration: const Duration(DurationType.quarter),
      dynamicElement: Dynamic(type: DynamicType.piano),
      articulations: [ArticulationType.tenuto],
    ));

    measure3.add(Note(
      pitch: const Pitch(step: 'E', octave: 5),
      duration: const Duration(DurationType.quarter),
      articulations: [ArticulationType.staccato],
    ));

    // === COMPASSO 4: Finalização com fermata ===
    final measure4 = Measure();

    // Ligadura de prolongamento
    measure4.add(Note(
      pitch: const Pitch(step: 'D', octave: 5),
      duration: const Duration(DurationType.half, dots: 1),
      tie: TieType.start,
      slur: SlurType.start,
    ));

    measure4.add(Note(
      pitch: Pitch.withAccidental(step: 'C', octave: 5, accidentalType: AccidentalType.sharp),
      duration: const Duration(DurationType.eighth),
      slur: SlurType.end,
    ));

    measure4.add(Note(
      pitch: const Pitch(step: 'D', octave: 5),
      duration: const Duration(DurationType.whole),
      tie: TieType.end,
      ornaments: [Ornament(type: OrnamentType.fermata)],
      dynamicElement: Dynamic(type: DynamicType.pianissimo),
    ));

    staff.add(measure1);
    staff.add(measure2);
    staff.add(measure3);
    staff.add(measure4);

    return SizedBox(
      height: 400,
      child: MusicScore(
        staff: staff,
        staffSpace: 14,
        theme: const MusicScoreTheme(
          noteheadColor: Colors.black,
          stemColor: Colors.black87,
          staffLineColor: Colors.black54,
          clefColor: Colors.black,
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Elementos Demonstrados:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildLegendRow('🎼', 'Clave de Sol com armadura de Ré Maior'),
          _buildLegendRow('🎵', 'Ornamentos: Trino, Grupeto, Fermata'),
          _buildLegendRow('🎯', 'Articulações: Staccato, Tenuto, Marcato, Accent'),
          _buildLegendRow('📊', 'Dinâmicas: mp, p, f, pp com crescendo'),
          _buildLegendRow('🔗', 'Ligaduras de expressão e prolongamento'),
          _buildLegendRow('3️⃣', 'Quiáltera: Tercina de colcheias'),
          _buildLegendRow('🎸', 'Acorde: Tríade de Ré Maior'),
          _buildLegendRow('💨', 'Marca de respiração'),
        ],
      ),
    );
  }

  Widget _buildLegendRow(String emoji, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              description,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
