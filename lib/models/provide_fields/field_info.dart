import 'package:flutter/widgets.dart';

class FieldInfo {
  final int index;
  final Type propertyType;
  final Type fieldType;
  final dynamic value;
  final TextInputType keyboardtype;

  const FieldInfo({
    required this.index,
    required this.propertyType,
    required this.fieldType,
    required this.value,
    required this.keyboardtype
  });
}
