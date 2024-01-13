import 'package:fbp/widgets/characteristic_tile.dart';
import 'package:fbp/widgets/descriptor_tile.dart';
import 'package:fbp/widgets/service_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class DeviceScreen extends StatefulWidget {
  final BluetoothDevice device;
  const DeviceScreen({super.key, required this.device});

  @override
  State<DeviceScreen> createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen> {
  int? _rssi;
  int? _mtuSize;
  BluetoothConnectionState _connectionState =
      BluetoothConnectionState.disconnected;
  List<BluetoothService> _services = [];
  bool _isDiscoveringServices = false;
  bool _isConnecting = false;
  bool _isDisconnecting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.device.platformName),
        actions: [
          Row(
            children: [
              if (_isConnecting || _isDisconnecting) buildSpinner(context),
              TextButton(
                onPressed: _isConnecting
                    ? onCancelPressed
                    : (isConnected ? onDisconnectPressed : onConnectPressed),
                child: Text(
                  _isConnecting
                      ? 'Cancel'
                      : isConnected
                          ? 'Disconnect'
                          : 'Connect',
                  style: Theme.of(context)
                      .primaryTextTheme
                      .labelLarge
                      ?.copyWith(color: Colors.blue),
                ),
              )
            ],
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // remote id
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('${widget.device.remoteId}'),
            ),

            ListTile(
              // rssi
              leading: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  isConnected
                      ? const Icon(Icons.bluetooth_connected)
                      : const Icon(Icons.bluetooth_disabled),
                  Text(((isConnected && _rssi != null) ? '${_rssi!} dBm' : ''),
                      style: Theme.of(context).textTheme.bodySmall)
                ],
              ),
              // status
              title: Text(
                  'Device is ${_connectionState.toString().split('.').last}'),
              //services
              trailing: IndexedStack(
                index: _isDiscoveringServices ? 1 : 0,
                children: [
                  TextButton(
                    onPressed: onDiscoverServicesPressed,
                    child: const Text('Get Services'),
                  ),
                  const IconButton(
                    icon: SizedBox(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Colors.grey),
                      ),
                      width: 18,
                      height: 18,
                    ),
                    onPressed: null,
                  ),
                ],
              ),
            ),
            // mtu
            ListTile(
              title: const Text('MTU Size'),
              subtitle: Text('$_mtuSize bytes'),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: onRequestMtuPressed,
              ),
            ),
            ..._buildServiceTiles(context, widget.device),
          ],
        ),
      ),
    );
  }

  bool get isConnected =>
      _connectionState == BluetoothConnectionState.connected;

  Widget buildSpinner(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(14.0),
      child: AspectRatio(
        aspectRatio: 1.0,
        child: CircularProgressIndicator(
          backgroundColor: Colors.black12,
          color: Colors.black26,
        ),
      ),
    );
  }

  List<Widget> _buildServiceTiles(BuildContext context, BluetoothDevice d) {
    return _services
        .map((s) => ServiceTile(
            service: s,
            characteristicTiles: s.characteristics
                .map((c) => _buildCharacteristicTile(c))
                .toList()))
        .toList();
  }

  CharacteristicTile _buildCharacteristicTile(BluetoothCharacteristic c) {
    return CharacteristicTile(
        characteristic: c,
        descriptorTiles:
            c.descriptors.map((d) => DescriptorTile(descriptor: d)).toList());
  }

  Future<void> onCancelPressed() async {
    print("canceling...");
    try {
      await widget.device.disconnect();
    } catch (e) {
      print(e);
    }
  }

  Future<void> onDisconnectPressed() async {
    print('disconnecting...');
    try {
      await widget.device.disconnect();
    } catch (e) {
      print(e);
    }
  }

  Future<void> onConnectPressed() async {
    print('connecting...');
    try {
      await widget.device.connect();
    } catch (e) {
      print(e);
    }
  }

  Future<void> onDiscoverServicesPressed() async {
    if (mounted) {
      setState(() {
        _isDiscoveringServices = true;
      });
    }

    print('discovering services...');
    try {
      _services = await widget.device.discoverServices();
    } catch (e) {
      print(e);
    }

    if (mounted) {
      setState(() {
        _isDiscoveringServices = false;
      });
    }
  }

  Future<void> onRequestMtuPressed() async {
    print('requesting mtu...');
    try {
      await widget.device.requestMtu(223, predelay: 0);
    } catch (e) {
      print(e);
    }
  }
}
