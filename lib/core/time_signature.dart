// lib/core/time_signature.dart

import 'musical_element.dart';

/// Representa a fórmula de compasso.
class TimeSignature extends MusicalElement {
  final int numerator;
  final int denominator;
  
  TimeSignature({required this.numerator, required this.denominator});

  /// Calcula o valor total permitido no compasso.
  /// Fórmula: numerator × (1 / denominator)
  double get measureValue => numerator * (1.0 / denominator);
}
