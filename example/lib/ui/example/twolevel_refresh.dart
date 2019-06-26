/*
 * Author: Jpeng
 * Email: peng8350@gmail.com
 * Time:  2019-06-26 16:28
 */

import 'package:flutter/material.dart' hide RefreshIndicator,RefreshIndicatorState;
import 'package:flutter/widgets.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

/*
   there two example implements two level,
   the first is common,when twoRefreshing,header will follow the list to scrollDown,when closing,still follow
   list move up,
   important point:
   1. open enableTwiceRefresh bool ,default is false
   2. _refreshController.twiceRefreshComplete() can closing the two level
   3. Using RefreshStyle.Behind implements two level ,the effect is better
*/
class TwoLevelExample extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _TwoLevelExampleState();
  }
}

class _TwoLevelExampleState extends State<TwoLevelExample> {
  RefreshController _refreshController1 = RefreshController();
  RefreshController _refreshController2 = RefreshController();
  int _tabIndex  =0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return LayoutBuilder(
      builder: (q, c) {
        double height = c.biggest.height;
        double width = c.biggest.width;
        return Scaffold(
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _tabIndex,
            onTap: (index){
               _tabIndex = index;
               setState(() {

               });
            },
            items: [BottomNavigationBarItem(icon: Icon(Icons.add),title: Text("二级刷新例子1")),BottomNavigationBarItem(icon: Icon(Icons.border_clear),title: Text("二级刷新例子2"))],
          ),
          body: Stack(
            children: <Widget>[
              Offstage(
                offstage: _tabIndex!=0,
                child: SmartRefresher(
                  header: CustomHeader(
                    refreshStyle: RefreshStyle.Behind,
                    builder: (BuildContext c, RefreshStatus mode) {
                      return Align(
                        alignment: Alignment.bottomCenter,
                        child: Scaffold(
                          body: Stack(
                            children: <Widget>[
                              Image.asset(
                                "images/secondfloor.jpg",
                                fit: BoxFit.cover,
                                height: height,
                                width: width,
                              ),
                              _refreshController1.isTwiceRefresh ? AppBar(
                                backgroundColor: Colors.transparent,
                                elevation: 0.0,
                                leading: GestureDetector(
                                  onTap: () {
                                    _refreshController1
                                        .twiceRefreshCompleted();
                                  },
                                  child: Icon(Icons.arrow_back_ios,color: Colors.white,),
                                ),
                              ):null,
                              mode == RefreshStatus.twiceRefreshing
                                  ? Container(
                              )
                                  : Container(
                                child: Text(
                                    mode == RefreshStatus.idle
                                        ? "下拉刷新!"
                                        : mode == RefreshStatus.canRefresh
                                        ? "释放刷新!"
                                        : mode ==
                                        RefreshStatus.refreshing
                                        ? "刷新中..."
                                        : mode ==
                                        RefreshStatus
                                            .canTwiceRefresh
                                        ? "松手有惊喜..."
                                        : "刷新完成!",
                                    style: TextStyle(color: Colors.white)),
                                alignment: Alignment.bottomCenter,
                              )
                            ].where((c) => c!=null).toList(),
                          ),
                        ),
                      );
                    },
                  ),
                  child: CustomScrollView(
                    slivers: <Widget>[
                      SliverToBoxAdapter(
                        child: Container(
                          child: RaisedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text("点击这里返回上一页!"),
                          ),
                          color: Colors.red,
                          height: 680.0,
                        ),
                      )
                    ],
                  ),
                  controller: _refreshController1,
                  enableTwiceRefresh: true,
                  onRefresh: () async {
                    await Future.delayed(Duration(milliseconds: 2000));
                    _refreshController1.refreshCompleted();
                  },
                  onTwiceRefresh: () {
                  },
                ),
              ),
              Offstage(
                offstage: _tabIndex!=1,
                child: SmartRefresher(
                  child: CustomScrollView(
                    slivers: <Widget>[
                      SliverToBoxAdapter(
                        child: Container(
                          child: RaisedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text("点击这里返回上一页!"),
                          ),
                          color: Colors.red,
                          height: 680.0,
                        ),
                      )
                    ],
                  ),
                  controller: _refreshController2,
                  enableTwiceRefresh: true,
                  onRefresh: () async {
                    await Future.delayed(Duration(milliseconds: 2000));
                    _refreshController2.refreshCompleted();
                  },
                  onTwiceRefresh: () {
                    print("Asd");
//                    _refreshController2.position.forcePixels( _refreshController2.position.pixels);
                    Navigator.of(context).push(MaterialPageRoute(builder: (c) => Scaffold(appBar: AppBar(),))).whenComplete((){
                      _refreshController2.twiceRefreshCompleted(needSpringAnimate: false);
                    });
                  },
                ),
              )
            ],
          ),
        );
      },
    );
  }
}

