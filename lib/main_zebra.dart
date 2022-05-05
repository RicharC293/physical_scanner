import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:zebrascanner/zebrascanner.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  dynamic map;

  StreamSubscription? subscription;

  String? eventData = "";

  @override
  void initState() {
    super.initState();

    // to get device OS Version
    initPlatformState();

    // to get Barcode Events from Zebra Scanner
    initBarcodeReceiver();
  }

  initBarcodeReceiver() {
    subscription = Zebrascanner.getBarCodeEventStream.listen((barcodeData) {
      setState(() {
        map = barcodeData;

        print(map);

        var _list = map.values.toList();

        // Barcode
        print(_list[0]);
        // BarcodeType
        print(_list[1]);

        // ScannerId
        print(_list[2]);

        eventData = _list[0] + "-" + _list[1] + "-" + _list[2];
      });
    });
  }

  Future<void> initPlatformState() async {
    String platformVersion;

    try {
      platformVersion = await Zebrascanner.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> openBarcodeScreen() async {
    String? result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await Zebrascanner.barcodeScreen;
    } on PlatformException {
      result = 'Failed to open the screen';
    }
  }

  @override
  void dispose() {
    super.dispose();
    if (subscription != null) {
      subscription!.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Zebra Bluetooth Scanner app'),
        ),
        body: Center(
          child: Container(
            child: Column(
              children: [
                SizedBox(
                  height: 10,
                ),
                Text('Running on: $_platformVersion\n'),
                SizedBox(
                  height: 10,
                ),
                TextButton(
                    onPressed: () {
                      openBarcodeScreen();
                    },
                    child: Text("Click to Open Barcode Screen")),
                SizedBox(
                  height: 10,
                ),
                Text('Scanned Barcode/Qrcode ' + eventData!),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
