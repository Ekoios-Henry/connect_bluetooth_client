import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Test(),
        ),
      ),
    );
  }
}

class Test extends StatefulWidget {
  const Test({super.key});

  @override
  State<StatefulWidget> createState() => TestState();
}

class TestState extends State<Test> {
  List<String> bltAddress = [];
  BluetoothConnection? connection;

  @override
  void initState() {
    super.initState();
    try {
      FlutterBluetoothSerial.instance.startDiscovery().listen((e) {
        bltAddress.add(e.device.address);
        setState(() {});
      });
    } catch (exception) {
      print('Cannot connect, exception occured');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, index) => InkWell(
        onTap: () async {
          // if(connection != null && connection!.isConnected){
          //   await connection!.finish();
          //   return;
          // }

          connection = await BluetoothConnection.toAddress(bltAddress[index]);
          if (connection != null) {
            showDialog(
              barrierDismissible: false,
              context: context,
              builder: (context) =>
                  BlueToothConnectDialog(connection: connection!),
            );
          }
        },
        child: Container(
          padding: const EdgeInsets.all(15),
          child: Text(bltAddress[index]),
        ),
      ),
      itemCount: bltAddress.length,
    );
  }
}

class BlueToothConnectDialog extends StatelessWidget {
  final BluetoothConnection connection;

  const BlueToothConnectDialog({required this.connection, super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Container(
        alignment: Alignment.center,
        height: 100,
        child: TextFormField(
          onChanged: (value) {
            List<int> list = value.substring(value.length - 1).codeUnits;
            Uint8List data = Uint8List.fromList(list);
            connection.output.add(data);
          },
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Enter message',
          ),
        ),
      ),
    );
  }
}
