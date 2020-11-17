/*
 * Author: Jpeng
 * Email: peng8350@gmail.com
 * Time: 2019/5/3 下午6:13
 */

import 'package:flutter/material.dart';
import 'package:residemenu/residemenu.dart';
import 'example/ExamplePage.dart';
import 'test/TestPage.dart';
import 'indicator/IndicatorPage.dart';

class MainActivity extends StatefulWidget {
  final String title;

  MainActivity({this.title});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _MainActivityState();
  }
}

class _MainActivityState extends State<MainActivity>
    with TickerProviderStateMixin {
  List<Widget> views;
  MenuController _menuController;
  TabController _tabController;
  int _tabIndex = 1;
  PageController _pageController;

  Widget buildItem(String msg, Widget icon, Function voidCallBack) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        child: ResideMenuItem(
          title: msg,
          icon: icon,
          right: const Icon(Icons.arrow_forward, color: Colors.grey),
        ),
        onTap: voidCallBack,
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _menuController =
        MenuController(vsync: this, direction: ScrollDirection.LEFT);
    _pageController = PageController(initialPage: 1);
    views = [
      IndicatorPage(title: "指示器界面"),
      ExamplePage(),
      TestPage(title: "测试界面"),
    ];
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ResideMenu.scaffold(
      controller: _menuController,
      enable3dRotate: true,
      child: Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(_tabIndex == 0
              ? "指示器界面"
              : _tabIndex == 1
                  ? "例子界面"
                  : _tabIndex == 2
                      ? "测试界面"
                      : _tabIndex == 3
                          ? "样例界面"
                          : "App界面"),
          leading: GestureDetector(
            child: Icon(Icons.menu),
            onTap: () {
              _menuController.openMenu(true);
            },
          ),
          backgroundColor: Colors.greenAccent,
          bottom: _tabIndex == 3
              ? TabBar(
                  isScrollable: true,
                  tabs: [
                    Tab(child: Text("超大数据量性能测试")),
                    Tab(child: Text("SliverAppbar+Sliverheader")),
                    Tab(child: Text("嵌套滚动视图")),
                    Tab(child: Text("动态变化指示器+Navigator")),
                    Tab(child: Text("主动刷新")),
                    Tab(child: Text("四个方向不同风格测试绘制")),
                  ],
                  controller: _tabController,
                )
              : null,
        ),
        body: PageView(
          controller: _pageController,
          children: views,
          physics: NeverScrollableScrollPhysics(),
        ),
      ),
      decoration: BoxDecoration(color: Colors.purple),
      leftScaffold: MenuScaffold(
        header: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: 80.0, maxWidth: 80.0),
          child: CircleAvatar(
            backgroundImage: NetworkImage(
                'https://avatars1.githubusercontent.com/u/19425362?s=400&u=1a30f9fdf71cc9a51e20729b2fa1410c710d0f2f&v=4'),
            radius: 40.0,
          ),
        ),
        children: <Widget>[
          buildItem("各种指示器", Icon(Icons.apps, size: 18, color: Colors.grey),
              () {
            setState(() {
              _tabIndex = 0;
            });
            _pageController.jumpToPage(0);
            _menuController.closeMenu();
          }),
          buildItem(
              "例子", Icon(Icons.insert_emoticon, size: 18, color: Colors.grey),
              () {
            setState(() {
              _tabIndex = 1;
            });
            _pageController.jumpToPage(1);
            _menuController.closeMenu();
          }),
          buildItem("测试",
              Icon(Icons.airplanemode_active, size: 18, color: Colors.grey),
              () {
            setState(() {
              _tabIndex = 2;
            });
            _menuController.closeMenu();
            _pageController.jumpToPage(2);
          }),
        ],
      ),
    );
  }
}
