/*
 * Author: Jpeng
 * Email: peng8350@gmail.com
 * Time:  2019-09-06 23:18
 */


import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class RefreshLocalizations{

  final Locale locale;

  RefreshLocalizations(
    this.locale
  );

  Map<String,RefreshString> _values = {
    'en':EnRefreshString(),
    'zh':ChRefreshString()
  };

  RefreshString get currentLocalization {
    if(_values.containsKey(locale.languageCode)) {
      return _values[locale.languageCode];
    }
    return _values["en"];
  }

  static const RefreshLocalizationsDelegate delegate = RefreshLocalizationsDelegate();

  ///通过 Localizations 加载当前的 GSYLocalizations
  ///获取对应的 GSYStringBase
  static RefreshLocalizations of(BuildContext context) {
    return Localizations.of(context, RefreshLocalizations);
  }

}


class RefreshLocalizationsDelegate extends LocalizationsDelegate<RefreshLocalizations>{

  const RefreshLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en','zh'].contains(locale.languageCode);
  }

  @override
  Future<RefreshLocalizations> load(Locale locale) {
    return SynchronousFuture<RefreshLocalizations>(RefreshLocalizations(locale));
  }

  @override
  bool shouldReload(LocalizationsDelegate<RefreshLocalizations> old) {
    return false;
  }

  static RefreshLocalizationsDelegate delegate = const RefreshLocalizationsDelegate();
}

abstract class RefreshString{
  // pull down refresh idle text
  String idleRefreshText;
  //  tips user to release gesture to refresh at time
  String canRefreshText;
  // refreshing state text
  String refreshingText;
  // refresh completed text
  String refreshCompleteText;
  //refresh failed text
  String refreshFailedText;
  // enable open twoLevel and tips user to release gesture to enter two level
  String canTwoLevelText;
  // pull down load idle text
  String idleLoadingText;
  // tips user to release gesture to load more at time
  String canLoadingText;
  // loading state text
  String loadingText;
  // load failed text
  String loadFailedText;
  // no more data text
  String noMoreText;

}

class ChRefreshString implements RefreshString{
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

class EnRefreshString implements RefreshString{
  @override
  String canLoadingText="release to load more";

  @override
  String canRefreshText = "Refresh when release";

  @override
  String canTwoLevelText = "release to enter secondfloor";

  @override
  String idleLoadingText = "Load More";

  @override
  String idleRefreshText="Pull down to refresh";

  @override
  String loadFailedText = "Load Failed";

  @override
  String loadingText = "Loading...";

  @override
  String noMoreText = "No more data";

  @override
  String refreshCompleteText = "Refresh completed";

  @override
  String refreshFailedText="Refresh failed";

  @override
  String refreshingText = "Refreshing...";

}