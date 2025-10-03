import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:safebox/l10n/locale_provider.dart';
import 'package:safebox/l10n/strings.dart';
import 'package:safebox/services/app_settings.dart';
import 'package:safebox/services/theme_provider.dart';
import 'custom_controls/login_widget.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await AppSettings.load();

  runApp(const SafeBoxApp());
}

final class SafeBoxApp extends StatelessWidget {
  const SafeBoxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Builder(
        builder: (context) {
          final localeProvider = Provider.of<LocaleProvider>(context);
          final themeProvider = Provider.of<ThemeProvider>(context);

          return MaterialApp(
            onGenerateTitle: (context) => Strings.of(context).appName,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            locale: localeProvider.locale,
            themeMode: themeProvider.theme,
            theme: ThemeData.light(useMaterial3: true),
            darkTheme: ThemeData.dark(useMaterial3: true),
            home: const LoginWidget(),
            debugShowCheckedModeBanner: kDebugMode,
          );
        },
      ),
    );
  }
}
