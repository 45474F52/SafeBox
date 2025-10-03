import '../../models/i_synchronizable.dart';

class ItemsMerger {
  static void sync<T extends ISynchronizable>(List<T> first, List<T> second) {
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

  static List<T> merge<T extends ISynchronizable>(
    List<T> first,
    List<T> second,
  ) {
    final Map<String, T> map = {};

    for (final item in first) {
      map[item.identifier] = item;
    }

    for (final item in second) {
      final existing = map[item.identifier];

      if (existing == null) {
        if (item.isDeleted) {
          map[item.identifier] = item;
        }
      } else {
        if (item.lastUpdate.isAfter(existing.lastUpdate)) {
          map[item.identifier] = item;
        }
      }
    }

    return map.values.toList();
  }
}
