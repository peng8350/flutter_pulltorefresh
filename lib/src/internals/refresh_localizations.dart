/*
 * Author: Jpeng
 * Email: peng8350@gmail.com
 * Time:  2019-09-06 23:18
 */

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// Implementation of localized strings for the [ClassicHeader],[ClassicFooter],[TwoLevelHeader]
///
///
/// Supported languages:now only add Chinese and English
/// If you need to add other languages,please give me a pr
///
/// ## Sample code
///
/// To include the localizations provided by this class in a [MaterialApp],
/// add [RefreshLocalizations.delegates] to
/// [MaterialApp.localizationsDelegates], and specify the locales your
/// app supports with [MaterialApp.supportedLocales]:
///
/// ```dart
/// new MaterialApp(
///   localizationsDelegates: RefreshLocalizations.delegates,
///   supportedLocales: [
///     const Locale('en'), // American English
///     const Locale('zh'), // Israeli Hebrew
///     // ...
///   ],
///   // ...
/// )
/// ```
class RefreshLocalizations {
  final Locale locale;

  RefreshLocalizations(this.locale);

  Map<String, RefreshString> values = {
    'en': EnRefreshString(),
    'zh': ChRefreshString()
  };

  RefreshString get currentLocalization {
    if (values.containsKey(locale.languageCode)) {
      return values[locale.languageCode];
    }
    return values["en"];
  }

  static const RefreshLocalizationsDelegate delegate =
      RefreshLocalizationsDelegate();

  static RefreshLocalizations of(BuildContext context) {
    return Localizations.of(context, RefreshLocalizations);
  }
}

class RefreshLocalizationsDelegate
    extends LocalizationsDelegate<RefreshLocalizations> {
  const RefreshLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'zh'].contains(locale.languageCode);
  }

  @override
  Future<RefreshLocalizations> load(Locale locale) {
    return SynchronousFuture<RefreshLocalizations>(
        RefreshLocalizations(locale));
  }

  @override
  bool shouldReload(LocalizationsDelegate<RefreshLocalizations> old) {
    return false;
  }
}

/// interface implements different language
abstract class RefreshString {
  /// pull down refresh idle text
  String idleRefreshText;

  ///  tips user to release gesture to refresh at time
  String canRefreshText;

  /// refreshing state text
  String refreshingText;

  /// refresh completed text
  String refreshCompleteText;

  /// refresh failed text
  String refreshFailedText;

  /// enable open twoLevel and tips user to release gesture to enter two level
  String canTwoLevelText;

  /// pull down load idle text
  String idleLoadingText;

  /// tips user to release gesture to load more at time
  String canLoadingText;

  /// loading state text
  String loadingText;

  /// load failed text
  String loadFailedText;

  /// no more data text
  String noMoreText;
}

/// Chinese
class ChRefreshString implements RefreshString {
  @override
  String canLoadingText = "松手开始加载数据";

  @override
  String canRefreshText = "松开开始刷新数据";

  @override
  String canTwoLevelText = "释放手势,进入二楼";

  @override
  String idleLoadingText = "上拉加载";

  @override
  String idleRefreshText = "下拉刷新";

  @override
  String loadFailedText = "加载失败";

  @override
  String loadingText = "加载中...";

  @override
  String noMoreText = "没有更多数据了";

  @override
  String refreshCompleteText = "刷新成功";

  @override
  String refreshFailedText = "刷新失败";

  @override
  String refreshingText = "刷新中...";
}

/// English
class EnRefreshString implements RefreshString {
  @override
  String canLoadingText = "Release to load more";

  @override
  String canRefreshText = "Release to refresh";

  @override
  String canTwoLevelText = "Release to enter secondfloor";

  @override
  String idleLoadingText = "Pull up Load more";

  @override
  String idleRefreshText = "Pull down Refresh";

  @override
  String loadFailedText = "Load Failed";

  @override
  String loadingText = "Loading...";

  @override
  String noMoreText = "No more data";

  @override
  String refreshCompleteText = "Refresh completed";

  @override
  String refreshFailedText = "Refresh failed";

  @override
  String refreshingText = "Refreshing...";
}
