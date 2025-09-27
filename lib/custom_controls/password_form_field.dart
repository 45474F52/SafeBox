import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../l10n/strings.dart';
import '../services/passwords/password_generator.dart';

class PasswordFormField extends StatefulWidget {
  final TextEditingController? controller;

  const PasswordFormField({super.key, this.controller});

  @override
  State<PasswordFormField> createState() => _PasswordFormFieldState();
}

class _PasswordFormFieldState extends State<PasswordFormField> {
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
        labelText: Strings.of(context).password,
        hintText: Strings.of(context).enterPassword,
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.key),
              onPressed: () {
                _generatePassword();
              },
              tooltip: Strings.of(context).generate,
            ),

            IconButton(
              icon: Icon(_isObscured ? Icons.visibility_off : Icons.visibility),
              onPressed: () {
                setState(() {
                  _isObscured = !_isObscured;
                });
              },
              tooltip: _isObscured
                  ? Strings.of(context).showPassword
                  : Strings.of(context).hidePassword,
            ),

            IconButton(
              icon: const Icon(Icons.content_copy),
              onPressed: () async {
                if (_controller.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(Strings.of(context).emptyFieldError),
                      duration: Duration(seconds: 1),
                    ),
                  );
                  return;
                }

                final messenger = ScaffoldMessenger.of(context);

                await Clipboard.setData(ClipboardData(text: _controller.text));

                if (context.mounted) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(Strings.of(context).passwordCopied),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }

                FocusManager.instance.primaryFocus?.unfocus();
              },
              tooltip: Strings.of(context).copy,
            ),
          ],
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return Strings.of(context).enterPassword;
        }
        return null;
      },
    );
  }

  void _generatePassword() {
    try {
      _controller.text = _passGen.generate();
    } on ArgumentError {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(Strings.of(context).selectLeastOneCharError),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.yellow,
        ),
      );
    }
  }
}
