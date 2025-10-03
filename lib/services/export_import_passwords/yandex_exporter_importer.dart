import 'dart:io';

import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import '../../models/yandex_password_entry.dart';
import '../helpers/csv_provider.dart';
import 'i_exporter_importer.dart';

class YandexExporterImporter implements IExporterImporter<YandexPasswordEntry> {
  static const _csvHeaders = ['url', 'username', 'password', 'comment', 'tags'];
  @override
  Future<String> export(List<YandexPasswordEntry> entries) async {
    final rows = entries.map((e) => e.toMap().values.toList());

    return const ListToCsvConverter().convert([_csvHeaders, ...rows]);
  }

  @override
  Future<List<YandexPasswordEntry>> import(String data) async {
    final csvTable = CsvProvider.convert(data);
    final headers = csvTable[0];
    return csvTable.skip(1).map((row) {
      final map = Map.fromIterables(headers, row);
      return YandexPasswordEntry.fromMap(map);
    }).toList();
  }

  @override
  Future<String> saveFile(String data, String filename) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}${Platform.pathSeparator}$filename');
    await file.writeAsString(data);
    return file.path;
  }

  @override
  Future<String> readFile(String filename) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}${Platform.pathSeparator}$filename');
    return await file.readAsString();
  }
}
