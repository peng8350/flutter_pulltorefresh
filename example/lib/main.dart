import 'package:example/ui/MainActivity.dart';
import 'package:example/ui/SecondActivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'ui/indicator/base/IndicatorActivity.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return RefreshConfiguration(
      footerTriggerDistance: 15,
      dragSpeedRatio: 0.91,
      headerBuilder: () => MaterialClassicHeader(),
      footerBuilder: () => ClassicFooter(),
      autoLoad: true,
      child: MaterialApp(
        title: 'Pulltorefresh Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          // This is the theme of your application.
          //s
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or press Run > Flutter Hot Reload in IntelliJ). Notice that the
          // counter didn't reset back to zero; the application is not restarted.
          platform: TargetPlatform.android,
          primarySwatch: Colors.blue,
          primaryColor: Colors.greenAccent
        ),
        localizationsDelegates: [
          RefreshLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalMaterialLocalizations.delegate
        ],
        supportedLocales: [
          const Locale('en'),
          const Locale('zh'),
          const Locale('fr'),
        ],
        localeResolutionCallback:
            (Locale locale, Iterable<Locale> supportedLocales) {
          //print("change language");
          return locale;
        },
        home: MainActivity(title: 'Pulltorefresh'),
        routes: {
          "sec": (BuildContext context) {
            return SecondActivity(
              title: "SecondAct",
            );
          },
          "indicator": (BuildContext context) {
            return IndicatorActivity();
          }
        },
      ),
    );
  }
}
