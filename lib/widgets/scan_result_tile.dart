import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class ScanResultTile extends StatefulWidget {
  final ScanResult result;
  final VoidCallback? onTap;
  const ScanResultTile({
    super.key,
    required this.result,
    this.onTap,
  });

  @override
  State<ScanResultTile> createState() => _ScanResultTileState();
}

class _ScanResultTileState extends State<ScanResultTile> {
  BluetoothConnectionState _connectionState =
      BluetoothConnectionState.disconnected;

  late StreamSubscription<BluetoothConnectionState>
      _connectionStateSubscription;

  @override
  void initState() {
    super.initState();

    _connectionStateSubscription =
        widget.result.device.connectionState.listen((state) {
      _connectionState = state;
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _connectionStateSubscription.cancel();
    super.dispose();
  }

  bool get isConnected {
    return _connectionState == BluetoothConnectionState.connected;
  }

  @override
  Widget build(BuildContext context) {
    var adv = widget.result.advertisementData;
    return ExpansionTile(
      
      title: widget.result.device.platformName.isNotEmpty
          ? Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.result.device.platformName,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  widget.result.device.remoteId.toString(),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            )
          : Text(widget.result.device.remoteId.toString()),
      leading: Text(widget.result.rssi.toString()),
      trailing: ElevatedButton(
        onPressed:
            (widget.result.advertisementData.connectable) ? widget.onTap : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        child: Text(isConnected ? 'Open' : 'Connect'),
      ),
      children: [
        if (adv.advName.isNotEmpty) _buildAdvRow(context, 'Name', adv.advName),
        if (adv.txPowerLevel != null)
          _buildAdvRow(context, 'TxPower Level', "${adv.txPowerLevel}"),
        if (adv.manufacturerData.isNotEmpty)
          _buildAdvRow(context, 'Manufacturer Data', '${adv.manufacturerData}'),
        if (adv.serviceUuids.isNotEmpty)
          _buildAdvRow(context, 'Service UUIDs', '${adv.serviceUuids}'),
        if (adv.serviceData.isNotEmpty)
          _buildAdvRow(context, 'Service Data', '${adv.serviceData}'),
      ],
    );
  }

  Widget _buildAdvRow(BuildContext context, String title, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.apply(color: Colors.black),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}
