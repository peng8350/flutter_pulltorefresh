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


enum TwoLevelDisplayAlignment{
  fromTop,
  fromCenter,
  fromBottom
}

class TwoLevelHeader extends StatelessWidget {
  final BoxDecoration decoration;

  final Widget twoLevelWidget;

  final TwoLevelDisplayAlignment displayAlignment;

  final String releaseText,
      idleText,
      refreshingText,
      completeText,
      failedText,
      canTwoLevelText;
  final Widget releaseIcon,
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

  const TwoLevelHeader({
    Key key,
    this.height: 80.0,
    this.decoration,
    this.displayAlignment:TwoLevelDisplayAlignment.fromBottom,
    this.completeDuration: const Duration(milliseconds: 600),
    this.textStyle: const TextStyle(color: const Color(0xff555555)),
    this.releaseText: 'Refresh when release',
    this.refreshingText: 'Refreshing...',
    this.canTwoLevelIcon,
    this.canTwoLevelText: 'release to enter secondfloor',
    this.completeText: 'Refresh complete',
    this.failedText: 'Refresh failed',
    this.idleText: 'Pull down to refresh',
    this.iconPos: IconPosition.left,
    this.spacing: 15.0,
    this.refreshingIcon,
    this.failedIcon: const Icon(Icons.error, color: Colors.grey),
    this.completeIcon: const Icon(Icons.done, color: Colors.grey),
    this.idleIcon = const Icon(Icons.arrow_downward, color: Colors.grey),
    this.releaseIcon = const Icon(Icons.refresh, color: Colors.grey),
    this.twoLevelWidget
  });


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ClassicHeader(
      refreshStyle: displayAlignment==TwoLevelDisplayAlignment.fromBottom?RefreshStyle.Follow:RefreshStyle.Behind,
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
        final RefreshStatus mode =
            SmartRefresher.of(context).controller.headerStatus;
        final bool isTwoLevel = (mode == RefreshStatus.twoLevelClosing ||
            mode == RefreshStatus.twoLeveling ||
            mode == RefreshStatus.twoLevelOpening);
        if(displayAlignment==TwoLevelDisplayAlignment.fromBottom) {
          return Container(
            decoration: !isTwoLevel
                ? (decoration ?? BoxDecoration(color: Colors.redAccent))
                : null,
            height: SmartRefresher
                .ofState(context)
                .viewportExtent,
            alignment: isTwoLevel ? null : Alignment.bottomCenter,
            child: isTwoLevel
                ? twoLevelWidget
                : Padding(
              child: child,
              padding: EdgeInsets.only(bottom: 15),
            ),
          );
        }
        else{
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

