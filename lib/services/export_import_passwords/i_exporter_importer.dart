abstract interface class IExporterImporter<T> {
  Future<String> export(List<T> entires);
  Future<List<T>> import(String data);
  Future<void> saveFile(String data, String filename);
  Future<String> readFile(String filename);
}
