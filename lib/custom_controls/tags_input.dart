import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../l10n/strings.dart';
import '../models/password_item.dart';

class TagsInput extends StatefulWidget {
  final PasswordItem item;
  final Function(PasswordItem) onUpdate;

  const TagsInput({super.key, required this.item, required this.onUpdate});

  @override
  State<StatefulWidget> createState() => _TagsInputState();
}

class _TagsInputState extends State<TagsInput> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8.0,
          children: widget.item.tagList.map((tag) {
            return InputChip(
              label: Text(tag),
              onDeleted: () {
                widget.item.removeTag(tag);
                widget.onUpdate(widget.item);
                setState(() {});
              },
            );
          }).toList(),
        ),

        if (widget.item.tagList.length < PasswordItem.maxTagsCount)
          TextField(
            controller: _controller,
            maxLength: 16,
            maxLengthEnforcement: MaxLengthEnforcement.enforced,
            decoration: InputDecoration(
              labelText: Strings.of(context).addTag,
              suffixIcon: IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  if (_controller.text.isNotEmpty) {
                    widget.item.addTag(_controller.text);
                    widget.onUpdate(widget.item);
                    setState(() {});
                    _controller.clear();
                  }
                },
              ),
            ),
            onSubmitted: (value) {
              if (value.isNotEmpty) {
                widget.item.addTag(value);
                widget.onUpdate(widget.item);
                setState(() {});
                _controller.clear();
              }
            },
          ),
      ],
    );
  }
}
