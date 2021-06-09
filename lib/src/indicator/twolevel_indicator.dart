/*
 * Author: Jpeng
 * Email: peng8350@gmail.com
 * Time:  2019-08-29 09:41
 */

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'classic_indicator.dart';
import '../smart_refresher.dart';

enum TwoLevelDisplayAlignment { fromTop, fromCenter, fromBottom }

/// this header help you implements twoLevel function easyily,
/// the behaviour just like TaoBao,XieCheng(携程) App TwoLevel
///
/// just a example
///
/// ```dart
///
///TwoLevelHeader(
///  textStyle: TextStyle(color: Colors.white),
///  displayAlignment: TwoLevelDisplayAlignment.fromTop,
///  decoration: BoxDecoration(
///  image: DecorationImage(
///  image: AssetImage("images/secondfloor.jpg"),
///  fit: BoxFit.cover,
///  // 很重要的属性,这会影响你打开二楼和关闭二楼的动画效果
///  alignment: Alignment.topCenter),
///),
///twoLevelWidget: Container(
///   decoration: BoxDecoration(
///   image: DecorationImage(
///   image: AssetImage("images/secondfloor.jpg"),
//    很重要的属性,这会影响你打开二楼和关闭二楼的动画效果,关联到TwoLevelHeader,如果背景一致的情况,请设置相同
///   alignment: Alignment.topCenter,
///   fit: BoxFit.cover),
///   ),
///   Container(
///     height: 60.0,
///     child: GestureDetector(
///     child: Icon(
///       Icons.arrow_back_ios,
///     color: Colors.white,
///    ),
///   onTap: () {
///     SmartRefresher.of(context).controller.twoLevelComplete();
///   },
///   ),
///   alignment: Alignment.bottomLeft,
///),
///),
///);
///
/// ```
class TwoLevelHeader extends StatelessWidget {
  /// this  attr mostly put image or color
  final BoxDecoration? decoration;

  /// the content in TwoLevel,display in (twoLevelOpening,closing,TwoLeveling state)
  final Widget? twoLevelWidget;

  /// fromTop use with RefreshStyle.Behind,from bottom use with Follow Style
  final TwoLevelDisplayAlignment displayAlignment;
  // the following is the same with ClassicHeader
  final String? releaseText,
      idleText,
      refreshingText,
      completeText,
      failedText,
      canTwoLevelText;

  final Widget? releaseIcon,
      idleIcon,
      refreshingIcon,
      completeIcon,
      failedIcon,
      canTwoLevelIcon;

  /// icon and text middle margin
  final double spacing;
  final IconPosition iconPos;

  final TextStyle textStyle;

  final double height;
  final Duration completeDuration;

  const TwoLevelHeader(
      {Key? key,
      this.height: 80.0,
      this.decoration,
      this.displayAlignment: TwoLevelDisplayAlignment.fromBottom,
      this.completeDuration: const Duration(milliseconds: 600),
      this.textStyle: const TextStyle(color: const Color(0xff555555)),
      this.releaseText,
      this.refreshingText,
      this.canTwoLevelIcon,
      this.canTwoLevelText,
      this.completeText,
      this.failedText,
      this.idleText,
      this.iconPos: IconPosition.left,
      this.spacing: 15.0,
      this.refreshingIcon,
      this.failedIcon: const Icon(Icons.error, color: Colors.grey),
      this.completeIcon: const Icon(Icons.done, color: Colors.grey),
      this.idleIcon = const Icon(Icons.arrow_downward, color: Colors.grey),
      this.releaseIcon = const Icon(Icons.refresh, color: Colors.grey),
      this.twoLevelWidget});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ClassicHeader(
      refreshStyle: displayAlignment == TwoLevelDisplayAlignment.fromBottom
          ? RefreshStyle.Follow
          : RefreshStyle.Behind,
      height: height,
      refreshingIcon: refreshingIcon,
      refreshingText: refreshingText,
      releaseIcon: releaseIcon,
      releaseText: releaseText,
      completeDuration: completeDuration,
      canTwoLevelIcon: canTwoLevelIcon,
      canTwoLevelText: canTwoLevelText,
      failedIcon: failedIcon,
      failedText: failedText,
      idleIcon: idleIcon,
      idleText: idleText,
      completeIcon: completeIcon,
      completeText: completeText,
      spacing: spacing,
      textStyle: textStyle,
      iconPos: iconPos,
      outerBuilder: (child) {
        final RefreshStatus? mode =
            SmartRefresher.of(context)!.controller.headerStatus;
        final bool isTwoLevel = (mode == RefreshStatus.twoLevelClosing ||
            mode == RefreshStatus.twoLeveling ||
            mode == RefreshStatus.twoLevelOpening);
        if (displayAlignment == TwoLevelDisplayAlignment.fromBottom) {
          return Container(
            decoration: !isTwoLevel
                ? (decoration ?? BoxDecoration(color: Colors.redAccent))
                : null,
            height: SmartRefresher.ofState(context)!.viewportExtent,
            alignment: isTwoLevel ? null : Alignment.bottomCenter,
            child: isTwoLevel
                ? twoLevelWidget
                : Padding(
                    child: child,
                    padding: EdgeInsets.only(bottom: 15),
                  ),
          );
        } else {
          return Container(
            child: isTwoLevel
                ? twoLevelWidget
                : Container(
                    decoration: !isTwoLevel
                        ? (decoration ?? BoxDecoration(color: Colors.redAccent))
                        : null,
                    alignment: Alignment.bottomCenter,
                    child: child,
                    padding: EdgeInsets.only(bottom: 15),
                  ),
          );
        }
      },
    );
  }
}
