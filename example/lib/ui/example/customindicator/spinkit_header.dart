/*
 * Author: Jpeng
 * Email: peng8350@gmail.com
 * Time:  2019-06-25 14:21
 */

/*
   here,I use SpinKit as a
 */

import 'dart:io';

import 'package:flutter/material.dart';
import '../../../other/custom_spinkit.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

/*
   this example show you how to custom your indicator with CustomHeader and CustomFooter,
   now I use Spinkit as a example,Custom a Spinkit Indicator with Scale effect.
   notice that SpinKit I have updated some functions,expose a AnimationController for controll
   the animation when refreshing. see "other/custom_spinkit.dart"

 */
class CustomHeaderExample extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _CustomHeaderExampleState();
  }
}

class _CustomHeaderExampleState extends State<CustomHeaderExample>
    with TickerProviderStateMixin {
  AnimationController _anicontroller, _scaleController;

  RefreshController _refreshController = RefreshController();
  @override
  void initState() {
    // TODO: implement initState
    _anicontroller = AnimationController(
        vsync: this, duration: Duration(milliseconds: 2000));
    _scaleController =
        AnimationController(value: 0.0, vsync: this, upperBound: 1.0);
    _refreshController.headerMode.addListener(() {
      if (_refreshController.headerStatus == RefreshStatus.idle) {
        _scaleController.value = 0.0;
        _anicontroller.reset();
      } else if (_refreshController.headerStatus == RefreshStatus.refreshing) {
        _anicontroller.repeat();
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _refreshController.dispose();
    _scaleController.dispose();
    _anicontroller.dispose();
    super.dispose();
  }

  void _onOffsetChange(bool up, double offset) {
    if (up &&
        (_refreshController.headerStatus == RefreshStatus.idle ||
            _refreshController.headerStatus == RefreshStatus.canRefresh)) {
      // 80.0 is headerTriggerDistance default value
      _scaleController.value = offset / 80.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      child: SmartRefresher(
        controller: _refreshController,
        onOffsetChange: _onOffsetChange,
        onRefresh: () async {
          await Future.delayed(Duration(milliseconds: 1000));
          _refreshController.refreshCompleted();
        },
        child: Container(
          color: Colors.red,
          height: 800.0,
        ),
        header: CustomHeader(
          refreshStyle: RefreshStyle.Behind,
          builder: (c, m) {
            return Container(
              child: ScaleTransition(
                child: SpinKitFadingCircle(
                  size: 30.0,
                  animationController: _anicontroller,
                  itemBuilder: (_, int index) {
                    return DecoratedBox(
                      decoration: BoxDecoration(
                        color: index.isEven ? Colors.red : Colors.green,
                      ),
                    );
                  },
                ),
                scale: _scaleController,
              ),
              alignment: Alignment.topCenter,
              color: Colors.green,
            );
          },
        ),
      ),
      color: Colors.grey,
    );
  }
}
