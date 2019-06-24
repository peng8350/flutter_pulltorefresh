/*
 * Author: Jpeng
 * Email: peng8350@gmail.com
 * Time:  2019-06-24 17:23
 */

import 'dart:async';
import 'dart:convert' show json, base64Decode;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as HTTP;
import 'package:pull_to_refresh/pull_to_refresh.dart';

/*
   this example will show you how to implements horizontal refresh,
   the main point is in child scrollDirection attr
 */
class HorizontalRefresh extends StatefulWidget {
  @override
  _HorizontalRefreshState createState() => _HorizontalRefreshState();
}

class _HorizontalRefreshState extends State<HorizontalRefresh>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  RefreshController _controller;
  int indexPage = 0;
  List<String> data = [];

  void _fetch() {
    HTTP
        .get(
        'http://image.baidu.com/channel/listjson?pn=$indexPage&rn=10&tag1=%E6%98%8E%E6%98%9F&tag2=%E5%85%A8%E9%83%A8&ie=utf8')
        .then((HTTP.Response response) {
      Map map = json.decode(response.body);
      return map["data"];
    }).then((array) {
      for (var item in array) {
        data.add(item["image_url"]);
      }
      if (mounted) setState(() {});
      _controller.loadComplete();
      indexPage++;
    }).catchError((_) {
      _controller.loadComplete();
    });
  }

  void _onRefresh() {
    Future.delayed(const Duration(milliseconds: 2009)).then((val) {
      _controller.refreshCompleted();
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
      child: Item(
        url: data[index],
      ),
      onTap: () {
        _controller.requestRefresh();
      },
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = RefreshController();
    _fetch();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text("这是一个水平滚动带加载更多的图片轮播"),
        Container(
          child: SmartRefresher(
            enablePullDown: false,
            enablePullUp: true,
            controller: _controller,
            onRefresh: _onRefresh,
            header: ClassicHeader(),
            onLoading: _onLoading,
            child: ListView.builder(
              itemCount: data.length,
              scrollDirection: Axis.horizontal,
              physics: ClampingScrollPhysics(),
              itemBuilder: buildImage,
            ),
          ),
          height: 200.0,
        )
      ],
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => false;
}

class Item extends StatefulWidget {
  final String url;

  Item({this.url});

  @override
  _ItemState createState() => _ItemState();
}

class _ItemState extends State<Item> {
  @override
  Widget build(BuildContext context) {
    if (widget.url == null) return Container();
    return RepaintBoundary(
      child: Image.network(
        widget.url,
        width: 200.0,
        height: 200.0,
        fit: BoxFit.cover,
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
}
