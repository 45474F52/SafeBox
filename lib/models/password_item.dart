// ignore_for_file: unnecessary_this

import 'package:safebox/services/storage/storable_item.dart';
import 'package:uuid/uuid.dart';

class PasswordItem extends StorableItem<PasswordItem> {
  @override
  final String id;
  final String login;
  final String password;
  final String url;
  final String description;
  final DateTime updatedAt;
  @override
  final DateTime? deletedAt;

  PasswordItem._(
    this.id,
    this.login,
    this.password,
    this.url,
    this.description,
    String tags,
    this.updatedAt,
    this.deletedAt,
  ) : super(tags);

  factory PasswordItem.nullObject() =>
      PasswordItem._('', '', '', '', '', '', DateTime.now(), null);

  PasswordItem({
    String? id,
    required this.login,
    required this.password,
    required this.url,
    required this.description,
    required String tags,
    DateTime? updatedAt,
    this.deletedAt,
  }) : this.id = id ?? Uuid().v4(),
       this.updatedAt = updatedAt ?? DateTime.now(),
       super(tags);

  factory PasswordItem.fromJson(Map<String, dynamic> json) {
    return PasswordItem(
      id: json['id'] as String,
      login: json['login'] as String,
      password: json['password'] as String,
      url: json['url'] as String,
      description: json['description'] as String,
      tags: json['tags'] as String,
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: DateTime.tryParse(
        json['deleted_at'] == null ? '' : json['deleted_at'] as String,
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'login': login,
      'password': password,
      'url': url,
      'description': description,
      'tags': tags,
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  @override
  PasswordItem copyWith({
    String? id,
    String? login,
    String? password,
    String? url,
    String? description,
    String? tags,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return PasswordItem(
      id: id ?? this.id,
      login: login ?? this.login,
      password: password ?? this.password,
      url: url ?? this.url,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      updatedAt: updatedAt ?? DateTime.now(),
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is PasswordItem) {
      return other.id == this.id;
    }
    return super == other;
  }

  @override
  int get hashCode => Object.hash(id, updatedAt);

  @override
  String get identifier => id;

  @override
  bool get isDeleted => deletedAt != null;

  @override
  DateTime get lastUpdate => updatedAt;
}
