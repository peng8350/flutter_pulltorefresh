/*
 * Author: Jpeng
 * Email: peng8350@gmail.com
 * Time:  2019-09-06 23:18
 */

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

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
///
/// If you don't have the language you need here and you want to add it, you can give me a pr.
///
/// Steps:
/// 1. custom a class XXRefreshString implements  RefreshString ,and then translate them
/// 2. add it into values
/// ```dart
///   Map<String, RefreshString> values = {
///    'en': EnRefreshString(),
///    'zh': ChRefreshString(),
///    'fr': FrRefreshString(),
///    'ru': RuRefreshString(),
///    'uk': UkRefreshString(),
///    'xx':XXRefreshString(), // xx indicate your country code
///  };
/// 3. update delegate a method "isSupported"
/// ```dart
///   @override
//  bool isSupported(Locale locale) {
//    return ['en', 'zh', 'fr', 'ru', 'uk','xx'].contains(locale.languageCode);
//  }
/// ```
///
/// see #175 to find more details
///
///
/// ```
///
///
/// ```
class RefreshLocalizations {
  final Locale locale;

  RefreshLocalizations(this.locale);

  Map<String, RefreshString> values = {
    'en': EnRefreshString(),
    'zh': ChRefreshString(),
    'fr': FrRefreshString(),
    'ru': RuRefreshString(),
    'uk': UkRefreshString(),
    'it': ItRefreshString(),
    'ja': JpRefreshString(),
    'de': DeRefreshString(),
    'es': EsRefreshString(),
    'nl': NlRefreshString(),
    'sv': SvRefreshString(),
    'pt': PtRefreshString(),
    'ko': KrRefreshString(),
  };

  RefreshString? get currentLocalization {
    if (values.containsKey(locale.languageCode)) {
      return values[locale.languageCode];
    }
    return values["en"];
  }

  static const RefreshLocalizationsDelegate delegate =
      RefreshLocalizationsDelegate();

  static RefreshLocalizations? of(BuildContext context) {
    return Localizations.of(context, RefreshLocalizations);
  }
}

class RefreshLocalizationsDelegate
    extends LocalizationsDelegate<RefreshLocalizations> {
  const RefreshLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return [
      'en',
      'zh',
      'fr',
      'ru',
      'uk',
      'ja',
      'it',
      'de',
      'ko',
      'pt',
      'sv',
      'nl',
      'es'
    ].contains(locale.languageCode);
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
  String? idleRefreshText;

  ///  tips user to release gesture to refresh at time
  String? canRefreshText;

  /// refreshing state text
  String? refreshingText;

  /// refresh completed text
  String? refreshCompleteText;

  /// refresh failed text
  String? refreshFailedText;

  /// enable open twoLevel and tips user to release gesture to enter two level
  String? canTwoLevelText;

  /// pull down load idle text
  String? idleLoadingText;

  /// tips user to release gesture to load more at time
  String? canLoadingText;

  /// loading state text
  String? loadingText;

  /// load failed text
  String? loadFailedText;

  /// no more data text
  String? noMoreText;
}

/// Chinese
class ChRefreshString implements RefreshString {
  @override
  String? canLoadingText = "松手开始加载数据";

  @override
  String? canRefreshText = "松开开始刷新数据";

  @override
  String? canTwoLevelText = "释放手势,进入二楼";

  @override
  String? idleLoadingText = "上拉加载";

  @override
  String? idleRefreshText = "下拉刷新";

  @override
  String? loadFailedText = "加载失败";

  @override
  String? loadingText = "加载中…";

  @override
  String? noMoreText = "没有更多数据了";

  @override
  String? refreshCompleteText = "刷新成功";

  @override
  String? refreshFailedText = "刷新失败";

  @override
  String? refreshingText = "刷新中…";
}

/// English
class EnRefreshString implements RefreshString {
  @override
  String? canLoadingText = "Release to load more";

  @override
  String? canRefreshText = "Release to refresh";

  @override
  String? canTwoLevelText = "Release to enter secondfloor";

  @override
  String? idleLoadingText = "Pull up Load more";

  @override
  String? idleRefreshText = "Pull down Refresh";

  @override
  String? loadFailedText = "Load Failed";

  @override
  String? loadingText = "Loading…";

  @override
  String? noMoreText = "No more data";

  @override
  String? refreshCompleteText = "Refresh completed";

  @override
  String? refreshFailedText = "Refresh failed";

  @override
  String? refreshingText = "Refreshing…";
}

