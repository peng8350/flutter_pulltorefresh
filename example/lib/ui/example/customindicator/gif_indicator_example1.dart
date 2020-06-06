/*
 * Author: Jpeng
 * Email: peng8350@gmail.com
 * Time:  2019-07-26 18:22
 */

import 'package:flutter/widgets.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_gifimage/flutter_gifimage.dart';
import 'package:flutter/material.dart'
    hide RefreshIndicator, RefreshIndicatorState;

/*
  I use my plugin to implements gif effect,this plugin can help you to controll gif easily,
  see page to find about usage: (https://github.com/peng8350/flutter_gifimage)
*/
class GifHeader1 extends RefreshIndicator {
  GifHeader1() : super(height: 80.0, refreshStyle: RefreshStyle.Follow);
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return GifHeader1State();
  }
}

class GifHeader1State extends RefreshIndicatorState<GifHeader1>
    with SingleTickerProviderStateMixin {
  GifController _gifController;

  @override
  void initState() {
    // TODO: implement initState
    // init frame is 2
    _gifController = GifController(
      vsync: this,
      value: 1,
    );
    super.initState();
  }

  @override
  void onModeChange(RefreshStatus mode) {
    // TODO: implement onModeChange
    if (mode == RefreshStatus.refreshing) {
      _gifController.repeat(
          min: 0, max: 29, period: Duration(milliseconds: 500));
    }
    super.onModeChange(mode);
  }

  @override
  Future<void> endRefresh() {
    // TODO: implement endRefresh
    _gifController.value = 30;
    return _gifController.animateTo(59, duration: Duration(milliseconds: 500));
  }

  @override
  void resetValue() {
    // TODO: implement resetValue
    // reset not ok , the plugin need to update lowwer
    _gifController.value = 0;
    super.resetValue();
  }

  @override
  Widget buildContent(BuildContext context, RefreshStatus mode) {
    // TODO: implement buildContent
    return GifImage(
      image: AssetImage("images/gifindicator1.gif"),
      controller: _gifController,
      height: 80.0,
      width: 537.0,
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _gifController.dispose();
    super.dispose();
  }
}

class GifFooter1 extends StatefulWidget {
  GifFooter1() : super();

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _GifFooter1State();
  }
}

class _GifFooter1State extends State<GifFooter1>
    with SingleTickerProviderStateMixin {
  GifController _gifController;

  @override
  void initState() {
    // TODO: implement initState
    // init frame is 2
    _gifController = GifController(
      vsync: this,
      value: 1,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return CustomFooter(
      height: 80,
      builder: (context, mode) {
        return GifImage(
          image: AssetImage("images/gifindicator1.gif"),
          controller: _gifController,
          height: 80.0,
          width: 537.0,
        );
      },
      loadStyle: LoadStyle.ShowWhenLoading,
      onModeChange: (mode) {
        if (mode == LoadStatus.loading) {
          _gifController.repeat(
              min: 0, max: 29, period: Duration(milliseconds: 500));
        }
      },
      endLoading: () async {
        _gifController.value = 30;
        return _gifController.animateTo(59,
            duration: Duration(milliseconds: 500));
      },
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _gifController.dispose();
    super.dispose();
  }
}

class GifIndicatorExample1 extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return GifIndicatorExample1State();
  }
}

class GifIndicatorExample1State extends State<GifIndicatorExample1> {
  RefreshController _controller = RefreshController();
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return RefreshConfiguration.copyAncestor(
      context: context,
      // two attrs enable footer implements the effect in header default
      enableBallisticLoad: false,
      footerTriggerDistance: -80,
      child: SmartRefresher(
        controller: _controller,
        enablePullUp: true,
        header: GifHeader1(),
        footer: GifFooter1(),
        onRefresh: () async {
          await Future.delayed(Duration(milliseconds: 2000));
          _controller.refreshCompleted();
        },
        onLoading: () async {
          await Future.delayed(Duration(milliseconds: 2000));
          _controller.loadFailed();
        },
        child: ListView.builder(
          itemBuilder: (c, q) => Card(),
          itemCount: 50,
          itemExtent: 100.0,
        ),
      ),
    );
  }
}
