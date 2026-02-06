import 'package:flutter/material.dart';
import 'package:safebox/custom_controls/base_screen.dart';
import 'package:safebox/custom_controls/tags_input.dart';
import 'package:safebox/l10n/strings.dart';
import 'package:safebox/services/storage/storable_item.dart';

final class EditItemScreen<T extends StorableItem<T>> extends BaseScreen<EditItemScreen<T>> {
  final T? item;
  final T Function() getNullObject;
  final T Function(T item) saveItem;
  final bool includeTags;
  final List<Widget> fields;

  const EditItemScreen({super.key, this.item, required this.getNullObject, required this.saveItem, required this.includeTags, required this.fields});

  @override
  State<EditItemScreen<T>> createState() => _EditItemScreenState<T>();
}

class _EditItemScreenState<T extends StorableItem<T>> extends BaseScreenState<EditItemScreen<T>> {
  static const _itemsSpacer = SizedBox(height: 16.0);

  late final _strings = Strings.of(context);
  late T _item;

  final _formKey = GlobalKey<FormState>();

  void _submit() {
    final isValid = _formKey.currentState?.validate();

    if (isValid == true) {
      _formKey.currentState!.save();
      _save();
    }
  }

  void _save() {
    final item = widget.saveItem(_item);
    Navigator.pop(context, item);
  }

  List<Widget> _generateFields() {
    final fields = <Widget>[];

    for (int i = 0; i < widget.fields.length; i++) {
      final field = widget.fields[i];
      fields.add(field);

      if (i < widget.fields.length - 1) {
        fields.add(_itemsSpacer);
      }
    }

    if (widget.includeTags) {
      fields.add(_itemsSpacer);
      fields.add(TagsInput(
        item: _item,
        onUpdate: (item) => setState(() => _item = item)
      ));
    }

    fields.add(const Spacer());
    fields.add(ElevatedButton(
      onPressed: _submit,
      child: Text(_strings.save)
    ));

    return fields;
  }

  @override
  void initState() {
    _item = widget.item ?? widget.getNullObject();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item == null ? _strings.add : _strings.edit),
      ),
      body: activityDetection(
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _generateFields(),
            ),
          ),
        )
      ),
    );
  }
}