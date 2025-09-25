class YandexPasswordEntry {
  final String url;
  final String username;
  final String password;
  final String comment;
  final String tags;

  YandexPasswordEntry({
    required this.url,
    required this.username,
    required this.password,
    required this.comment,
    required this.tags,
  });

  factory YandexPasswordEntry.fromMap(Map map) {
    return YandexPasswordEntry(
      url: map['url'],
      username: map['username'],
      password: map['password'],
      comment: map['comment'],
      tags: map['tags'],
    );
  }

  YandexPasswordEntry fromMap(Map map) => YandexPasswordEntry.fromMap(map);

  Map toMap() {
    return {
      'url': url,
      'username': username,
      'password': password,
      'comment': comment,
      'tags': tags,
    };
  }
}
