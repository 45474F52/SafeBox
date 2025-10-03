import 'package:flutter/material.dart';
import '../l10n/strings.dart';
import '../custom_controls/base_screen.dart';
import '../services/passwords/strength/password_security_checker.dart';
import '../services/passwords/strength/strength_level.dart';
import '../services/security/password_storage.dart';
import '../models/password_item.dart';

class PasswordSecurityScreen extends BaseScreen<PasswordSecurityScreen> {
  final PasswordStorage storage;

  const PasswordSecurityScreen({super.key, required this.storage});

  @override
  State<StatefulWidget> createState() => _PasswordSecurityScreenState();
}

class _PasswordSecurityScreenState
    extends BaseScreenState<PasswordSecurityScreen> {
  late final _strings = Strings.of(context);
  late Future<List<PasswordItem>> _futurePasswords;
  int _totalCount = 0;
  int _weakCount = 0;

  @override
  void initState() {
    super.initState();
    _futurePasswords = widget.storage.loadActive().then((passwords) {
      setState(() {
        _totalCount = passwords.length;
        _weakCount = passwords.where((item) {
          final strength = PasswordSecurityChecker.check(item.password);
          return strength == StrengthLevel.veryWeak ||
              strength == StrengthLevel.weak;
        }).length;
      });
      return passwords;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_strings.securityStatsTitle)),
      body: activityDetection(
        FutureBuilder(
          future: _futurePasswords,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text(_strings.errorMsg(snapshot.error!)));
            }
            if (!snapshot.hasData) {
              return Center(child: Text(_strings.noDataError));
            }
            final passwords = snapshot.data!;

            return Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    itemCount: passwords.length,
                    itemBuilder: (context, index) {
                      final item = passwords[index];
                      final strength = PasswordSecurityChecker.check(
                        item.password,
                      );

                      final color = _getColorFromStrength(strength);
                      final text = _getTextFromStrength(strength);
                      final progress = _getProgressFromStrength(strength);

                      return ListTile(
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.url,
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4.0),
                            Text(
                              item.password.length >= 6
                                  ? '${item.password.substring(0, 3)}****${item.password.substring(item.password.length - 3)}'
                                  : '****',
                              style: TextStyle(
                                fontSize: 14.0,
                                color: const Color.fromARGB(255, 116, 116, 116),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Row(
                          children: [
                            Expanded(
                              child: LinearProgressIndicator(
                                value: progress,
                                backgroundColor: Colors.grey,
                                valueColor: AlwaysStoppedAnimation(color),
                              ),
                            ),
                            SizedBox(width: 16.0),
                            Text(
                              text,
                              style: TextStyle(fontSize: 14.0, color: color),
                            ),
                          ],
                        ),
                      );
                    },
                    separatorBuilder: (_, _) => Divider(),
                  ),
                ),
                Padding(
                  padding: EdgeInsetsGeometry.all(16.0),
                  child: Text(
                    Strings.of(
                      context,
                    ).statsSummaryMessage(_totalCount, _weakCount),
                    style: TextStyle(
                      fontSize: 14,
                      color: const Color.fromARGB(255, 116, 116, 116),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  static Color _getColorFromStrength(StrengthLevel strength) {
    switch (strength) {
      case StrengthLevel.veryWeak:
        return Colors.red;
      case StrengthLevel.weak:
        return Colors.orange;
      case StrengthLevel.moderate:
        return Colors.yellow;
      case StrengthLevel.strong:
        return Colors.green;
      case StrengthLevel.veryStrong:
        return const Color.fromARGB(255, 50, 126, 52);
    }
  }

  String _getTextFromStrength(StrengthLevel strength) {
    switch (strength) {
      case StrengthLevel.veryWeak:
        return _strings.veryWeakLevelText;
      case StrengthLevel.weak:
        return _strings.weakLevelText;
      case StrengthLevel.moderate:
        return _strings.moderateLevelText;
      case StrengthLevel.strong:
        return _strings.strongLevelText;
      case StrengthLevel.veryStrong:
        return _strings.veryStrongLevelText;
    }
  }

  static double _getProgressFromStrength(StrengthLevel strength) {
    switch (strength) {
      case StrengthLevel.veryWeak:
        return 0.1;
      case StrengthLevel.weak:
        return 0.3;
      case StrengthLevel.moderate:
        return 0.5;
      case StrengthLevel.strong:
        return 0.8;
      case StrengthLevel.veryStrong:
        return 1.0;
    }
  }
}
