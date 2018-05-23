import 'package:flutter/widgets.dart';

/*
    Author: Jpeng
    Email: peng8350@gmail.com
    createTime:2018-05-17 10:39
 */


typedef void OnRefresh(bool up);
typedef void OnOffsetChange(bool up, double offset);
typedef Widget IndicatorBuilder(BuildContext context, int mode);

const int default_completeDuration = 800;

const double default_refresh_triggerDistance = 100.0;

const double default_load_triggerDistance = 5.0;

const double default_VisibleRange = 50.0;

const bool default_AutoLoad = true;

const bool default_enablePullDown = true;

const bool default_enablePullUp = false;

const bool default_BottomWhenBuild = true;

const bool default_enableOverScroll = true;

const int spaceAnimateMill=300;

const double minSpace = 0.000001;