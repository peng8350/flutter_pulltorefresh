/*
 * Author: Jpeng
 * Email: peng8350@gmail.com
 * Time:  2019-06-24 17:23
 */

import 'dart:async';
import 'dart:convert' show json;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../Item.dart';
import 'package:http/http.dart' as HTTP;
import 'package:pull_to_refresh/pull_to_refresh.dart';

/*
   this example will show you how to implements horizontal refresh or reverse,
   the main point is in child scrollDirection attr
 */
class HorizontalRefresh extends StatefulWidget {
  @override
  _HorizontalRefreshState createState() => _HorizontalRefreshState();
}

class _HorizontalRefreshState extends State<HorizontalRefresh>
    with TickerProviderStateMixin {
  RefreshController _controller1 = RefreshController();
  RefreshController _controller2 = RefreshController();
  int indexPage = 0;
  List<String> data = [];

  void _fetch() {
    HTTP
        .get(
            'https://gank.io/api/v2/data/category/Girl/type/Girl/page/$indexPage/count/10')
        .then((HTTP.Response response) {
      Map map = json.decode(response.body);
      return map["data"];
    }).then((array) {
      for (var item in array) {
        data.add(item["url"]);
      }
      if (mounted) setState(() {});
      _controller1.loadComplete();
      indexPage++;
    }).catchError((_) {
      print("error");
      _controller1.loadComplete();
    });
  }

  void _onRefresh() {
    Future.delayed(const Duration(milliseconds: 2009)).then((val) {
      _controller1.refreshCompleted();
//                refresher.sendStatus(RefreshStatus.completed);
    });
  }

  void _onLoading() {
    Future.delayed(const Duration(milliseconds: 2009)).then((val) {
      _fetch();
    });
  }

  Widget buildImage(context, index) {
    return GestureDetector(
      child: Item1(
        url: data[index],
      ),
      onTap: () {
        _controller1.requestRefresh();
      },
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller1 = RefreshController();
    _fetch();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          child: SmartRefresher(
            enablePullDown: true,
            enablePullUp: true,
            controller: _controller1,
            onRefresh: _onRefresh,
            footer: ClassicFooter(
              iconPos: IconPosition.top,
              outerBuilder: (child) {
                return Container(
                  width: 80.0,
                  child: Center(
                    child: child,
                  ),
                );
              },
            ),
            header: ClassicHeader(
              iconPos: IconPosition.top,
              outerBuilder: (child) {
                return Container(
                  width: 80.0,
                  child: Center(
                    child: child,
                  ),
                );
              },
            ),
            onLoading: _onLoading,
            child: ListView.builder(
              itemCount: data.length,
              scrollDirection: Axis.horizontal,
              physics: ClampingScrollPhysics(),
              itemBuilder: buildImage,
            ),
          ),
          height: 200.0,
        ),
        Expanded(
          child: Container(
            child: SmartRefresher(
              enablePullDown: true,
              enablePullUp: true,
              controller: _controller2,
              onRefresh: () async {
                _controller2.refreshCompleted();
              },
              footer: ClassicFooter(
                iconPos: IconPosition.top,
                outerBuilder: (child) {
                  return Container(
                    width: 80.0,
                    child: Center(
                      child: child,
                    ),
                  );
                },
              ),
              header: WaterDropMaterialHeader(),
              onLoading: () async {
                await Future.delayed(const Duration(milliseconds: 1000));
                if (mounted) setState(() {});
                _controller2.loadComplete();
              },
              child: ListView.builder(
                reverse: true,
                itemCount: data.length,
                physics: ClampingScrollPhysics(),
                itemBuilder: (c, i) => Item(
                  title: "data $i",
                ),
              ),
            ),
            height: 200.0,
          ),
        )
      ],
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => false;
}

class Item1 extends StatefulWidget {
  final String url;

  Item1({this.url});

  @override
  _ItemState createState() => _ItemState();
}

class _ItemState extends State<Item1> {
  @override
  Widget build(BuildContext context) {
    if (widget.url == null) return Container();
    return FadeInImage(
      placeholder: AssetImage("images/empty.png"),
      image: NetworkImage(
        widget.url,
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
}
