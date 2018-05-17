/*
    Author: Jpeng
    Email: peng8350@gmail.com
    createTime:2018-05-14 15:39
 */

import 'default_constants.dart';

/*
 * This will use to configure the Wrapper action
 */
abstract class Config {
  final double triggerDistance;

  const Config({this.triggerDistance});
}

class RefreshConfig extends Config {
  final int completeDuration;
  final double visibleRange;
  const RefreshConfig(
      {this.visibleRange: default_VisibleRange,
      double triggerDistance: default_refresh_triggerDistance,
      this.completeDuration: default_completeDuration})
      : super(triggerDistance: triggerDistance);
}

class LoadConfig extends Config {
  final bool autoLoad;

  const LoadConfig({
    this.autoLoad: default_AutoLoad,
    double triggerDistance: default_load_triggerDistance,
  }) : super(triggerDistance: triggerDistance);
}
