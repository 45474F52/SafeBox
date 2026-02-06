import 'package:flutter/material.dart';
import 'package:safebox/services/passwords/strength/strength_level.dart';

final class SecurityData {
  final StrengthLevel strengthLevel;
  final int score;
  final int length;
  final bool containsUppercaseLetters;
  final bool containsLowercaseLetters;
  final bool containsNumbers;
  final bool containsSpecialSymbols;
  final bool containsCommonPatterns;

  const SecurityData({
    required this.strengthLevel,
    required this.score,
    required this.length,
    required this.containsUppercaseLetters,
    required this.containsLowercaseLetters,
    required this.containsNumbers,
    required this.containsSpecialSymbols,
    required this.containsCommonPatterns,
  });

  Color get color => switch (strengthLevel) {
    StrengthLevel.veryWeak => Colors.red,
    StrengthLevel.weak => Colors.orange,
    StrengthLevel.moderate => Colors.yellow,
    StrengthLevel.strong => Colors.green,
    StrengthLevel.veryStrong => const Color.fromARGB(255, 50, 126, 52),
  };

  double get progress => switch (strengthLevel) {
    StrengthLevel.veryWeak => 0.1,
    StrengthLevel.weak => 0.3,
    StrengthLevel.moderate => 0.5,
    StrengthLevel.strong => 0.8,
    StrengthLevel.veryStrong => 1.0,
  };
}
