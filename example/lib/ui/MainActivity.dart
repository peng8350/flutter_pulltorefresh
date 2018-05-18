import 'Example1.dart';
import 'Example2.dart';
import 'Example3.dart';
import 'Example4.dart';
import 'package:flutter/material.dart';

class MainActivity extends StatefulWidget {
  MainActivity({Key key, this.title}) : super(key: key);
  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MainActivityState createState() => new _MainActivityState();
}

class _MainActivityState extends State<MainActivity> {
  int tabIndex = 0;

  List<Widget> views;

  GlobalKey<Example3State> example3Key= new GlobalKey();


  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return new Scaffold(

      appBar: new AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: new Text(widget.title),
        actions: <Widget>[(tabIndex==2)?new MaterialButton(onPressed: (){
          example3Key.currentState.enterRefresh();
        },child: new Text('refresh3',style: new TextStyle(color:Colors.white),)):new Container()],
      ),
      body: new Stack(

        children: <Widget>[
          new Offstage(
            child: views[0],
            offstage: tabIndex!=0,
          ),
          new Offstage(
            child: views[1],
            offstage: tabIndex!=1,
          ),
          new Offstage(
            child: views[2],
            offstage: tabIndex!=2,
          ),
          new Offstage(
            child: views[3],
            offstage: tabIndex!=3,
          )
        ],
      ),
      bottomNavigationBar: new BottomNavigationBar(
        items: [
          new BottomNavigationBarItem(
              icon: new Icon(Icons.home,
                  color: tabIndex == 0 ? Colors.blue : Colors.grey),
              title: new Text('Example1',
                  style: new TextStyle(
                      color: tabIndex == 0 ? Colors.blue : Colors.grey))),
          new BottomNavigationBarItem(
              icon: new Icon(Icons.cloud,
                  color: tabIndex == 1 ? Colors.blue : Colors.grey),
              title: new Text('Example2',
                  style: new TextStyle(
                      color: tabIndex == 1 ? Colors.blue : Colors.grey))),
          new BottomNavigationBarItem(
              icon: new Icon(Icons.call,
                  color: tabIndex == 2 ? Colors.blue : Colors.grey),
              title: new Text('Example3',
                  style: new TextStyle(
                      color: tabIndex == 2 ? Colors.blue : Colors.grey))),
          new BottomNavigationBarItem(
              icon: new Icon(Icons.transform,
                  color: tabIndex == 3 ? Colors.blue : Colors.grey),
              title: new Text('Example4',
                  style: new TextStyle(
                      color: tabIndex == 3 ? Colors.blue : Colors.grey))),
        ],
        onTap: (index) {
          setState(() {
            tabIndex = index;
          });
        },
        currentIndex: tabIndex,
        fixedColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState

    views = [new Example1(),new Example2(),new Example3(key:example3Key),new Example4()];
    super.initState();
  }

}
