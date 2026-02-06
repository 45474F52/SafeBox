import 'package:flutter/material.dart';
import 'package:safebox/models/provide_fields/i_fields_provider.dart';

abstract final class ItemFieldsFactory {
  static List<Widget> produceFields<T extends IFieldsProvider>({
    required T provider,
    required void Function(dynamic) onSaved,
    dynamic Function(int)? provideDecoration,
    Map<int, Widget>? customFields
  }) {
    final fields = <Widget>[];

    final infos = provider.propsInfo;

    if (customFields != null) {
      fields.setRange(start, end, iterable)
      for (int i = 0; i < infos.length; i++) {

      }
      
    }

    for (final info in provider.propsInfo) {
      late final Widget field;

      switch (info.fieldType) {
        case const (TextFormField):
          field = TextFormField(
            initialValue: info.value,
            onSaved: onSaved,
            decoration: provideDecoration == null
                ? const InputDecoration()
                : provideDecoration(info.index),
            keyboardType: info.keyboardtype
          );
          break;
        default:
          field = SizedBox();
          break;
      }

      fields.add(field);
    }

    return fields;
  }
}
