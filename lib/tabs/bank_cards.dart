import 'package:flutter/material.dart';
import 'package:safebox/l10n/strings.dart';
import 'package:safebox/models/bank_card.dart';
import 'package:safebox/services/security/bank_card_storage.dart';

import '../screen/edit_bank_card_screen.dart';

class BankCardsTab extends StatefulWidget {
  final BankCardStorage storage;

  const BankCardsTab({super.key, required this.storage});

  @override
  State<StatefulWidget> createState() => _BankCardsTabState();
}

class _BankCardsTabState extends State<BankCardsTab> {
  late final _strings = Strings.of(context);
  late Future<List<BankCard>> _itemsFuture;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() {
      _itemsFuture = widget.storage.loadActive();
    });
  }

  void _addItem() async {
    final item = await Navigator.push<BankCard>(
      context,
      MaterialPageRoute(builder: (context) => const EditBankCardScreen()),
    );

    if (item != null) {
      await widget.storage.addItem(item);
      _refresh();
    }
  }

  void _editItem(BankCard item) async {
    final updated = await Navigator.push<BankCard>(
      context,
      MaterialPageRoute(builder: (context) => EditBankCardScreen(item: item)),
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
                        ? '${items.length} ${_strings.piecesPrefix}'
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
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () async {
              await widget.storage.clear();
              await _refresh();
            },
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
            return Center(child: Text(_strings.errorMsg(snapshot.error!)));
          }

          final items = snapshot.data ?? [];

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];

              return LayoutBuilder(
                builder: (context, constraints) {
                  final isWideScreen = constraints.maxWidth > 735.0;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        leading: SizedBox(
                          width: 120, // оптимальная ширина
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Flexible(
                                fit: FlexFit.loose,
                                child: Tooltip(
                                  message: item.title,
                                  child: Text(
                                    item.title,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const CircleAvatar(
                                backgroundColor: Colors.transparent,
                                child: Icon(Icons.credit_card),
                              ),
                            ],
                          ),
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
                                    children: [Text(item.number)],
                                  ),
                                  Wrap(
                                    spacing: 8.0,
                                    children: item.tagList
                                        .map(
                                          (tag) => Chip(
                                            label: Text(tag),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadiusGeometry.circular(
                                                    10.0,
                                                  ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  ),
                                ],
                              )
                            : Text(item.number),
                        subtitle: isWideScreen
                            ? Text(
                                '${item.validityPeriod.month}/${item.validityPeriod.year}',
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${item.validityPeriod.month}/${item.validityPeriod.year}',
                                  ),
                                  Wrap(
                                    spacing: 8.0,
                                    children: item.tagList
                                        .map(
                                          (tag) => Chip(
                                            label: Text(tag),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadiusGeometry.circular(
                                                    10.0,
                                                  ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  ),
                                ],
                              ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _editItem(item),
                        onLongPress: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(_strings.removeQuestion),
                              content: Text(
                                Strings.of(
                                  context,
                                ).removeBankCardQuestion(item.number),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: Text(_strings.cancel),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: Text(
                                    _strings.delete,
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );

                          if (confirmed == true) {
                            await widget.storage.markAsDeleted(item.id);
                            await _refresh();
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
}
