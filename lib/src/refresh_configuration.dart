/*
 * Author: Jpeng
 * Email: peng8350@gmail.com
 * Time:  2019-05-27 13:08
 */

import 'package:flutter/widgets.dart';

class RefreshConfiguration extends InheritedWidget {
  final Function headerBuilder;
  final Function footerBuilder;
  final bool autoLoad;
  final Duration completeDuration;
  final Widget child;

  RefreshConfiguration(
      {@required this.child,
      this.headerBuilder,
      this.footerBuilder,
      this.autoLoad,
      this.completeDuration});

  static RefreshConfiguration of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(RefreshConfiguration);
  }

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => false;
}
