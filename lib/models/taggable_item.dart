abstract class TaggableItem {
  final int maxTagsCount;

  String _tags;
  String get tags => _tags;

  TaggableItem(this._tags, [this.maxTagsCount = 3]);

  List<String> get tagList =>
      tags.isEmpty ? [] : tags.split(',').map((tag) => tag.trim()).toList();

  void addTag(String tag) {
    if (tagList.length < maxTagsCount &&
        !tagList.contains(tag) &&
        tag.isNotEmpty) {
      _tags = '${tags.isNotEmpty ? '$tags, ' : ''}$tag';
    }
  }

  void removeTag(String tag) {
    _tags = tagList.where((t) => t != tag).join(', ');
  }
}
