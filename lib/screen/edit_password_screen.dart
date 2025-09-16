import 'package:flutter/material.dart';
import 'package:safebox/custom_controls/password_form_field.dart';
import 'package:safebox/models/password_item.dart';

class EditPasswordScreen extends StatefulWidget {
  final PasswordItem? item;

  const EditPasswordScreen({super.key, this.item});

  @override
  State<EditPasswordScreen> createState() => _EditPasswordScreenState();
}

class _EditPasswordScreenState extends State<EditPasswordScreen> {
  late TextEditingController _loginCtrl;
  late TextEditingController _passwordCtrl;
  late TextEditingController _urlCtrl;
  late TextEditingController _descriptionCtrl;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    final item = widget.item;
    _loginCtrl = TextEditingController(text: item?.login);
    _passwordCtrl = TextEditingController(text: item?.password);
    _urlCtrl = TextEditingController(text: item?.url);
    _descriptionCtrl = TextEditingController(text: item?.description);
  }

  @override
  void dispose() {
    _loginCtrl.dispose();
    _passwordCtrl.dispose();
    _urlCtrl.dispose();
    _descriptionCtrl.dispose();
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
      login: _loginCtrl.text,
      password: _passwordCtrl.text,
      url: _urlCtrl.text,
      description: _descriptionCtrl.text,
    );
    Navigator.pop(context, item);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item == null ? 'Добавить' : 'Редактировать'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _urlCtrl,
                decoration: const InputDecoration(labelText: 'URL'),
                keyboardType: TextInputType.url,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _loginCtrl,
                decoration: const InputDecoration(labelText: 'Логин'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Логин обязателен';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              PasswordFormField(controller: _passwordCtrl),
              SizedBox(height: 16),
              TextFormField(
                controller: _descriptionCtrl,
                decoration: const InputDecoration(labelText: 'Описание'),
                maxLines: 2,
                minLines: 1,
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Сохранить'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
