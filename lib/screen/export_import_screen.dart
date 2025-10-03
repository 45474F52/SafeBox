import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:safebox/services/helpers/snackbar_provider.dart';
import '../l10n/strings.dart';
import '../custom_controls/base_screen.dart';
import '../services/export_import_passwords/yandex_entries_converter.dart';
import '../services/export_import_passwords/yandex_exporter_importer.dart';
import '../services/security/password_storage.dart';

class ExportImportScreen extends BaseScreen<ExportImportScreen> {
  final PasswordStorage storage;

  const ExportImportScreen({super.key, required this.storage});

  @override
  State<StatefulWidget> createState() => _ExportImportScreenState();
}

class _ExportImportScreenState extends BaseScreenState<ExportImportScreen> {
  static const _filename = 'sb_exp.csv';
  late final _strings = Strings.of(context);

  final _provider = YandexExporterImporter();
  final _converter = YandexEntriesConverter();

  String _exported = '';
  bool _isLoading = false;
  String? _selectedFile;

  Future<void> _exportData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final passwords = await widget.storage.loadActive();
      final entries = _converter.convertFrom(passwords);
      final data = await _provider.export(entries);
      final path = await _provider.saveFile(data, _filename);
      setState(() {
        _exported = _strings.fileSaved;
      });
      if (mounted) {
        SnackBarProvider.showInfo(context, _strings.savedToMessage(path));
      }
    } catch (e) {
      if (mounted) {
        SnackBarProvider.provideException(context, e);
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _importData() async {
    if (_selectedFile == null || _selectedFile!.isEmpty) {
      if (mounted) {
        SnackBarProvider.showWarning(context, _strings.selectFileForImport);
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final data = await File(_selectedFile!).readAsString();
      final entries = await _provider.import(data);
      final passwords = _converter.convertTo(entries);
      await widget.storage.save(passwords);
      if (mounted) {
        SnackBarProvider.showSuccess(context, _strings.dataImported);
      }
    } catch (e) {
      if (mounted) {
        SnackBarProvider.provideException(context, e);
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null) {
      setState(() {
        _selectedFile = result.files.single.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_strings.exportImport)),
      body: activityDetection(
        Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton(
                onPressed: _exportData,
                child: Text(_strings.exportPasswords),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _pickFile,
                child: Text(_strings.selectFileForImport),
              ),
              if (_selectedFile != null && _selectedFile!.isNotEmpty)
                Text(
                  Strings.of(
                    context,
                  ).selectedFileMessage(_selectedFile!.split('/').last),
                  style: TextStyle(color: Colors.blueGrey),
                ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _importData,
                child: Text(_strings.importPasswords),
              ),
              SizedBox(height: 16.0),
              if (_exported.isNotEmpty)
                Text(_exported, style: TextStyle(color: Colors.green)),
              if (_isLoading) CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
