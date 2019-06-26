/*
 * Author: Jpeng
 * Email: peng8350@gmail.com
 * Time:  2019-06-26 16:28
 */

import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class TwoLevelExample extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _TwoLevelExampleState();
  }
}

class _TwoLevelExampleState extends State<TwoLevelExample> {
  RefreshController _refreshController = RefreshController();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return LayoutBuilder(
      builder: (q, c) {
        double height = c.biggest.height;
        double width = c.biggest.width;
        return Scaffold(
          body: RefreshConfiguration(
            child: Stack(
              children: <Widget>[
                SmartRefresher(
                  header: CustomHeader(
                    height: 300.0,
                    refreshStyle: RefreshStyle.Behind,
                    builder: (BuildContext c, RefreshStatus mode) {
                      return Align(
                        alignment: Alignment.bottomCenter,
                        child: Stack(
                          children: <Widget>[
                            Hero(
                              tag: "Aa",
                              child: Image.asset(
                                "images/secondfloor.jpg",
                                fit: BoxFit.cover,
                                height: height,
                                width: width,
                              ),
                            ),
                            Container(
                              child: Text(
                                  mode == RefreshStatus.idle
                                      ? "下拉刷新!"
                                      : mode == RefreshStatus.canRefresh
                                          ? "释放刷新!"
                                          : mode ==
                                                  RefreshStatus.canTwiceRefresh
                                              ? "松手进入二楼!"
                                              : mode == RefreshStatus.refreshing
                                                  ? "刷新中..."
                                                  : "刷新完成!",
                                  style: TextStyle(color: Colors.white)),
                              alignment: Alignment.bottomCenter,
                            )
                          ],
                        ),
                      );
                    },
                  ),
                  child: CustomScrollView(
                    slivers: <Widget>[
                      SliverToBoxAdapter(
                        child: Container(
                          child: RaisedButton(onPressed: (){
                            Navigator.of(context).pop();
                          },child: Text("点击这里返回上一页!"),),
                          color: Colors.red,
                          height: 680.0,
                        ),
                      )
                    ],
                  ),
                  controller: _refreshController,
                  enableTwiceRefresh: true,
                  onRefresh: () async {
                    await Future.delayed(Duration(milliseconds: 2000));
                    _refreshController.refreshCompleted();
                  },
                  onTwiceRefresh: () {
                    Navigator.of(context).push(PageRouteBuilder(
                        pageBuilder: (c, animation, _) {
                          return Hero(
                            tag: "Aa",
                            child: Container(
                              child: Center(
                                child: RaisedButton(
                                  onPressed: (){
                                    Navigator.of(context).pop();
                                  },
                                  color: Colors.red,
                                  child: Text("点这里返回"),
                                ),
                              ),
                              decoration: BoxDecoration(image: DecorationImage(
                                image: AssetImage(
                                  "images/secondfloor.jpg",

                                ),fit: BoxFit.cover,
                              )),
                            ),
                          );
                        },
                        transitionDuration: Duration(milliseconds: 2000)

                    )).whenComplete((){
                      //import,you should call this ,else it will keep height
                      _refreshController.twiceRefreshCompleted();
                    });
                  },
                )
              ],
            ),
            maxUnderScrollExtent: 0.0,
          ),
        );
      },
    );
  }
}
