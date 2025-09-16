import 'package:flutter/material.dart';
import 'package:safebox/models/password_item.dart';
import 'package:safebox/services/security/password_storage.dart';
import 'package:safebox/screen/edit_password_screen.dart';

class PasswordsTab extends StatefulWidget {
  final PasswordStorage storage;

  const PasswordsTab({super.key, required this.storage});

  @override
  State<PasswordsTab> createState() => _PasswordsTabState();
}

class _PasswordsTabState extends State<PasswordsTab> {
  late Future<List<PasswordItem>> _itemsFuture;

  @override
  void initState() {
    super.initState();
    _itemsFuture = widget.storage.load();
  }

  void _refresh() {
    setState(() {
      _itemsFuture = widget.storage.load();
    });
  }

  void _addItem() async {
    final item = await Navigator.push<PasswordItem>(
      context,
      MaterialPageRoute(builder: (context) => const EditPasswordScreen()),
    );

    if (item != null) {
      await widget.storage.addItem(item);
      _refresh();
    }
  }

  void _editItem(int index, PasswordItem item) async {
    final updated = await Navigator.push<PasswordItem>(
      context,
      MaterialPageRoute(builder: (context) => EditPasswordScreen(item: item)),
    );

    if (updated != null) {
      await widget.storage.updateItem(index, updated);
      _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Мои пароли')),
      floatingActionButton: FloatingActionButton(
        onPressed: _addItem,
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<PasswordItem>>(
        future: _itemsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('ERROR: ${snapshot.error}'));
          }

          final items = snapshot.data ?? [];

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.transparent,
                  child: Icon(Icons.key),
                ),
                title: Text(item.login),
                subtitle: Text(item.url),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _editItem(index, item),
                onLongPress: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Удалить?'),
                      content: Text('Удалить пароль для ${item.url}?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Отмена'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Удалить'),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true) {
                    await widget.storage.deleteItem(index);
                    _refresh();
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
