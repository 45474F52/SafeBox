import 'package:safebox/models/password_item.dart';

abstract interface class IEntriesConverter<T> {
  List<PasswordItem> convertTo(List<T> entries);
  List<T> convertFrom(List<PasswordItem> passwords);
}
