import 'package:safebox/models/i_synchronizable.dart';
import 'package:safebox/models/taggable_item.dart';

abstract class StorableItem<T extends StorableItem<T>> extends TaggableItem
    implements ISynchronizable {
  StorableItem(super.tags);
  String get id;
  DateTime? get deletedAt;
  Map<String, dynamic> toJson();
  T copyWith({String? id, DateTime? updatedAt, DateTime? deletedAt});
}
