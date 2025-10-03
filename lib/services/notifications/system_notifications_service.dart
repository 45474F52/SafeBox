import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:safebox/services/security/password_storage.dart';

abstract final class SystemNotificationsService {
  static const _notificationChannelID = 'SB_N.Y_CHID';
  static const _notificationChannelName = 'SafeBox Notifications';

  static final FlutterLocalNotificationsPlugin
  _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  static late PasswordStorage _passwordStorage;

  static Future<void> init(PasswordStorage passwordStorage) async {
    _passwordStorage = passwordStorage;

    const androidInitSettings = AndroidInitializationSettings(
      '@mipmap/launcher_icon',
    );

    final linuxInitSettings = LinuxInitializationSettings(
      defaultActionName: 'Ok',
      defaultIcon: AssetsLinuxIcon('assets/icons/appicon.png'),
    );

    final initSettings = InitializationSettings(
      android: androidInitSettings,
      linux: linuxInitSettings,
    );

    await _flutterLocalNotificationsPlugin.initialize(initSettings);
  }

  static Future<void> scheduleDailyNotification(PasswordStorage storage) async {
    await init(storage);

    if (await _needsPasswordsUpdate()) {
      await _scheduleNotification();
    }
  }

  static Future<void> _scheduleNotification() async {
    const androidChannelSpec = AndroidNotificationDetails(
      _notificationChannelID,
      _notificationChannelName,
      channelDescription:
          'SafeBox notifications channels', // TODO: add translate
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    const linuxChannelSpec = LinuxNotificationDetails(
      category: LinuxNotificationCategory.im,
      urgency: LinuxNotificationUrgency.normal,
    );

    const platformChannelSpec = NotificationDetails(
      android: androidChannelSpec,
      linux: linuxChannelSpec,
    );

    // TODO: add translate
    // TODO: schedule linux notifications

    if (Platform.isAndroid) {
      await _flutterLocalNotificationsPlugin.periodicallyShow(
        0,
        'Update passwords',
        'Check your passwords for update',
        RepeatInterval.daily,
        platformChannelSpec,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } else {
      await _flutterLocalNotificationsPlugin.show(
        0,
        'Update passwords',
        'Check your passwords for update',
        platformChannelSpec,
      );
    }
  }

  static Future<bool> _needsPasswordsUpdate() async {
    return await _passwordStorage.needUpdateAny();
  }

  static Future<void> cancelAll() async =>
      await _flutterLocalNotificationsPlugin.cancelAll();
}
