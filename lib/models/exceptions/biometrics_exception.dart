class BiometricsException implements Exception {
  final String _message;
  BiometricsException(this._message);
  @override
  String toString() => _message;
}
