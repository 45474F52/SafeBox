import 'package:uuid/uuid.dart';

class PasswordItem {
  final String id;
  final String login;
  final String password;
  final String url;
  final String description;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  PasswordItem({
    String? id,
    required this.login,
    required this.password,
    required this.url,
    required this.description,
    DateTime? updatedAt,
    this.deletedAt,
    // ignore: unnecessary_this
  }) : this.id = id ?? Uuid().v4(),
       // ignore: unnecessary_this
       this.updatedAt = updatedAt ?? DateTime.now();

  factory PasswordItem.fromJSON(Map<String, dynamic> json) {
    return PasswordItem(
      id: json['id'] as String,
      login: json['login'] as String,
      password: json['password'] as String,
      url: json['url'] as String,
      description: json['description'] as String,
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: DateTime.tryParse(
        json['deleted_at'] == null ? '' : json['deleted_at'] as String,
      ),
    );
  }

  Map<String, dynamic> toJSON() {
    return {
      'id': id,
      'login': login,
      'password': password,
      'url': url,
      'description': description,
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  PasswordItem copyWith({
    String? id,
    String? login,
    String? password,
    String? url,
    String? description,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return PasswordItem(
      id: id ?? this.id,
      login: login ?? this.login,
      password: password ?? this.password,
      url: url ?? this.url,
      description: description ?? this.description,
      updatedAt: updatedAt ?? DateTime.now(),
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}
