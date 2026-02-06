// ignore_for_file: curly_braces_in_flow_control_structures

import 'dart:io';

import 'package:flutter/services.dart';
import 'package:safebox/services/passwords/strength/security_data.dart';
import 'package:safebox/services/passwords/strength/strength_level.dart';

class PasswordSecurityChecker {
  static const _patternsFilePath = 'assets/files/common_patterns.txt';
  static const _minLength = 8;
  static const _maxScore = 100;

  static late Set<String> _commonPatterns;

  static Future<void> init() async {
    final fileContent = await rootBundle.loadString(_patternsFilePath);
    _commonPatterns = Set.from(fileContent.split(Platform.lineTerminator))
      ..removeWhere((pattern) => pattern.isEmpty);
  }

  static SecurityData check(String password) {
    int score = 0;
    final length = password.length;

    if (length >= 20)
      score += 25;
    else if (length >= 15)
      score += 20;
    else if (length >= 10)
      score += 15;
    else if (length <= _minLength)
      score -= 10;

    final containsUppercaseLetters = password.contains(RegExp(r'[A-Z]'));
    final containsLowercaseLetters = password.contains(RegExp(r'[a-z]'));
    final containsNumbers = password.contains(RegExp(r'[0-9]'));
    final containsSpecialSymbols = password.contains(
      RegExp(r'[!@#$%^&*(),.?":{}|<]'),
    );
    final containsCommonPatterns = _containsCommonPatterns(password);

    if (containsUppercaseLetters) score += 20;
    if (containsLowercaseLetters) score += 20;
    if (containsNumbers) score += 20;
    if (containsSpecialSymbols) score += 20;
    if (containsCommonPatterns) score -= 15;

    score = score.clamp(0, _maxScore);

    final strength = _getStrengthFromScore(score);

    return SecurityData(
      strengthLevel: strength,
      score: score,
      length: length,
      containsUppercaseLetters: containsUppercaseLetters,
      containsLowercaseLetters: containsLowercaseLetters,
      containsNumbers: containsNumbers,
      containsSpecialSymbols: containsSpecialSymbols,
      containsCommonPatterns: containsCommonPatterns,
    );
  }

  static bool isWeak(String password) {
    final result = check(password);
    return result.strengthLevel == StrengthLevel.veryWeak ||
        result.strengthLevel == StrengthLevel.weak;
  }

  static bool _containsCommonPatterns(String password) {
    final regex = RegExp(
      _commonPatterns.map((pattern) => RegExp.escape(pattern)).join('|'),
    );
    return regex.hasMatch(password);
  }

  static StrengthLevel _getStrengthFromScore(int score) {
    if (score >= 90) return StrengthLevel.veryStrong;
    if (score >= 70) return StrengthLevel.strong;
    if (score >= 50) return StrengthLevel.moderate;
    if (score >= 30) return StrengthLevel.weak;
    return StrengthLevel.veryWeak;
  }
}
