import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class SystemDeviceTile extends StatefulWidget {
  final BluetoothDevice device;
  final VoidCallback onOpen;
  final VoidCallback onConnect;
  const SystemDeviceTile({
    super.key,
    required this.device,
    required this.onConnect,
    required this.onOpen,
  });

  @override
  State<SystemDeviceTile> createState() => _SystemDeviceTileState();
}

class _SystemDeviceTileState extends State<SystemDeviceTile> {
  BluetoothConnectionState _connectionState =
      BluetoothConnectionState.disconnected;
  late StreamSubscription<BluetoothConnectionState>
      _connectionStateSubscription;

  @override
  void initState() {
    super.initState();
    _connectionStateSubscription = widget.device.connectionState.listen(
      (state) {
        _connectionState = state;
        if (mounted) setState(() {});
      },
    );
  }

  @override
  void dispose() {
    _connectionStateSubscription.cancel();
    super.dispose();
  }

  bool get isConnected =>
      _connectionState == BluetoothConnectionState.connected;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(widget.device.platformName),
      subtitle: Text(widget.device.remoteId.toString()),
      trailing: ElevatedButton(
        onPressed: isConnected ? widget.onOpen : widget.onConnect,
        child: Text(isConnected ? 'Open' : 'Connect'),
      ),
    );
  }
}
