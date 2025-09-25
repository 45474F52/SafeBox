import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

import 'package:safebox/screen/passphrase_generator_screen.dart';

class PasswordGeneratorTab extends StatefulWidget {
  const PasswordGeneratorTab({super.key});

  @override
  State<PasswordGeneratorTab> createState() => _PasswordGeneratorTabState();
}

class _PasswordGeneratorTabState extends State<PasswordGeneratorTab> {
  static const _minLength = 8;
  static const _maxLength = 32;
  int _length = 12;
  bool _includeUppercase = true;
  bool _includeLowercase = true;
  bool _includeNumbers = true;
  bool _includeSymbols = true;
  bool _excludeAmbiguous = false;

  String _generatedPassword = 'Нажмите "Сгенерировать"';

  final String _uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  final String _lowercase = 'abcdefghijklmnopqrstuvwxyz';
  final String _numbers = '0123456789';
  final String _symbols = '!@#\$%^&*()_+-={}|;:,.<>?';

  void _generatePassword() {
    String chars = '';
    if (_includeUppercase) chars += _uppercase;
    if (_includeLowercase) chars += _lowercase;
    if (_includeNumbers) chars += _numbers;
    if (_includeSymbols) chars += _symbols;

    if (chars.isEmpty) {
      setState(() {
        _generatedPassword = 'Выберите хотя бы один тип символов';
      });
      return;
    }

    if (_excludeAmbiguous) {
      chars = chars.replaceAll(RegExp(r'[0O1lI]'), '');
      if (chars.isEmpty) chars = _lowercase;
    }

    final random = Random();
    String password = List.generate(_length, (index) {
      return chars[random.nextInt(chars.length)];
    }).join();

    setState(() {
      _generatedPassword = password;
    });
  }

  Future<void> _copyToClipboard() async {
    if (_generatedPassword.contains('Нажмите') ||
        _generatedPassword.contains('Выберите')) {
      return;
    }
    await Clipboard.setData(ClipboardData(text: _generatedPassword));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Пароль скопирован'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.vpn_key, size: 64, color: primary),
            const SizedBox(height: 16),
            const Text(
              'Генератор паролей',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            const Text('Длина пароля:'),
            Slider(
              value: _length.toDouble(),
              min: _minLength.toDouble(),
              max: _maxLength.toDouble(),
              divisions: 24,
              label: _length.toString(),
              onChanged: (value) => setState(() => _length = value.round()),
            ),

            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _buildCheckbox(
                  'Заглавные',
                  _includeUppercase,
                  (v) => setState(() => _includeUppercase = v ?? true),
                ),
                _buildCheckbox(
                  'Строчные',
                  _includeLowercase,
                  (v) => setState(() => _includeLowercase = v ?? true),
                ),
                _buildCheckbox(
                  'Цифры',
                  _includeNumbers,
                  (v) => setState(() => _includeNumbers = v ?? true),
                ),
                _buildCheckbox(
                  'Символы',
                  _includeSymbols,
                  (v) => setState(() => _includeSymbols = v ?? true),
                ),
                _buildCheckbox(
                  'Исключить похожие (0,O,l,1)',
                  _excludeAmbiguous,
                  (v) => setState(() => _excludeAmbiguous = v ?? false),
                ),
              ],
            ),

            const SizedBox(height: 24),

            Center(
              child: ElevatedButton.icon(
                onPressed: _generatePassword,
                icon: const Icon(Icons.autorenew),
                label: const Text(
                  'Сгенерировать',
                  style: TextStyle(fontSize: 18.0),
                ),
              ),
            ),

            const SizedBox(height: 24),

            const Text('Сгенерированный пароль:'),
            const SizedBox(height: 8),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: SelectableText(
                  _generatedPassword,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 16,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),

            Center(
              child: TextButton.icon(
                onPressed: _copyToClipboard,
                icon: const Icon(Icons.copy, size: 16),
                label: const Text('Копировать'),
              ),
            ),
            const SizedBox(height: 8.0),

            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PassphraseGeneratorScreen(),
                    ),
                  );
                },
                icon: Icon(Icons.text_snippet),
                label: Text('Генератор парольных фраз'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckbox(
    String label,
    bool value,
    ValueChanged<bool?> onChanged,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(value: value, onChanged: onChanged),
        Text(label),
      ],
    );
  }
}
