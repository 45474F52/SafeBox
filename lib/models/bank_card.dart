// ignore_for_file: unnecessary_this

import 'package:safebox/models/i_synchronizable.dart';
import 'package:safebox/models/taggable_item.dart';
import 'package:uuid/uuid.dart';

class BankCard extends TaggableItem implements ISynchronizable {
  final String id;
  final String number;
  final DateTime validityPeriod;
  final String owner;
  final String title;
  final String description;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  BankCard._(
    this.id,
    this.number,
    this.validityPeriod,
    this.owner,
    this.title,
    this.description,
    String tags,
    this.updatedAt,
    this.deletedAt,
  ) : super(tags);

  factory BankCard.nullObject() =>
      BankCard._('', '', DateTime.now(), '', '', '', '', DateTime.now(), null);

  BankCard({
    String? id,
    required this.number,
    required this.validityPeriod,
    required this.owner,
    required this.title,
    required this.description,
    required String tags,
    DateTime? updatedAt,
    this.deletedAt,
  }) : this.id = id ?? Uuid().v4(),
       this.updatedAt = updatedAt ?? DateTime.now(),
       super(tags);

  factory BankCard.fromJSON(Map<String, dynamic> json) {
    return BankCard(
      id: json['id'],
      number: json['number'],
      validityPeriod: DateTime.parse(json['validity_period']),
      owner: json['owner'],
      title: json['title'],
      description: json['description'],
      tags: json['tags'],
      updatedAt: DateTime.parse(json['updated_at']),
      deletedAt: DateTime.tryParse(json['deleted_at'] ?? ''),
    );
  }

  Map<String, dynamic> toJSON() {
    return {
      'id': id,
      'number': number,
      'validity_period': validityPeriod.toIso8601String(),
      'owner': owner,
      'title': title,
      'description': description,
      'tags': tags,
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  BankCard copyWith({
    String? id,
    String? number,
    DateTime? validityPeriod,
    String? owner,
    String? title,
    String? description,
    String? tags,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return BankCard(
      id: id ?? this.id,
      number: number ?? this.number,
      validityPeriod: validityPeriod ?? this.validityPeriod,
      owner: owner ?? this.owner,
      title: title ?? this.title,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      updatedAt: updatedAt ?? DateTime.now(),
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is BankCard) {
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
