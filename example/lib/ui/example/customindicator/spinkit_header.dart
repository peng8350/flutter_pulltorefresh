/*
 * Author: Jpeng
 * Email: peng8350@gmail.com
 * Time:  2019-06-25 14:21
 */

/*
   here,I use SpinKit as a
 */

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
  AnimationController _footerController;
  RefreshController _refreshController = RefreshController();
  int count = 20;
  @override
  void initState() {
    // TODO: implement initState
    _anicontroller = AnimationController(
        vsync: this, duration: Duration(milliseconds: 2000));
    _scaleController =
        AnimationController(value: 0.0, vsync: this, upperBound: 1.0);
    _footerController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 2000));
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
    _footerController.dispose();
    _anicontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      child: SmartRefresher(
        enablePullUp: true,
        controller: _refreshController,
        onRefresh: () async {
          await Future.delayed(Duration(milliseconds: 1000));
          _refreshController.refreshCompleted();
        },
        onLoading: () async {
          await Future.delayed(Duration(milliseconds: 1000));
          count += 4;
          setState(() {});
          _refreshController.loadComplete();
        },
        child: ListView.builder(
          itemBuilder: (c, i) => Card(),
          itemExtent: 100,
          itemCount: count,
        ),
        footer: CustomFooter(
          onModeChange: (mode) {
            if (mode == LoadStatus.loading) {
              _scaleController.value = 0.0;
              _footerController.repeat();
            } else {
              _footerController.reset();
            }
          },
          builder: (context, mode) {
            Widget child;
            switch (mode) {
              case LoadStatus.failed:
                child = Text("failed,click retry");
                break;
              case LoadStatus.noMore:
                child = Text("no more data");
                break;
              default:
                child = SpinKitFadingCircle(
                  size: 30.0,
                  animationController: _footerController,
                  itemBuilder: (_, int index) {
                    return DecoratedBox(
                      decoration: BoxDecoration(
                        color: index.isEven ? Colors.red : Colors.green,
                      ),
                    );
                  },
                );
                break;
            }
            return Container(
              height: 60,
              child: Center(
                child: child,
              ),
            );
          },
        ),
        header: CustomHeader(
          refreshStyle: RefreshStyle.Behind,
          onOffsetChange: (offset) {
            if (_refreshController.headerMode.value != RefreshStatus.refreshing)
              _scaleController.value = offset / 80.0;
          },
          builder: (c, m) {
            return Container(
              child: FadeTransition(
                opacity: _scaleController,
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
              ),
              alignment: Alignment.center,
            );
          },
        ),
      ),
    );
  }
}