/// French
class FrRefreshString implements RefreshString {
  @override
  String? canLoadingText = "Relâchez pour charger davantage";

  @override
  String? canRefreshText = "Relâchez pour rafraîchir";

  @override
  String? canTwoLevelText = "Relâchez pour entrer secondfloor";

  @override
  String? idleLoadingText = "Tirez pour charger davantage";

  @override
  String? idleRefreshText = "Tirez pour rafraîchir";

  @override
  String? loadFailedText = "Chargement échoué";

  @override
  String? loadingText = "Chargement…";

  @override
  String? noMoreText = "Aucune autre donnée";

  @override
  String? refreshCompleteText = "Rafraîchissement terminé";

  @override
  String? refreshFailedText = "Rafraîchissement échoué";

  @override
  String? refreshingText = "Rafraîchissement…";
}

/// Russian
class RuRefreshString implements RefreshString {
  @override
  String? canLoadingText = "Отпустите, чтобы загрузить больше";

  @override
  String? canRefreshText = "Отпустите, чтобы обновить";

  @override
  String? canTwoLevelText = "Отпустите, чтобы войти на второй уровень";

  @override
  String? idleLoadingText = "Тянуть вверх, чтобы загрузить больше";

  @override
  String? idleRefreshText = "Тянуть вниз, чтобы обновить";

  @override
  String? loadFailedText = "Ошибка загрузки";

  @override
  String? loadingText = "Загрузка…";

  @override
  String? noMoreText = "Больше данных нет";

  @override
  String? refreshCompleteText = "Обновление завершено";

  @override
  String? refreshFailedText = "Не удалось обновить";

  @override
  String? refreshingText = "Обновление…";
}

// Ukrainian
class UkRefreshString implements RefreshString {
  @override
  String? canLoadingText = "Відпустіть, щоб завантажити більше";

  @override
  String? canRefreshText = "Відпустіть, щоб оновити";

  @override
  String? canTwoLevelText = "Відпустіть, щоб увійти на другий рівень";

  @override
  String? idleLoadingText = "Тягнути вгору, щоб завантажити більше";

  @override
  String? idleRefreshText = "Тягнути вниз, щоб оновити";

  @override
  String? loadFailedText = "Помилка завантаження";

  @override
  String? loadingText = "Завантаження…";

  @override
  String? noMoreText = "Більше даних немає";

  @override
  String? refreshCompleteText = "Оновлення завершено";

  @override
  String? refreshFailedText = "Не вдалося оновити";

  @override
  String? refreshingText = "Оновлення…";
}

/// Italian
class ItRefreshString implements RefreshString {
  @override
  String? canLoadingText = "Rilascia per caricare altro";

  @override
  String? canRefreshText = "Rilascia per aggiornare";

  @override
  String? canTwoLevelText = "Rilascia per accedere a secondfloor";

  @override
  String? idleLoadingText = "Tira per caricare altro";

  @override
  String? idleRefreshText = "Tira giù per aggiornare";

  @override
  String? loadFailedText = "Caricamento fallito";

  @override
  String? loadingText = "Caricamento…";

  @override
  String? noMoreText = "Nessun altro elemento";

  @override
  String? refreshCompleteText = "Aggiornamento completato";

  @override
  String? refreshFailedText = "Aggiornamento fallito";

  @override
  String? refreshingText = "Aggiornamento…";
}

/// Japanese
class JpRefreshString implements RefreshString {
  @override
  String? canLoadingText = "指を離して更に読み込む";

  @override
  String? canRefreshText = "指を離して更新";

  @override
  String? canTwoLevelText = "指を離して2段目を表示";

  @override
  String? idleLoadingText = "上方スワイプで更に読み込む";

  @override
  String? idleRefreshText = "下方スワイプでデータを更新";

  @override
  String? loadFailedText = "読み込みが失敗しました";

  @override
  String? loadingText = "読み込み中…";

  @override
  String? noMoreText = "データはありません";

  @override
  String? refreshCompleteText = "更新完了";

  @override
  String? refreshFailedText = "更新が失敗しました";

  @override
  String? refreshingText = "更新中…";
}

/// German
class DeRefreshString implements RefreshString {
  @override
  String? canLoadingText = "Loslassen, um mehr zu laden";

  @override
  String? canRefreshText = "Zum Aktualisieren loslassen";

  @override
  String? canTwoLevelText = "Lassen Sie los, um den zweiten Stock zu betreten";

  @override
  String? idleLoadingText = "Hochziehen, mehr laden";

  @override
  String? idleRefreshText = "Ziehen für Aktualisierung";

