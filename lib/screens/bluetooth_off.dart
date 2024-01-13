import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothOffScreen extends StatelessWidget {
  const BluetoothOffScreen({super.key, this.adapterState});
  final BluetoothAdapterState? adapterState;

  @override
  Widget build(BuildContext context) {
    String? state = adapterState?.toString().split('.').last;
    return Scaffold(
      backgroundColor: Colors.lightBlue,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.bluetooth_disabled,
              size: 200,
              color: Colors.white54,
            ),
            Text(
              "Bluetooth Adapter is ${state ?? 'not available'}",
              style: Theme.of(context)
                  .primaryTextTheme
                  .titleSmall
                  ?.copyWith(color: Colors.white),
            ),
            if (Platform.isAndroid)
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: ElevatedButton(
                  child: const Text('TURN ON'),
                  onPressed: () async {
                    try {
                      if (Platform.isAndroid) {
                        await FlutterBluePlus.turnOn();
                      }
                    } catch (e) {
                      print(e);
                    }
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
