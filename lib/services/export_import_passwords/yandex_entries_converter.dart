import 'package:safebox/models/password_item.dart';
import 'package:safebox/services/export_import_passwords/i_entries_converter.dart';

import '../../models/yandex_password_entry.dart';

class YandexEntriesConverter implements IEntriesConverter<YandexPasswordEntry> {
  @override
  List<PasswordItem> convertTo(List<YandexPasswordEntry> entries) => entries
      .map(
        (item) => PasswordItem(
          login: item.username,
          password: item.password,
          url: item.url,
          description: item.comment,
        ),
      )
      .toList();

  @override
  List<YandexPasswordEntry> convertFrom(List<PasswordItem> passwords) =>
      passwords
          .map(
            (item) => YandexPasswordEntry(
              url: item.url,
              username: item.login,
              password: item.password,
              comment: item.description,
              tags: Uri.tryParse(item.url)?.host ?? '',
            ),
          )
          .toList();
}
