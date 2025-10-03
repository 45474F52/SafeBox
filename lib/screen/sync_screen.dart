import 'package:flutter/material.dart';
import 'package:safebox/services/helpers/snackbar_provider.dart';
import '../l10n/strings.dart';
import '../custom_controls/base_screen.dart';
import '../services/sync/discoverer.dart';
import '../services/sync/synchronizer.dart';

class SyncScreen extends BaseScreen<SyncScreen> {
  final Synchronizer synchronizer;
  const SyncScreen({super.key, required this.synchronizer});

  @override
  State<SyncScreen> createState() => _SyncScreenState();
}

class _SyncScreenState extends BaseScreenState<SyncScreen> {
  late final _strings = Strings.of(context);
  final _discoverer = Discoverer();
  bool _isDiscover = false;
  List<String> _devices = [];

  void _stopDiscover() {
    setState(() {
      _isDiscover = false;
      _devices = [];
    });

    _discoverer.cancelDiscover();
  }

  Future<void> _startDiscover() async {
    setState(() {
      _isDiscover = true;
      _devices = [];
    });

    try {
      final devices = await _discoverer.discoverDevices();
      if (mounted) {
        setState(() {
          _devices = devices;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _devices = [];
        });
        SnackBarProvider.provideException(context, e);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDiscover = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_strings.discoverDevices)),
      body: activityDetection(
        Column(
          children: [
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton.icon(
                    icon: _isDiscover
                        ? Container(
                            width: 24.0,
                            height: 24.0,
                            padding: const EdgeInsets.all(2.0),
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3.0,
                            ),
                          )
                        : const Icon(Icons.search),
                    label: Text(_strings.discover),
                    onPressed: _isDiscover
                        ? null
                        : () async {
                            await _startDiscover();
                          },
                  ),

                  const SizedBox(width: 16.0),

                  TextButton.icon(
                    icon: const Icon(Icons.stop),
                    label: Text(_strings.stop),
                    onPressed: !_isDiscover ? null : _stopDiscover,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16.0),

            Text(
              _isDiscover
                  ? '${_strings.discover}...'
                  : _devices.isNotEmpty
                  ? _strings.discoveredCountMessage(_devices.length)
                  : _strings.devicesNotFoundMsg,
              style: TextStyle(
                fontSize: 14.0,
                color: _isDiscover ? Colors.blue : Colors.grey,
              ),
            ),
            const SizedBox(height: 16.0),

            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.all(8.0),
                itemCount: _devices.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: const Icon(Icons.device_hub, color: Colors.blue),
                    title: Text(_devices[index]),
                    trailing: IconButton(
                      icon: Icon(Icons.sync, color: Colors.green),
                      tooltip: Strings.of(
                        context,
                      ).startSyncWith(_devices[index]),
                      onPressed: () async {
                        try {
                          final targetIP = _devices[index];
                          await widget.synchronizer.initiateSyncWith(targetIP);
                          if (context.mounted) {
                            SnackBarProvider.showSuccess(
                              context,
                              _strings.passwordsSynchronized,
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            SnackBarProvider.provideException(context, e);
                          }
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
