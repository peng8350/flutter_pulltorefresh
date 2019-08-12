/*
 * Author: Jpeng
 * Email: peng8350@gmail.com
 * Time:  2019-06-24 17:13
 */

/*
  this example will show you how to hide Footer by the sizeOfContent,
  SmartRefresher has an ability to automatically hide indicators when less than one page,e
   when your slivers have some complex sliver,which will cause error hiding,so You need to hide it  yourself.
   though many widgets provided by flutter doesn't have this situation
   first step:  give RefreshConfiguration's hideFooterWhenNotFull = false
   second step:  use LayoutBuilder get the Widget height
   third step: Use your judgment to decide whether to hide footer, enablePullUp = false
 */
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class HideFooterManual extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return HideFooterManualState();
  }
}

class HideFooterManualState extends State<HideFooterManual> {
  RefreshController _controller = RefreshController();

  List<String> strs = ["1", "2"];

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return RefreshConfiguration.copyAncestor(
      context: context,
      child: LayoutBuilder(
        builder: (b, c) {
          double refresherHeight = c.biggest.height -
              50.0; // 50.0 is Container's height before SmartRefresher
          return Column(
            children: <Widget>[
              Container(
                height: 50.0,
              ),
              Expanded(
                child: SmartRefresher(
                  controller: _controller,
                  enablePullUp: refresherHeight < 100.0 * strs.length,
                  //100.0 is itemExtent in SliverList
                  onLoading: () {
                    strs.add("new");
                    if (mounted) setState(() {});
                    _controller.loadComplete();
                  },
                  onRefresh: () {
                    strs.add("new");
                    if (mounted) setState(() {});
                    _controller.refreshCompleted();
                  },
                  child: CustomScrollView(
                    slivers: <Widget>[
                      SliverFixedExtentList(
                        delegate: SliverChildBuilderDelegate(
                            (c, i) => Text(strs[i]),
                            childCount: strs.length),
                        itemExtent: 100.0,
                      )
                    ],
                  ),
                ),
              )
            ],
          );
        },
      ),
      hideFooterWhenNotFull: false,
    );
  }
}
