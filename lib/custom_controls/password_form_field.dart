import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PasswordFormField extends StatefulWidget {
  final TextEditingController? controller;

  const PasswordFormField({super.key, this.controller});

  @override
  State<PasswordFormField> createState() => _PasswordFormFieldState();
}

class _PasswordFormFieldState extends State<PasswordFormField> {
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
        labelText: 'Пароль',
        hintText: 'Введите пароль',
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Кнопка: Показать/скрыть
            IconButton(
              icon: Icon(_isObscured ? Icons.visibility_off : Icons.visibility),
              onPressed: () {
                setState(() {
                  _isObscured = !_isObscured;
                });
              },
              tooltip: _isObscured ? 'Показать пароль' : 'Скрыть пароль',
            ),

            // Кнопка: Скопировать
            IconButton(
              icon: const Icon(Icons.content_copy),
              onPressed: () async {
                if (_controller.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Поле пустое'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                  return;
                }

                final messenger = ScaffoldMessenger.of(context);

                await Clipboard.setData(ClipboardData(text: _controller.text));

                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Пароль скопирован'),
                    duration: Duration(seconds: 2),
                  ),
                );

                FocusManager.instance.primaryFocus?.unfocus();
              },
              tooltip: 'Скопировать пароль',
            ),
          ],
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Введите пароль';
        }
        return null;
      },
    );
  }
}
