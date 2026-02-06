import 'package:safebox/models/provide_fields/field_info.dart';

abstract interface class IFieldsProvider {
  List<FieldInfo> get propsInfo;
}