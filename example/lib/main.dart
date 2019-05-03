import 'package:example/ui/MainActivity.dart';
import 'package:example/ui/SecondActivity.dart';

import 'package:example/ui/test/TestPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() => runApp( MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return  MaterialApp(

      title: 'Pulltorefresh Demo',
      debugShowCheckedModeBanner:   false,
      theme:  ThemeData(
        // This is the theme of your application.
        //s
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or press Run > Flutter Hot Reload in IntelliJ). Notice that the
        // counter didn't reset back to zero; the application is not restarted.
        primarySwatch: Colors.blue,
      ),
      home:  MainActivity(title: 'Pulltorefresh'),
      routes: {
        "sec": (BuildContext context) {
          return  SecondActivity(title: "SecondAct",);
        },
      },
    );
  }
}

