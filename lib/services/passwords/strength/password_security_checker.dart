// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:safebox/services/passwords/strength/strength_level.dart';

class PasswordSecurityChecker {
  static const _minLength = 8;
  static const _maxScore = 100;

  static StrengthLevel check(String password) {
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

    if (password.contains(RegExp(r'[A-Z]'))) score += 20;
    if (password.contains(RegExp(r'[a-z]'))) score += 20;
    if (password.contains(RegExp(r'[0-9]'))) score += 20;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<]'))) score += 20;

    if (_containsCommonPatterns(password)) score -= 15;

    score = score.clamp(0, _maxScore);

    return _getStrengthFromScore(score);
  }

  static bool _containsCommonPatterns(String password) {
    return password.contains(RegExp(r'123|qwerty|password|admin'));
  }

  static StrengthLevel _getStrengthFromScore(int score) {
    if (score >= 90) return StrengthLevel.veryStrong;
    if (score >= 70) return StrengthLevel.strong;
    if (score >= 50) return StrengthLevel.moderate;
    if (score >= 30) return StrengthLevel.weak;
    return StrengthLevel.veryWeak;
  }
}
