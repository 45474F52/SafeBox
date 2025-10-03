import 'package:flutter/material.dart';
import 'package:safebox/services/helpers/snackbar_provider.dart';

abstract final class InAppNotificationsManager {
  static void showNotification(BuildContext context) {
    SnackBarProvider.showInfo(
      context,
      'Нужно обновить пароли',
    ); // TODO: add translate
  }
}
