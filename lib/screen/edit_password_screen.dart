import 'package:flutter/material.dart';
import '../l10n/strings.dart';
import '../custom_controls/base_screen.dart';
import '../custom_controls/password_form_field.dart';
import '../custom_controls/tags_input.dart';
import '../models/password_item.dart';

class EditPasswordScreen extends BaseScreen<EditPasswordScreen> {
  final PasswordItem? item;

  const EditPasswordScreen({super.key, this.item});

  @override
  State<EditPasswordScreen> createState() => _EditPasswordScreenState();
}

class _EditPasswordScreenState extends BaseScreenState<EditPasswordScreen> {
  late PasswordItem _item;
  late TextEditingController _passwordCtrl;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    _item = widget.item ?? PasswordItem.nullObject();
    _passwordCtrl = TextEditingController(text: _item.password);
  }

  @override
  void dispose() {
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final isValid = _formKey.currentState?.validate();

    if (isValid == true) {
      _formKey.currentState!.save();
      _save();
    }
  }

  void _save() {
    final item = PasswordItem(
      id: widget.item?.id,
      login: _item.login,
      password: _passwordCtrl.text,
      url: _item.url,
      description: _item.description,
      tags: _item.tags,
    );
    Navigator.pop(context, item);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.item == null
              ? Strings.of(context).add
              : Strings.of(context).edit,
        ),
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
                  initialValue: _item.url,
                  onChanged: (url) => _item = _item.copyWith(url: url),
                  decoration: const InputDecoration(labelText: 'URL'),
                  keyboardType: TextInputType.url,
                ),
                SizedBox(height: 16),
                TextFormField(
                  initialValue: _item.login,
                  onChanged: (login) => _item = _item.copyWith(login: login),
                  decoration: InputDecoration(
                    labelText: Strings.of(context).login,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return Strings.of(context).loginIsRequiredError;
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                PasswordFormField(controller: _passwordCtrl),
                SizedBox(height: 16),
                TextFormField(
                  initialValue: _item.description,
                  onChanged: (value) =>
                      _item = _item.copyWith(description: value),
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    labelText: Strings.of(context).description,
                  ),
                  maxLines: 2,
                  minLines: 1,
                ),
                SizedBox(height: 16.0),
                TagsInput(
                  item: _item,
                  onUpdate: (item) => setState(() => _item = item),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: _submit,
                  child: Text(Strings.of(context).save),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
