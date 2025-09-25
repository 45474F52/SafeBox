class CsvProvider {
  static List<String> _getRows(String csv) {
    return csv.split('\n');
  }

  static List<String> _getRowData(String row) {
    return row.split(',');
  }

  static List<List<String>> convert(
    String csv, [
    bool removeTitle = true,
    bool trimLast = true,
  ]) {
    var rows = _getRows(csv);

    if (removeTitle) {
      rows = rows.sublist(1);
    }

    if (trimLast) {
      rows.removeLast();
    }

    return rows.map((row) => _getRowData(row)).toList();
  }
}
