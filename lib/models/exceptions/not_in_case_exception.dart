class NotInCaseException implements Exception {
  final Enum _state;

  const NotInCaseException(this._state);

  Enum get state => _state;

  @override
  String toString() => 'State "$_state" not supported';
}
