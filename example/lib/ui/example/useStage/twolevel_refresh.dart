/*
 * Author: Jpeng
 * Email: peng8350@gmail.com
 * Time:  2019-06-26 16:28
 */

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'
    hide RefreshIndicator, RefreshIndicatorState;
import 'package:flutter/widgets.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

/*
   there two example implements two level,
   the first is common,when twoRefreshing,header will follow the list to scrollDown,when closing,still follow
   list move up,
   the second example use Navigator and keep offset when twoLevel trigger,
   header can use ClassicalHeader to implments twoLevel,it provide outerBuilder(1.4.7)
   important point:
   1. open enableTwiceRefresh bool ,default is false
   2. _refreshController.twiceRefreshComplete() can closing the two level
*/
class TwoLevelExample extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _TwoLevelExampleState();
  }
}

class _TwoLevelExampleState extends State<TwoLevelExample> {
  RefreshController _refreshController1 =
      RefreshController();
  RefreshController _refreshController2 = RefreshController();
  int _tabIndex = 0;

  @override
  void initState() {
    // TODO: implement initState
    _refreshController1.headerMode.addListener((){
        setState(() {

        });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    print(!_refreshController1.isTwoLevel);
    return RefreshConfiguration.copyAncestor(
      context: context,
      enableScrollWhenTwoLevel: true,
      maxOverScrollExtent: 120,
      child: Scaffold(
        bottomNavigationBar: !_refreshController1.isTwoLevel?BottomNavigationBar(
          currentIndex: _tabIndex,
          onTap: (index) {
            _tabIndex = index;
            if (mounted) setState(() {});
          },
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.add), title: Text("二级刷新例子1")),
            BottomNavigationBarItem(
                icon: Icon(Icons.border_clear), title: Text("二级刷新例子2"))
          ],
        ):null,
        body: Stack(
          children: <Widget>[
            Offstage(
              offstage: _tabIndex != 0,
              child: LayoutBuilder(
                builder: (_, c) {
                  return SmartRefresher(
                    header: TwoLevelHeader(
                      textStyle: TextStyle(
                          color: Colors.white
                      ),
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage("images/secondfloor.jpg"),
                            fit:BoxFit.cover
                        ),
                      ),
                      twoLevelWidget: TwoLevelWidget(),
                    ),
                    child: CustomScrollView(
                      physics: ClampingScrollPhysics(),
                      slivers: <Widget>[
                        SliverToBoxAdapter(
                          child: Container(
                            child: Scaffold(
                              appBar: AppBar(),
                              body: Column(
                                children: <Widget>[
                                  RaisedButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text("点击这里返回上一页!"),
                                  )
                                ],
                              ),
                            ),
                            height: 500.0,
                          ),
                        )
                      ],
                    ),
                    controller: _refreshController1,
                    enableTwoLevel: true,
                    enablePullDown: true,
                    onRefresh: () async {
                      await Future.delayed(Duration(milliseconds: 2000));
                      _refreshController1.refreshCompleted();
                    },
                    onTwoLevel: () {},
                  );
                },
              ),
            ),
            Offstage(
              offstage: _tabIndex != 1,
              child: SmartRefresher(
                header: ClassicHeader(),
                child: CustomScrollView(
                  physics: ClampingScrollPhysics(),
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
                enableTwoLevel: true,
                onRefresh: () async {
                  await Future.delayed(Duration(milliseconds: 2000));
                  _refreshController2.refreshCompleted();
                },
                onTwoLevel: () {
                  print("Asd");
                  _refreshController2.position.hold(() {});
                  Navigator.of(context)
                      .push(MaterialPageRoute(
                      builder: (c) => Scaffold(
                        appBar: AppBar(),
                        body: Text("二楼刷新"),
                      )))
                      .whenComplete(() {
                    _refreshController2.twoLevelComplete(
                        duration: Duration(microseconds: 1));
                  });
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}


class TwoLevelWidget extends StatelessWidget{


  @override
  Widget build(BuildContext context) {

    // TODO: implement build
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
            image: AssetImage("images/secondfloor.jpg"),
            fit:BoxFit.cover
        ),
      ),
      child: Stack(
        children: <Widget>[
          Center(
            child: Wrap(
              children: <Widget>[
                RaisedButton(
                  color: Colors.greenAccent,
                  onPressed: () {},
                  child: Text("登陆"),
                ),
              ],
            ),
          ),
          Container(
            height: 60.0,
            child: GestureDetector(
              child: Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
              ),
              onTap: () {
                SmartRefresher.of(context).controller.twoLevelComplete();
              },
            ),
            alignment: Alignment.bottomLeft,
          ),
        ],
      ),
    );
  }

}