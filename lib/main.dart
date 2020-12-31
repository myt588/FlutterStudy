import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: NativeCall(),
    );
  }
}

class NativeCall extends StatefulWidget {
  @override
  _NativeCallState createState() => _NativeCallState();
}

class _NativeCallState extends State<NativeCall> {
  String text = 'No idea';
  String imageURL =
      'https://static.toiimg.com/photo/msid-67586673/67586673.jpg?3918697';

  static const platform =
      const MethodChannel('flutterapp.tutorialspoint.com/browser');
  Future<void> _openBrowser() async {
    try {
      final int result = await platform.invokeMethod(
          'openBrowser', <String, String>{'url': "https://flutter.dev"});
    } on PlatformException catch (e) {
      // Unable to open the browser print(e);
    }
  }

  Future<void> _analyzeImage() async {
    try {
      const abc =
          const MethodChannel('flutterapp.tutorialspoint.com/analyzeImage');
      final String result = await abc
          .invokeMethod('analyzeImage', <String, String>{'url': imageURL});
      print(result);

      setState(() {
        text = result;
      });
    } on PlatformException catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Flutter Demo Home Page'),
        ),
        body: ListView(children: [
          Center(
            child: RaisedButton(
              child: Text('Open Browser'),
              onPressed: _openBrowser,
            ),
          ),
          Image.network(imageURL),
          Center(
            child: RaisedButton(
              child: Text('Analyze Image'),
              onPressed: _analyzeImage,
            ),
          ),
          Text(
            text,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w400,
              color: Colors.black,
            ),
          ),
        ]));
  }
}
