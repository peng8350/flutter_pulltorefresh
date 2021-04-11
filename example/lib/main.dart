import 'package:example/other/refresh_glowindicator.dart';
import 'package:example/ui/MainActivity.dart';
import 'package:example/ui/SecondActivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
      enableLoadingWhenNoData: false,
      enableRefreshVibrate: false,
      enableLoadMoreVibrate: false,
      shouldFooterFollowWhenNotFull: (state) {
        // If you want load more with noMoreData state ,may be you should return false
        return false;
      },
      child: MaterialApp(
        title: 'Pulltorefresh Demo',
        debugShowCheckedModeBanner: false,
        builder: (context, child) {
          return ScrollConfiguration(
            child: child,
            behavior: RefreshScrollBehavior(),
          );
        },
        theme: ThemeData(
            // This is the theme of your application.
            //s
            // Try running your application with "flutter run". You'll see the
            // application has a blue toolbar. Then, without quitting the app, try
            // changing the primarySwatch below to Colors.green and then invoke
            // "hot reload" (press "r" in the console where you ran "flutter run",
            // or press Run > Flutter Hot Reload in IntelliJ). Notice that the
            // counter didn't reset back to zero; the application is not restarted.
            primarySwatch: Colors.blue,
            primaryColor: Colors.greenAccent),
        localizationsDelegates: [
          RefreshLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate
        ],
        supportedLocales: [
          const Locale('en'),
          const Locale('zh'),
          const Locale('ja'),
          const Locale('uk'),
          const Locale('it'),
          const Locale('ru'),
          const Locale('fr'),
          const Locale('es'),
          const Locale('nl'),
          const Locale('sv'),
          const Locale('pt'),
          const Locale('ko'),
        ],
        locale: const Locale('zh'),
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
