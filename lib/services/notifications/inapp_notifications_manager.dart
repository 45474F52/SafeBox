import 'package:flutter/material.dart';
import 'package:safebox/l10n/strings.dart';
import 'package:safebox/services/helpers/snackbar_provider.dart';

abstract final class InAppNotificationsManager {
  static bool _displayedOnce = false;

  static void showNotification(BuildContext context) {
    if (!_displayedOnce) {
      _displayedOnce = true;
      SnackBarProvider.showInfo(
        context,
        Strings.of(context).inAppNotificationMessage,
      );
    }
  }

  static void resetDisplayedOnceFlag() => _displayedOnce = false;
}
