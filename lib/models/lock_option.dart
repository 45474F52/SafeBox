// ignore_for_file: unnecessary_this

class LockOption {
  final Duration _duration;

  const LockOption._(this._duration);

  factory LockOption.fromMinutes(Duration duration) {
    if (duration.inMinutes > 0) {
      return LockOption._(duration);
    }
    throw ArgumentError.value(duration);
  }

  factory LockOption.nullObject() => LockOption._(Duration.zero);

  factory LockOption.parse(String value) {
    final minutes = int.tryParse(value);
    if (minutes != null) {
      return LockOption.fromMinutes(Duration(minutes: minutes));
    }
    throw ArgumentError.value(value);
  }

  Duration get duration => _duration;
  String get minutes => _duration.inMinutes.toString();

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
