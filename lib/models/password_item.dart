import 'package:uuid/uuid.dart';

class PasswordItem {
  static const maxTagsCount = 3;

  final String id;
  final String login;
  final String password;
  final String url;
  final String description;
  String tags;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  PasswordItem._(
    this.id,
    this.login,
    this.password,
    this.url,
    this.description,
    this.tags,
    this.updatedAt,
    this.deletedAt,
  );

  factory PasswordItem.nullObject() =>
      PasswordItem._('', '', '', '', '', '', DateTime.now(), null);

  PasswordItem({
    String? id,
    required this.login,
    required this.password,
    required this.url,
    required this.description,
    required this.tags,
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
      tags: json['tags'] as String,
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
      'tags': tags,
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

  List<String> get tagList =>
      tags.isEmpty ? [] : tags.split(',').map((tag) => tag.trim()).toList();

  void addTag(String tag) {
    if (tagList.length < maxTagsCount &&
        !tagList.contains(tag) &&
        tag.isNotEmpty) {
      tags = '${tags.isNotEmpty ? '$tags, ' : ''}$tag';
    }
  }

  void removeTag(String tag) {
    tags = tagList.where((t) => t != tag).join(', ');
  }

  @override
  bool operator ==(Object other) {
    if (other is PasswordItem) {
      // ignore: unnecessary_this
      return other.id == this.id;
    }
    return super == other;
  }

  @override
  int get hashCode => Object.hash(id, updatedAt);
}
