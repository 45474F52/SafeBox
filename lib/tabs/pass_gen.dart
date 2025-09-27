import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/strings.dart';
import '../screen/passphrase_generator_screen.dart';
import '../services/passwords/password_generator.dart';

class PasswordGeneratorTab extends StatefulWidget {
  const PasswordGeneratorTab({super.key});

  @override
  State<PasswordGeneratorTab> createState() => _PasswordGeneratorTabState();
}

class _PasswordGeneratorTabState extends State<PasswordGeneratorTab> {
  final _passGen = PasswordGenerator();

  String _generatedPassword = '';

  void _generatePassword() {
    try {
      final password = _passGen.generate();
      setState(() {
        _generatedPassword = password;
      });
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

  Future<void> _copyToClipboard() async {
    if (_generatedPassword.isNotEmpty) {
      await Clipboard.setData(ClipboardData(text: _generatedPassword));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(Strings.of(context).passwordCopied),
            duration: Duration(seconds: 1),
          ),
        );
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
              Strings.of(context).generatorTabTitle,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            Text(Strings.of(context).passwordLength),
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
                  Strings.of(context).uppercase,
                  _passGen.includeUppercase,
                  (v) => setState(() => _passGen.includeUppercase = v ?? true),
                ),
                _buildCheckbox(
                  Strings.of(context).lowercase,
                  _passGen.includeLowercase,
                  (v) => setState(() => _passGen.includeLowercase = v ?? true),
                ),
                _buildCheckbox(
                  Strings.of(context).numbers,
                  _passGen.includeNumbers,
                  (v) => setState(() => _passGen.includeNumbers = v ?? true),
                ),
                _buildCheckbox(
                  Strings.of(context).symbols,
                  _passGen.includeSymbols,
                  (v) => setState(() => _passGen.includeSymbols = v ?? true),
                ),
                _buildCheckbox(
                  Strings.of(context).excludeAmbigious,
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
                  Strings.of(context).generate,
                  style: TextStyle(fontSize: 18.0),
                ),
              ),
            ),

            const SizedBox(height: 24),

            Text(Strings.of(context).generatedPassword),
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
                label: Text(Strings.of(context).copy),
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
                label: Text(Strings.of(context).passphraseGenTitle),
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
