/*
 * Author: Jpeng
 * Email: peng8350@gmail.com
 * Time: 2019/5/3 下午6:13
 */
import 'package:flutter/material.dart';
import 'package:residemenu/residemenu.dart';
import 'test/TestPage.dart';

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
    with SingleTickerProviderStateMixin {
  List<Widget> views;
  MenuController _menuController;
  int _tabIndex = 1;

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
    _menuController = MenuController(vsync: this);
    views = [Container(), TestPage(title: "测试界面"), Container()];
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ResideMenu.scafford(
      controller: _menuController,
      enableScale: false,
      child: Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(widget.title),
        ),
        body: Stack(
          children: <Widget>[
            Offstage(
              child: views[0],
              offstage: _tabIndex != 0,
            ),
            Offstage(
              child: views[1],
              offstage: _tabIndex != 1,
            ),
            Offstage(
              child: views[2],
              offstage: _tabIndex != 2,
            ),
          ],
        ),
      ),
      decoration: BoxDecoration(
          color: Colors.purple),
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
            _menuController.closeMenu();
          }),
          buildItem("测试界面",
              Icon(Icons.airplanemode_active, size: 18, color: Colors.grey),
              () {
            setState(() {
              _tabIndex = 1;
            });
            _menuController.closeMenu();
          }),
          buildItem(
              "待定", Icon(Icons.format_underlined, size: 18, color: Colors.grey),
              () {
            setState(() {
              _tabIndex = 2;
            });
            _menuController.closeMenu();
          }),
        ],
      ),
    );
  }
}
