import 'dart:async';

import 'package:fbp/screens/device.dart';
import 'package:fbp/widgets/scan_result_tile.dart';
import 'package:fbp/widgets/system_device_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  List<BluetoothDevice> _systemDevices = [];
  List<ScanResult> _scanResults = [];
  List<ScanResult> _customScanResults = [];
  bool _isScanning = false;
  late StreamSubscription<List<ScanResult>> _scanResultsSubscription;
  late StreamSubscription<bool> _isScanningSubscription;

  @override
  void initState() {
    super.initState();
    _scanResultsSubscription = FlutterBluePlus.scanResults.listen(
      (results) {
        var customList = results
            .where((element) =>
                element.advertisementData.advName.contains('HEETHINGS'))
            .toList();
        _customScanResults = customList;
        _scanResults =
            results.where((element) => !customList.contains(element)).toList();
        if (mounted) setState(() {});
      },
      onError: (e) {
        print(e);
      },
    );

    _isScanningSubscription = FlutterBluePlus.isScanning.listen(
      (state) {
        _isScanning = state;
        if (mounted) setState(() {});
      },
    );
  }

  @override
  void dispose() {
    _scanResultsSubscription.cancel();
    _isScanningSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Find Devices')),
      floatingActionButton: buildScanButton(context),
      body: RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          children: [
            ..._buildCustomScanResultTiles(context),
          ],
        ),
      ),
    );
  }

  Future<void> onScanPressed() async {
    try {
      _systemDevices = await FlutterBluePlus.systemDevices;
    } catch (e) {
      print(e);
    }

    try {
      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 15),
        continuousUpdates: true,
      );
    } catch (e) {
      print(e);
    }

    if (mounted) setState(() {});
  }

  Future<void> onStopPressed() async {
    try {
      FlutterBluePlus.stopScan();
    } catch (e) {
      print(e);
    }
  }

  void onConnectPressed(BluetoothDevice device) {
    device.connect().catchError((e) {
      print(e);
    }).whenComplete(() => print("Connected ${device.advName}"));
    // next screen
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => DeviceScreen(device: device),
      settings: const RouteSettings(name: '/device'),
    ));
  }

  Future<void> onRefresh() {
    if (_isScanning == false) {
      FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
    }
    if (mounted) setState(() {});
    return Future.delayed(const Duration(milliseconds: 500));
  }

  Widget buildScanButton(BuildContext context) {
    if (FlutterBluePlus.isScanningNow) {
      return FloatingActionButton(
        onPressed: onStopPressed,
        backgroundColor: Colors.red,
        child: const Icon(Icons.stop),
      );
    } else {
      return FloatingActionButton(
        onPressed: onScanPressed,
        child: const Text('Scan'),
      );
    }
  }

  List<Widget> _buildCustomScanResultTiles(BuildContext context) {
    return _customScanResults
        .map(
          (r) => ScanResultTile(
            result: r,
            onTap: () => onConnectPressed(r.device),
          ),
        )
        .toList();
  }
}
