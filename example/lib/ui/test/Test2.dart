import 'dart:async';
import 'dart:convert' show json, base64Decode;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as HTTP;
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Test2 extends StatefulWidget {
  @override
  _Test2State createState() => _Test2State();
}

class _Test2State extends State<Test2>
    with TickerProviderStateMixin  {
  RefreshController _controller;
  int indexPage = 0;
  List<String> data = [];

  void _fetch() {
    HTTP
        .get(
            'http://gank.io/api/data/福利/10/$indexPage')
        .then((HTTP.Response response) {
      Map map = json.decode(response.body);
      return map["results"];
    }).then((array) {
      for (var item in array) {
        data.add(item["url"]);
      }
      if (mounted) setState(() {});
      _controller.loadComplete();
      indexPage++;
    }).catchError((_) {
      print("error");
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

  void _onOffsetCallback(bool isUp, double offset) {
    // if you want change some widgets state ,you should rewrite the callback
    if (isUp) {
    } else {}
  }

  Widget _headerCreate(BuildContext context, RefreshStatus mode) {
    if (mode == RefreshStatus.refreshing) {
      return SpinKitCircle(color: Colors.greenAccent);
    } else {
      return SpinKitDualRing(color: Colors.greenAccent);
    }
  }

  Widget _footerCreate(BuildContext context, LoadStatus mode) {
    return Image.memory(base64Decode(
        "R0lGODlhFAAUALMAAGaZADOZzP8zM5mZmczMzNra2t7e3uLi4uXl5enp6e3t7fHx8fb29vn5+f7+/gAAACH/C05FVFNDQVBFMi4wAwEAAAAh/g9Qb3dlcmVkIGJ5IEFGRUkAIfkECRQADwAsAAAAABQAFAAABJLwkUmrpdLpzfue2jA4YliKowOmZBtu6drMQ1PbM96oBJnXwF+O52CIjEiU8UhcOJ/Q6KIpDQSkU5Biy1VYtwAAl5gomxPWcthMLgsE5XRiXSYi7u+79R6+I4gHgW+BVoFhgQdEBotvi1aLYYsGiowCjgGQAJJEBZ1vnVadYZ0FnJ4CoAGiAKREHq8cBBIXtBUPEQAh+QQJFAAPACwAAAAAFAAUAAAEjPCRSaul0unN+57aMDhiWIqjA6ZkG27p2sxDU9sz3qgEmdfAX47nYIiMSJTxSFw4n9DooimtOomKrECQ7XqzxIR4Ky6bxeGx4JwAAMpEhHwrryPcdeJhv937D25+RAaEW4QBAYRuhAaDhQKHiQaLhEQFl1uXiJdulwWWmAKaAZwAnkQeqRwEEheuFQ8RADs="));
  }

  ScrollController _scrollController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _scrollController = ScrollController(keepScrollOffset: true);
    _controller = RefreshController();

    _fetch();
  }

  @override
  Widget build(BuildContext context) {

    return SmartRefresher(
      enablePullDown: true,
      enablePullUp: true,
      controller: _controller,
      onRefresh: _onRefresh,
      header: ClassicHeader(),
      onLoading: _onLoading,
      onOffsetChange: _onOffsetCallback,
      child: GridView.builder(
        gridDelegate:
            SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
        physics: ClampingScrollPhysics(),
        itemCount: data.length,
        itemBuilder: buildImage,
      ),
    );
  }

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
    return Container(
      child: FadeInImage(
        placeholder: AssetImage("images/empty.png"),
        image: NetworkImage(
          widget.url,
        ),
      ),

    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
}
