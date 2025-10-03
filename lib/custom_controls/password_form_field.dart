import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:safebox/services/helpers/snackbar_provider.dart';
import '../l10n/strings.dart';
import '../services/passwords/password_generator.dart';

class PasswordFormField extends StatefulWidget {
  final TextEditingController? controller;

  const PasswordFormField({super.key, this.controller});

  @override
  State<PasswordFormField> createState() => _PasswordFormFieldState();
}

class _PasswordFormFieldState extends State<PasswordFormField> {
  late final _strings = Strings.of(context);
  final _passGen = PasswordGenerator();
  late final TextEditingController _controller;
  bool _isObscured = true;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      obscureText: _isObscured,
      decoration: InputDecoration(
        labelText: _strings.password,
        hintText: _strings.enterPassword,
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.key),
              onPressed: () {
                _generatePassword();
              },
              tooltip: _strings.generate,
            ),

            IconButton(
              icon: Icon(_isObscured ? Icons.visibility_off : Icons.visibility),
              onPressed: () {
                setState(() {
                  _isObscured = !_isObscured;
                });
              },
              tooltip: _isObscured
                  ? _strings.showPassword
                  : _strings.hidePassword,
            ),

            IconButton(
              icon: const Icon(Icons.content_copy),
              onPressed: () async {
                if (_controller.text.isEmpty) {
                  SnackBarProvider.showWarning(
                    context,
                    _strings.emptyFieldError,
                  );
                  return;
                }

                await Clipboard.setData(ClipboardData(text: _controller.text));

                if (context.mounted) {
                  SnackBarProvider.showSuccess(
                    context,
                    _strings.passwordCopied,
                  );
                }

                FocusManager.instance.primaryFocus?.unfocus();
              },
              tooltip: _strings.copy,
            ),
          ],
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return _strings.enterPassword;
        }
        return null;
      },
    );
  }

  void _generatePassword() {
    try {
      _controller.text = _passGen.generate();
    } on ArgumentError {
      SnackBarProvider.showWarning(context, _strings.selectLeastOneCharError);
    }
  }
}
