import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class DescriptorTile extends StatefulWidget {
  final BluetoothDescriptor descriptor;
  const DescriptorTile({super.key, required this.descriptor});

  @override
  State<DescriptorTile> createState() => _DescriptorTileState();
}

class _DescriptorTileState extends State<DescriptorTile> {
  List<int> _value = [];
  late StreamSubscription<List<int>> _lastValueSubscription;

  @override
  void initState() {
    super.initState();
    _lastValueSubscription = widget.descriptor.lastValueStream.listen(
      (value) {
        _value = value;
        if (mounted) setState(() {});
      },
    );
  }

  @override
  void dispose() {
    _lastValueSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Descriptor'),
          Text(
            '0x${widget.descriptor.uuid.str.toUpperCase()}',
            style: TextStyle(fontSize: 13),
          ),
          Text(
            _value.toString(),
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ],
      ),
      subtitle: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(onPressed: onReadPressed, child: Text('Read')),
          TextButton(onPressed: onWritePressed, child: Text('Write')),
        ],
      ),
    );
  }

  BluetoothDescriptor get d => widget.descriptor;

  List<int> _getRandomBytes() {
    final math = Random();
    return [
      math.nextInt(255),
      math.nextInt(255),
      math.nextInt(255),
      math.nextInt(255)
    ];
  }

  Future<void> onReadPressed() async {
    print('reading...');
    try {
      await d.read();
    } catch (e) {
      print(e);
    }
  }

  Future<void> onWritePressed() async {
    final data = _getRandomBytes();
    print('writing: $data');
    try {
      await d.write(data);
    } catch (e) {
      print(e);
    }
  }
}
