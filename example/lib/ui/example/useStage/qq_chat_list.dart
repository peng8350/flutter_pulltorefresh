/*
 * Author: Jpeng
 * Email: peng8350@gmail.com
 * Time:  2019-07-11 17:55
 */
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../../other/expanded_viewport.dart';

class QQChatList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _QQChatListState();
  }
}

const String myUrl = "https://avatars1.githubusercontent.com/u/19425362?s=400&u=1a30f9fdf71cc9a51e20729b2fa1410c710d0f2f&v=4";
class _QQChatListState extends State<QQChatList> {
  RefreshController _refreshController = RefreshController();
  TextEditingController _textController = TextEditingController();
  List<_MessageItem> data = [_MessageItem(
    content: "你好...................asdasdasdasdasdasdasdasdasda",
    isMe: true,
    author: "我",
    url:myUrl,),
    _MessageItem(
      content: "你好...........asdasdasdaasdasdasdasdasdasdasdasdasdsadasdasdasdasdasdasdasdcasdcascdascdascdascdasa",
      isMe: true,
      author: "我",
      url: "https://avatars1.githubusercontent.com/u/19425362?s=400&u=1a30f9fdf71cc9a51e20729b2fa1410c710d0f2f&v=4",)
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return CupertinoApp(
      home: RefreshConfiguration(
        child: CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            middle: Text("XXXXX"),
            leading: GestureDetector(
              child: Icon(
                Icons.arrow_back_ios,
                color: Colors.grey,
                size: 20,
              ),
              onTap: () {
                Navigator.of(context).pop();
              },
            ),
            trailing: Icon(
              Icons.group,
              color: Colors.grey,
              size: 24,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: <Widget>[
                Expanded(
                  child: SmartRefresher(
                    enablePullDown: false,
                    onLoading: () async {
                      await Future.delayed(Duration(milliseconds: 1000));
//                      data.add("aa");
                      setState(() {});
                      _refreshController.loadComplete();
                    },
                    footer: CustomFooter(
                      loadStyle: LoadStyle.HideAlways,
                      builder: (context, mode) {
                        if(mode==LoadStatus.loading) {
                          return Container(
                            height: 60.0,
                            child: Container(
                              height: 20.0,
                              width: 20.0,
                              child: CupertinoActivityIndicator(),
                            ),
                          );
                        }
                        else return Container();
                      },
                    ),
                    enablePullUp: true,
                    child: Scrollable(
                      axisDirection: AxisDirection.up,
                      viewportBuilder: (context, offset) {
                        return ExpandedViewport(
                          offset: offset,
                          axisDirection: AxisDirection.up,
                          slivers: <Widget>[
                            SliverExpanded(),
                            SliverList(
                              delegate: SliverChildBuilderDelegate(
                                      (c, i) => data[i],
                                  childCount: data.length),
                            )
                          ],
                        );
                      },
                    ),
                    controller: _refreshController,
                  ),
                ),
                Container(
                  color: Colors.white,
                  height: 56.0,
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          child: CupertinoTextField(
                            controller: _textController,
                            placeholder: "输入你想发送的信息",
                            onSubmitted: (s) {
                              data.insert(0,_MessageItem(content: s,author: "我",url: myUrl,isMe: true,));
                              setState(() {

                              });
                              _textController.clear();
                            },
                          ),
                          margin: EdgeInsets.all(10.0),
                        ),
                      ),
                      RaisedButton(
                        child: Text("发送"),
                        color: Colors.blueAccent,
                        onPressed: () {
                          data.insert(0,_MessageItem(content: _textController.text,author: "我",url: myUrl,isMe: true,));
                          setState(() {

                          });
                          _textController.clear();
                        },
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
        hideFooterWhenNotFull: true,
      ),
    );
  }
}

class _MessageItem extends StatelessWidget {
  final String content;
  final String author;
  final bool isMe;
  final String url;

  _MessageItem({this.content, this.author, this.isMe, this.url});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      margin: EdgeInsets.only(top: 10.0),
      child: Wrap(
        textDirection: isMe ? TextDirection.rtl : TextDirection.ltr,
        children: <Widget>[
          CircleAvatar(
            backgroundImage: NetworkImage(url),
            radius: 20.0,
          ),
          Container(width: 15.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                height: 25.0,
                width: 222.0,
                alignment: isMe ? Alignment.topRight : Alignment.topLeft,
                child: Text(
                  author,

                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ),
              Container(
                constraints: BoxConstraints(
                  minWidth: 100.0,
                  minHeight: 100.0,
                  maxWidth: 222.0,
                ),
                alignment: isMe ? Alignment.topRight : Alignment.topLeft,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  content,
                  style: TextStyle(color: Colors.black),
                ),
                padding: EdgeInsets.all(10.0),
              )
            ],
          )
        ],
      ),
    );
  }
}