  @override
  String? loadFailedText = "Laden ist fehlgeschlagen";

  @override
  String? loadingText = "Lade…";

  @override
  String? noMoreText = "Keine weitere Daten";

  @override
  String? refreshCompleteText = "Aktualisierung fertig";

  @override
  String? refreshFailedText = "Aktualisierung fehlgeschlagen";

  @override
  String? refreshingText = "Aktualisiere…";
}

/// Spanish
class EsRefreshString implements RefreshString {
  @override
  String? canLoadingText = "Suelte para cargar más";

  @override
  String? canRefreshText = "Suelte para actualizar";

  @override
  String? canTwoLevelText = "Suelte para entrar al segundo nivel";

  @override
  String? idleLoadingText = "Tire hacia arriba para cargar más";

  @override
  String? idleRefreshText = "Tire hacia abajo para refrescar";

  @override
  String? loadFailedText = "Error de carga";

  @override
  String? loadingText = "Cargando…";

  @override
  String? noMoreText = "No hay más datos disponibles";

  @override
  String? refreshCompleteText = "Actualización completada";

  @override
  String? refreshFailedText = "Error al actualizar";

  @override
  String? refreshingText = "Actualizando…";
}

/// Dutch
class NlRefreshString implements RefreshString {
  @override
  String? canLoadingText = "Laat los om meer te laden";

  @override
  String? canRefreshText = "Laat los om te vernieuwen";

  @override
  String? canTwoLevelText = "Laat los om naar tweede verdieping te gaan";

  @override
  String? idleLoadingText = "Trek omhoog om meer te laden";

  @override
  String? idleRefreshText = "Trek omlaag om te vernieuwen";

  @override
  String? loadFailedText = "Laden mislukt";

  @override
  String? loadingText = "Laden…";

  @override
  String? noMoreText = "Geen data meer";

  @override
  String? refreshCompleteText = "Vernieuwen voltooid";

  @override
  String? refreshFailedText = "Vernieuwen mislukt";

  @override
  String? refreshingText = "Vernieuwen…";
}

/// Swedish
class SvRefreshString implements RefreshString {
  @override
  String? canLoadingText = "Släpp för att ladda mer";

  @override
  String? canRefreshText = "Släpp för att uppdatera";

  @override
  String? canTwoLevelText = "Släpp för att gå till andra våningen";

  @override
  String? idleLoadingText = "Dra upp för att ladda mer";

  @override
  String? idleRefreshText = "Dra ner för att uppdatera";

  @override
  String? loadFailedText = "Hämtningen misslyckades";

  @override
  String? loadingText = "Laddar…";

  @override
  String? noMoreText = "Ingen mer data";

  @override
  String? refreshCompleteText = "Uppdaterad";

  @override
  String? refreshFailedText = "Kunde inte uppdatera";

  @override
  String? refreshingText = "Uppdaterar…";
}

// Portuguese - Brazil
class PtRefreshString implements RefreshString {
  @override
  String? canLoadingText = "Solte para carregar mais";

  @override
  String? canRefreshText = "Solte para atualizar";

  @override
  String? canTwoLevelText = "Solte para entrar no segundo andar";

  @override
  String? idleLoadingText = "Puxe para cima para carregar mais";

  @override
  String? idleRefreshText = "Puxe para baixo para atualizar";

  @override
  String? loadFailedText = "Falha ao carregar";

  @override
  String? loadingText = "Carregando…";

  @override
  String? noMoreText = "Não há mais dados";

  @override
  String? refreshCompleteText = "Atualização completada";

  @override
  String? refreshFailedText = "Falha ao atualizar";

  @override
  String? refreshingText = "Atualizando…";
}

/// Korean
class KrRefreshString implements RefreshString {
  @override
  String? canLoadingText = "당겨서 불러오기";

  @override
  String? canRefreshText = "당겨서 새로 고침";

  @override
  String? canTwoLevelText = "두 번째 레벨로 이동";

  @override
  String? idleLoadingText = "위로 당겨서 불러오기";

  @override
  String? idleRefreshText = "아래로 당겨서 새로 고침";

  @override
  String? loadFailedText = "로딩에 실패했습니다.";

  @override
  String? loadingText = "로딩 중…";

  @override
  String? noMoreText = "데이터가 더 이상 없습니다.";

  @override
  String? refreshCompleteText = "새로 고침 완료";

  @override
  String? refreshFailedText = "새로 고침에 실패했습니다.";

  @override
  String? refreshingText = "새로 고침 중…";
}
