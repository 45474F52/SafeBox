import 'package:flutter/material.dart';
import 'package:safebox/screen/edit_password_screen.dart';
import 'package:safebox/l10n/strings.dart';
import 'package:safebox/custom_controls/base_screen.dart';
import 'package:safebox/services/passwords/strength/password_security_checker.dart';
import 'package:safebox/services/passwords/strength/strength_level.dart';
import 'package:safebox/services/storage/passwords_storage.dart';
import 'package:safebox/models/password_item.dart';

class PasswordSecurityScreen extends BaseScreen<PasswordSecurityScreen> {
  final PasswordsStorage storage;

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

  Future<void> _refresh() async {
    setState(() {
      _futurePasswords = widget.storage.loadActive().then((passwords) {
        _totalCount = passwords.length;
        _weakCount = passwords
            .where((item) => PasswordSecurityChecker.isWeak(item.password))
            .length;
        return passwords;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _refresh();
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
                      final result = PasswordSecurityChecker.check(
                        item.password,
                      );

                      final text = _getTextFromStrength(result.strengthLevel);

                      return ListTile(
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _hideWithMask(item.login),
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 8.0),
                                Text(
                                  '(${item.url})',
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 4.0),
                            Text(
                              _hideWithMask(item.password),
                              style: TextStyle(
                                fontSize: 14.0,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        subtitle: Row(
                          children: [
                            Expanded(
                              child: LinearProgressIndicator(
                                value: result.progress,
                                backgroundColor: Colors.grey,
                                valueColor: AlwaysStoppedAnimation(
                                  result.color,
                                ),
                              ),
                            ),
                            SizedBox(width: 16.0),
                            Text(
                              text,
                              style: TextStyle(
                                fontSize: 14.0,
                                color: result.color,
                              ),
                            ),
                          ],
                        ),
                        onTap: () async {
                          final updated = await Navigator.push<PasswordItem>(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EditPasswordScreen(item: item),
                            ),
                          );

                          if (updated != null) {
                            await widget.storage.updateItem(updated);
                            _refresh();
                          }
                        },
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
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
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

  String _hideWithMask(String text) {
    final mask = '****';
    if (text.length >= 6) {
      final prefix = text.substring(0, 3);
      final suffix = text.substring(text.length - 3);
      return '$prefix$mask$suffix';
    } else {
      return mask;
    }
  }
}
