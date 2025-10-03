import 'package:flutter/material.dart';
import 'package:safebox/custom_controls/base_screen.dart';
import 'package:safebox/custom_controls/tags_input.dart';
import 'package:safebox/l10n/strings.dart';
import 'package:safebox/models/bank_card.dart';

class EditBankCardScreen extends BaseScreen<EditBankCardScreen> {
  final BankCard? item;

  const EditBankCardScreen({super.key, this.item});

  @override
  State<StatefulWidget> createState() => _EditBankCardScreenState();
}

class _EditBankCardScreenState extends BaseScreenState<EditBankCardScreen> {
  late final _strings = Strings.of(context);
  late BankCard _item;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    _item = widget.item ?? BankCard.nullObject();
  }

  void _submit() {
    final isValid = _formKey.currentState?.validate();

    if (isValid == true) {
      _formKey.currentState!.save();
      _save();
    }
  }

  void _save() {
    final item = BankCard(
      id: widget.item?.id,
      number: _item.number,
      validityPeriod: _item.validityPeriod,
      owner: _item.owner,
      title: _item.title,
      description: _item.description,
      tags: _item.tags,
    );
    Navigator.pop(context, item);
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
              children: [
                TextFormField(
                  initialValue: _item.number,
                  onSaved: (number) => _item = _item.copyWith(number: number),
                  decoration: const InputDecoration(labelText: 'Номер карты'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16.0),
                InputDatePickerFormField(
                  initialDate: _item.validityPeriod,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2099),
                  onDateSaved: (value) =>
                      _item = _item.copyWith(validityPeriod: value),
                  fieldLabelText: 'Срок действия',
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  initialValue: _item.owner,
                  onSaved: (owner) => _item = _item.copyWith(owner: owner),
                  decoration: const InputDecoration(labelText: 'Имя владельца'),
                  keyboardType: TextInputType.name,
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  initialValue: _item.title,
                  onSaved: (title) => _item = _item.copyWith(title: title),
                  decoration: const InputDecoration(labelText: 'Название'),
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  initialValue: _item.description,
                  onSaved: (value) =>
                      _item = _item.copyWith(description: value),
                  decoration: const InputDecoration(labelText: 'Описание'),
                  keyboardType: TextInputType.multiline,
                  maxLines: 2,
                  minLines: 1,
                ),
                const SizedBox(height: 16.0),
                TagsInput(
                  item: _item,
                  onUpdate: <T>(item) => setState(() => _item = item),
                ),
                const Spacer(),
                ElevatedButton(onPressed: _submit, child: Text(_strings.save)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
