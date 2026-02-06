import 'dart:convert';
import 'dart:typed_data';

abstract final class ItemsConverter {
  static Uint8List itemsToBytes<T>(
    List<T> items,
    Map<String, dynamic> Function(T) toJSON,
  ) {
    final jsonList = jsonEncode(items.map((item) => toJSON(item)).toList());
    return Uint8List.fromList(utf8.encode(jsonList));
  }

  static List<T> bytesToItems<T>(
    Uint8List bytes,
    T Function(Map<String, dynamic>) fromJSON,
  ) {
    if (bytes.isNotEmpty) {
      final jsonString = utf8.decode(bytes);
      final jsonList = jsonDecode(jsonString) as List;
      return jsonList.map((json) => fromJSON(json)).toList();
    }
    return [];
  }
}
