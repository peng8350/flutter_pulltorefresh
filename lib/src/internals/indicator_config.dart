import 'package:flutter/widgets.dart';

/*
    Author: Jpeng
    Email: peng8350@gmail.com
    createTime:2018-05-14 15:39
 */


/*
 * This will use to configure the Wrapper action
 */
abstract class Config {
  final double visibleRange;

  final double triggerDistance;

  const Config({this.visibleRange, this.triggerDistance});
}

class RefreshConfig extends Config {
  final int completeTime;

  const RefreshConfig(
      {double visibleRange:50.0, double triggerDistance:70.0, this.completeTime:1000})
      : super(visibleRange: visibleRange, triggerDistance: triggerDistance);
}

class LoadConfig extends Config {
  final bool autoLoad;

  const LoadConfig({
    this.autoLoad:true,
    double visibleRange:50.0,
    double triggerDistance:70.0,
  }) : super(visibleRange: visibleRange, triggerDistance: triggerDistance);
}

