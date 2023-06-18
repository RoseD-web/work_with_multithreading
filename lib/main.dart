import 'dart:async';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() {
  runApp(MyApp());

  ReceivePort receivePort1 = ReceivePort();
  Isolate.spawn(firstThread, receivePort1.sendPort);

  ReceivePort receivePort2 = ReceivePort();
  Isolate.spawn(secondThread, receivePort2.sendPort);

  ReceivePort receivePort3 = ReceivePort();
  Isolate.spawn(thirdThread, receivePort3.sendPort);

  receivePort1.listen((message) {
    MyApp.sessionDuration = message.toString();
  });

  receivePort2.listen((message) {
    MyApp.secondThreadValue = message.toString();
    if (message % 4 != 0) {
      Fluttertoast.showToast(
        msg: 'Длительность сессии: ${MyApp.sessionDuration} секунд',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
      );
    }
  });

  receivePort3.listen((message) {
    if (message == 'Surprise') {
      Fluttertoast.showToast(
        msg: 'Surprise',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  });
}

void firstThread(SendPort mainThreadPort) {
  int seconds = 0;

  Timer.periodic(Duration(seconds: 1), (Timer timer) {
    seconds++;
    mainThreadPort.send(seconds);
  });
}

void secondThread(SendPort mainThreadPort) {
  int counter = 0;

  Timer.periodic(Duration(seconds: 10), (Timer timer) {
    counter++;
    mainThreadPort.send(counter);
  });
}

void thirdThread(SendPort mainThreadPort) {
  int toastCounter = 0;

  Timer.periodic(Duration(seconds: 10), (Timer timer) {
    toastCounter++;
    if (toastCounter % 4 == 0) {
      mainThreadPort.send('Surprise');
    }
  });
}

class MyApp extends StatefulWidget {
  static String sessionDuration = '';
  static String secondThreadValue = '';

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String uiValue = '';

  @override
  void initState() {
    super.initState();

    Timer.periodic(Duration(seconds: 1), (Timer timer) {
      setState(() {
        uiValue = 'Длительность сессии: ${MyApp.sessionDuration} секунд\n';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Text(
            uiValue,
            style: TextStyle(fontSize: 20),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
