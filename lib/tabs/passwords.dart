import 'package:flutter/material.dart';
import '../l10n/strings.dart';
import '../models/password_item.dart';
import '../screen/password_security_screen.dart';
import '../services/security/password_storage.dart';
import '../screen/edit_password_screen.dart';

class PasswordsTab extends StatefulWidget {
  final PasswordStorage storage;

  const PasswordsTab({super.key, required this.storage});

  @override
  State<PasswordsTab> createState() => _PasswordsTabState();
}

class _PasswordsTabState extends State<PasswordsTab> {
  late Future<List<PasswordItem>> _itemsFuture;
  String _searchQuery = '';
  Map<String, bool> _filters = {};
  bool _showAll = true;

  @override
  void initState() {
    super.initState();
    _refreshCategories();
    _refresh();
  }

  Future<void> _refreshCategories() async {
    final items = await widget.storage.loadActive();
    _filters = {};
    if (mounted) {
      for (var item in items) {
        final domain =
            Uri.tryParse(item.url)?.host ?? Strings.of(context).othersCategory;
        _filters[domain] = true;
      }
    }
    setState(() {});
  }

  Future<void> _refresh() async {
    setState(() {
      _itemsFuture = widget.storage.loadActive().then(
        (items) => _applyFilters(items),
      );
    });
  }

  List<PasswordItem> _applyFilters(List<PasswordItem> items) {
    if (_searchQuery.isNotEmpty) {
      items = items
          .where(
            (item) =>
                item.login.contains(_searchQuery) ||
                item.url.contains(_searchQuery),
          )
          .toList();
    }

    if (!_showAll) {
      items = items.where((item) {
        final domain =
            Uri.tryParse(item.url)?.host ?? Strings.of(context).othersCategory;
        return _filters[domain] ?? false;
      }).toList();
    }

    items = items.toList()
      ..sort((a, b) {
        final domainA = Uri.tryParse(a.url)?.host ?? '';
        final domainB = Uri.tryParse(b.url)?.host ?? '';
        return domainA.compareTo(domainB);
      });

    return items;
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

  void _editItem(PasswordItem item) async {
    final updated = await Navigator.push<PasswordItem>(
      context,
      MaterialPageRoute(builder: (context) => EditPasswordScreen(item: item)),
    );

    if (updated != null) {
      await widget.storage.updateItem(updated);
      _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FutureBuilder(
              future: _itemsFuture,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final items = snapshot.data ?? [];
                  return Text(
                    items.isNotEmpty
                        ? '${items.length} ${Strings.of(context).piecesPrefix}'
                        : '',
                  );
                }
                return const SizedBox();
              },
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearchDialog,
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      PasswordSecurityScreen(storage: widget.storage),
                ),
              );
            },
            icon: Icon(Icons.analytics),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addItem,
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder(
        future: _itemsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(Strings.of(context).errorMsg(snapshot.error!)),
            );
          }

          final items = snapshot.data ?? [];

          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (context, index) {
              final currentItem = items[index];
              final nextItem = index < items.length - 1
                  ? items[index + 1]
                  : null;

              final currentDomain =
                  Uri.tryParse(currentItem.url)?.host ??
                  Strings.of(context).othersCategory;
              final nextDomain = nextItem != null
                  ? Uri.tryParse(nextItem.url)?.host ??
                        Strings.of(context).othersCategory
                  : null;

              if (nextDomain != currentDomain || index == items.length - 1) {
                return Divider();
              }
              return SizedBox.shrink();
            },
            itemBuilder: (context, index) {
              final item = items[index];
              final currentDomain =
                  Uri.tryParse(item.url)?.host ??
                  Strings.of(context).othersCategory;

              return LayoutBuilder(
                builder: (context, constraints) {
                  final isWideScreen = constraints.maxWidth > 735.0;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (index == 0 ||
                          (index > 0 &&
                              Uri.tryParse(items[index - 1].url)?.host !=
                                  currentDomain))
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          child: Text(
                            currentDomain,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withAlpha(135),
                            ),
                          ),
                        ),

                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.transparent,
                          child: Icon(Icons.key),
                        ),
                        title: isWideScreen
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [Text(item.login)],
                                  ),
                                  Wrap(
                                    spacing: 8.0,
                                    children: item.tagList.map((tag) {
                                      return Chip(
                                        label: Text(tag),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10.0,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              )
                            : Text(item.login),
                        subtitle: isWideScreen
                            ? Text(item.url)
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.url),
                                  Wrap(
                                    spacing: 8.0,
                                    children: item.tagList.map((tag) {
                                      return Chip(
                                        label: Text(tag),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10.0,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _editItem(item),
                        onLongPress: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(Strings.of(context).removeQuestion),
                              content: Text(
                                Strings.of(
                                  context,
                                ).removePasswordQuestion(item.url),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: Text(Strings.of(context).cancel),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: Text(Strings.of(context).delete),
                                ),
                              ],
                            ),
                          );

                          if (confirmed == true) {
                            await widget.storage.markAsDeleted(item.id);
                            _refresh();
                          }
                        },
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _showFilterDialog() async {
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(Strings.of(context).filters),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SwitchListTile(
                      title: Text(Strings.of(context).showAll),
                      value: _showAll,
                      onChanged: (value) {
                        setStateDialog(() {
                          _showAll = value;
                          _refresh();
                        });
                      },
                    ),
                    Divider(),
                    ..._filters.entries.map((entry) {
                      return SwitchListTile(
                        title: Text(entry.key),
                        value: entry.value,
                        onChanged: (value) {
                          setStateDialog(() {
                            _filters[entry.key] = value;
                            _refresh();
                          });
                        },
                      );
                    }),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: Text(Strings.of(context).close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showSearchDialog() async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(Strings.of(context).search),
          content: TextField(
            autofocus: true,
            decoration: InputDecoration(
              hintText: Strings.of(context).enterSearchQuery,
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
                _refresh();
              });
            },
          ),
          actions: [
            TextButton(
              child: Text(Strings.of(context).close),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }
}
