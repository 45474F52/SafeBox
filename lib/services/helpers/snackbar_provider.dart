import 'package:flutter/material.dart';
import 'package:safebox/l10n/strings.dart';

abstract class SnackBarProvider {
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> show(
    BuildContext context,
    SnackBar snackBar, {
    AnimationStyle? snackBarAnimationStyle,
  }) {
    return ScaffoldMessenger.of(
      context,
    ).showSnackBar(snackBar, snackBarAnimationStyle: snackBarAnimationStyle);
  }

  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSimple(
    BuildContext context,
    String text,
  ) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showInfo(
    BuildContext context,
    String text,
  ) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(text), backgroundColor: Colors.blue));

  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSuccess(
    BuildContext context,
    String text,
  ) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(text), backgroundColor: Colors.green));

  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showWarning(
    BuildContext context,
    String text,
  ) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(text), backgroundColor: Colors.orange));

  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showError(
    BuildContext context,
    String text,
  ) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(text), backgroundColor: Colors.red));

  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason>
  provideException(
    BuildContext context,
    Object e, [
    int durationInMinutes = 2,
  ]) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(Strings.of(context).errorMsg(e.toString())),
      backgroundColor: Colors.red,
      duration: Duration(minutes: durationInMinutes),
    ),
  );
}
