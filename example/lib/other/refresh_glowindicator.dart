/*
 * Author: Jpeng
 * Email: peng8350@gmail.com
 * Time:  2019-09-08 14:44
 */

import 'package:flutter/material.dart';

// 在不自定义的默认情况下,当你拖到顶端不能再拖的时候会出现光晕,假如你只想在撞击顶部时看到光晕的情况
// 以下例子就是可以解决这种问题

// Android平台 自定义刷新光晕效果
class RefreshScrollBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    // When modifying this function, consider modifying the implementation in
    // _MaterialScrollBehavior as well.
    switch (getPlatform(context)) {
      case TargetPlatform.iOS:
        return child;
      case TargetPlatform.macOS:
      case TargetPlatform.android:
        return GlowingOverscrollIndicator(
          child: child,
          // this will disable top Bouncing OverScroll Indicator showing in Android
          showLeading: true, //顶部水波纹是否展示
          showTrailing: true, //底部水波纹是否展示
          axisDirection: axisDirection,
          notificationPredicate: (notification) {
            if (notification.depth == 0) {
              // 越界了拖动触发overScroll的话就没必要展示水波纹
              if (notification.metrics.outOfRange) {
                return false;
              }
              return true;
            }
            return false;
          },
          color: Theme.of(context).primaryColor,
        );
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
    }
    return null;
  }
}
