import '../../models/password_item.dart';

class ItemsMerger {
  static void sync(List<PasswordItem> first, List<PasswordItem> second) {
    if (second.isNotEmpty) {
      if (first.isEmpty) {
        first.addAll(second);
      } else {
        final merged = merge(first, second);
        first.clear();
        first.addAll(merged);
      }
    }
  }

  static List<PasswordItem> merge(
    List<PasswordItem> first,
    List<PasswordItem> second,
  ) {
    final Map<String, PasswordItem> map = {};

    for (final item in first) {
      map[item.id] = item;
    }

    for (final item in second) {
      final existing = map[item.id];

      if (existing == null) {
        if (item.deletedAt == null) {
          map[item.id] = item;
        }
      } else {
        if (item.updatedAt.isAfter(existing.updatedAt)) {
          map[item.id] = item;
        }
      }
    }

    return map.values.toList();
  }
}
