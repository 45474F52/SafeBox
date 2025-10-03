import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:safebox/services/helpers/snackbar_provider.dart';

import '../l10n/strings.dart';
import '../screen/passphrase_generator_screen.dart';
import '../services/passwords/password_generator.dart';

class PasswordGeneratorTab extends StatefulWidget {
  const PasswordGeneratorTab({super.key});

  @override
  State<PasswordGeneratorTab> createState() => _PasswordGeneratorTabState();
}

class _PasswordGeneratorTabState extends State<PasswordGeneratorTab> {
  late final _strings = Strings.of(context);
  final _passGen = PasswordGenerator();

  String _generatedPassword = '';

  void _generatePassword() {
    try {
      final password = _passGen.generate();
      setState(() {
        _generatedPassword = password;
      });
    } on ArgumentError {
      SnackBarProvider.showWarning(context, _strings.selectLeastOneCharError);
    }
  }

  Future<void> _copyToClipboard() async {
    if (_generatedPassword.isNotEmpty) {
      await Clipboard.setData(ClipboardData(text: _generatedPassword));
      if (mounted) {
        SnackBarProvider.showSuccess(context, _strings.passwordCopied);
      }
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
            Text(
              _strings.generatorTabTitle,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            Text(_strings.passwordLength),
            Slider(
              value: _passGen.length.toDouble(),
              min: PasswordGenerator.minLength.toDouble(),
              max: PasswordGenerator.maxLength.toDouble(),
              divisions: 24,
              label: _passGen.length.toString(),
              onChanged: (value) =>
                  setState(() => _passGen.length = value.round()),
            ),

            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _buildCheckbox(
                  _strings.uppercase,
                  _passGen.includeUppercase,
                  (v) => setState(() => _passGen.includeUppercase = v ?? true),
                ),
                _buildCheckbox(
                  _strings.lowercase,
                  _passGen.includeLowercase,
                  (v) => setState(() => _passGen.includeLowercase = v ?? true),
                ),
                _buildCheckbox(
                  _strings.numbers,
                  _passGen.includeNumbers,
                  (v) => setState(() => _passGen.includeNumbers = v ?? true),
                ),
                _buildCheckbox(
                  _strings.symbols,
                  _passGen.includeSymbols,
                  (v) => setState(() => _passGen.includeSymbols = v ?? true),
                ),
                _buildCheckbox(
                  _strings.excludeAmbigious,
                  _passGen.excludeAmbiguous,
                  (v) => setState(() => _passGen.excludeAmbiguous = v ?? false),
                ),
              ],
            ),

            const SizedBox(height: 24),

            Center(
              child: ElevatedButton.icon(
                onPressed: _generatePassword,
                icon: const Icon(Icons.autorenew),
                label: Text(
                  _strings.generate,
                  style: TextStyle(fontSize: 18.0),
                ),
              ),
            ),

            const SizedBox(height: 24),

            Text(_strings.generatedPassword),
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
                label: Text(_strings.copy),
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
                label: Text(_strings.passphraseGenTitle),
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
