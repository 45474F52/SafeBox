import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../custom_controls/base_screen.dart';
import '../l10n/strings.dart';

class PassphraseGeneratorScreen extends BaseScreen<PassphraseGeneratorScreen> {
  const PassphraseGeneratorScreen({super.key});

  @override
  State<StatefulWidget> createState() => _PassphraseGeneratorScreenState();
}

class _PassphraseGeneratorScreenState
    extends BaseScreenState<PassphraseGeneratorScreen> {
  static const _maxLength = 64;
  int _wordCount = 4;
  String _generatedPhrase = '';
  List<String> _customWords = [];

  final _wordController = TextEditingController();
  final List<String> _defaultWordList = [
    'apple',
    'banana',
    'cherry',
    'date',
    'elderberry',
    'fig',
    'grape',
    'honeydew',
    'kiwi',
    'lemon',
    'mango',
    'nectarine',
    'orange',
    'papaya',
    'quince',
    'raspberry',
    'strawberry',
    'tangerine',
    'ugli',
    'vanilla',
    'watermelon',
    'xigua',
    'yam',
    'zucchini',
  ];

  void _generatePassphrase() {
    if (_customWords.isEmpty) {
      _customWords = _defaultWordList;
    }
    final random = Random();
    String passphrase = List.generate(
      _wordCount,
      (index) => _customWords[random.nextInt(_customWords.length)],
    ).join('-');
    if (passphrase.length >= _maxLength) {
      passphrase = passphrase.substring(0, _maxLength);
      if (passphrase.endsWith('-')) {
        passphrase = passphrase.substring(0, passphrase.length);
      }
    }
    setState(() {
      _generatedPhrase = passphrase;
    });
  }

  void _addCustomWord() {
    if (_wordController.text.isNotEmpty) {
      setState(() {
        _customWords.add(_wordController.text.toLowerCase());
        _wordController.clear();
      });
    }
  }

  Future<void> _copyToClipboard() async {
    if (_generatedPhrase.isNotEmpty) {
      try {
        await Clipboard.setData(ClipboardData(text: _generatedPhrase));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(Strings.of(context).passphraseCopied),
              duration: Duration(seconds: 1),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(Strings.of(context).errorMsg(e)),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(Strings.of(context).passphraseGenTitle)),
      body: activityDetection(
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(Strings.of(context).wordsCount),
              Slider(
                value: _wordCount.toDouble(),
                min: 2.0,
                max: 8.0,
                divisions: 6,
                label: _wordCount.toString(),
                onChanged: (value) =>
                    setState(() => _wordCount = value.round()),
              ),
              const SizedBox(height: 16.0),

              TextField(
                controller: _wordController,
                decoration: InputDecoration(
                  labelText: Strings.of(context).addYourWord,
                  suffixIcon: IconButton(
                    onPressed: _addCustomWord,
                    icon: Icon(Icons.add),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(Strings.of(context).yourWords),
                  TextButton.icon(
                    onPressed: () => setState(() {
                      _customWords.clear();
                    }),
                    label: Text(Strings.of(context).clear),
                    icon: Icon(Icons.delete),
                  ),
                ],
              ),

              Flexible(
                fit: FlexFit.loose,
                flex: 1,
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  itemCount: _customWords.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(_customWords[index]),
                      trailing: IconButton(
                        onPressed: () =>
                            setState(() => _customWords.removeAt(index)),
                        icon: Icon(Icons.delete),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24.0),

              Center(
                child: ElevatedButton.icon(
                  onPressed: _generatePassphrase,
                  icon: Icon(Icons.autorenew),
                  label: Text(
                    Strings.of(context).generate,
                    style: TextStyle(fontSize: 18.0),
                  ),
                ),
              ),
              const SizedBox(height: 24.0),

              Text(Strings.of(context).generatedPassphrase),
              const SizedBox(height: 8.0),

              Card(
                elevation: 2.0,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: SelectableText(
                    _generatedPhrase,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 16.0,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8.0),

              Center(
                child: TextButton.icon(
                  onPressed: _copyToClipboard,
                  label: Text(Strings.of(context).copy),
                  icon: Icon(Icons.copy, size: 16.0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
