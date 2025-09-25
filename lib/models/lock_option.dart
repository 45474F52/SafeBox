// ignore_for_file: unnecessary_this

class LockOption {
  final String _alias;
  final Duration _duration;

  const LockOption(this._alias, this._duration);
  factory LockOption.parse(String value) {
    final minutes = int.tryParse(value);
    if (minutes != null) {
      return LockOption('$value мин.', Duration(minutes: minutes));
    }
    throw ArgumentError.value(value);
  }

  String get alias => _alias;
  Duration get duration => _duration;

  String get minutes => _alias.split(' ').first;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    } else {
      return other is LockOption &&
          other.minutes == this.minutes &&
          other._duration.inMinutes == this._duration.inMinutes;
    }
  }

  @override
  int get hashCode => Object.hash(_duration, minutes);
}
