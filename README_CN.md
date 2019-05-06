# flutter_pulltorefresh

## 介绍
一个提供上拉加载和下拉刷新的组件,同时支持Android和Ios

## 特性
* 同时支持Android,IOS
* 提供上拉加载和下拉刷新
* 几乎适合所有的部件,例如GridView,ListView,Container...
* 高度扩展性和很低的限制性
* 灵活的回弹能力
* 支持反转列表
* 提供多种刷新指示器风格:跟随,不跟随,背部

## 指示器截图

|Style|跟随经典指示器|不跟随经典指示器|
|:---:|:---:|:---:|
|art|![](example/images/classical_follow.gif)|![](example/images/classical_unfollow.gif))|

|Style|背部指示器|水滴指示器(手机QQ)|
|:---:|:---:|:---:|
|art|![](arts/screen1.gif)|![](example/images/warterdrop.gif))|

## 我该怎么用?


```

   dependencies:
     pull_to_refresh: ^1.3.0

```



```

RefreshController _refreshController;

initState(){

    super.initState();
    _refreshController = RefreshController();
}

void _onRefresh(){

   /*.  after the data return,
        use _refreshController.refreshComplete() or refreshFailed() to end refreshing
   */
}

void _onLoading(){
   /*
        use _refreshController.loadComplete() or loadNoData() to end loading
   */
}

build(){
...
SmartRefresher(
      enablePullDown: true,
      enablePullUp: true,
      header: WaterDropHeader(),
      controller: _refreshController,
      onRefresh: _onRefresh,
      onLoading: _onLoading,
      child: "yourContentScrollView",
    )
....
}

// don't forget to dispose refreshController
void dispose(){
    _refreshController.dispose();
    super.dispose();
}

```

关于数据量太小的时候,内部没有提供自动判断去隐藏的功能,需要你动态判断listView高度和实际大小,listView高度可以借助LayoutBuilder,[example1](https://github.com/peng8350/flutter_pulltorefresh/blob/master/example/lib/ui/Example1.dart)是个例子.

```

       double innerListHeight= ...;
       // listView height
       double listHeight = ...;

       new SmartRefresher(
           enablePullUp: innerListHeight>listHeight
          .....
       )


```

## 自定义指示器
1.第一种方式,假设你要实现的指示器功能不是太过于复杂,可以使用CustomHeader或者CustomFooter

```
   Widget buildHeader(BuildContext context,RefreshStatus mode){
      .....
   }

   SmartRefresher(
      ...
      header: buildHeader

      ...
   )

```

2.第二种方式,通过集成RefreshInditor或者LoadIndicator来实现,详细参考 [经典指示器](lib/src/indicator/classic_indicator.dart)


## 属性表
SmartRefresher:

| Attribute Name     |     Attribute Explain     | Parameter Type | Default Value  | requirement |
|---------|--------------------------|:-----:|:-----:|:-----:|
| child      | 你的内容部件   | ? extends ScrollView   |   null |  必要
| controller | 控制内部状态  | RefreshController | null | 必要 |
| header | 头部指示器构造  | ? extends RefreshIndicator  | ClassicHeader | 可选|
| footer | 尾部指示器构造     | ? extends LoadIndicator | ClassicFooter | 可选 |
| enablePullDown | 是否允许下拉     | boolean | true | 可选 |
| enablePullUp |   是否允许上拉 | boolean | false | 可选 |
| onRefresh | 进入下拉刷新时的回调   | () => Void | null | 可选 |
| onLoading | 进入上拉加载时的回调   | () => Void | null | 可选 |
| onOffsetChange | 它将在超出边缘范围拖动时回调  | (bool,double) => Void | null | 可选 |
| enableOverScroll |  越界回弹的开关,如果你要配合RefreshIndicator(material包)使用,有可能要关闭    | bool | true | optional |
| isNestWrapped | 如果SmartRefesher被NestedScrollView包裹着,需要设置为true  | bool | false | optional |

## FAQ
* <h3>能不能实现:自动判断数据量大于一页,隐藏掉上拉加载组件?</h3>
目前来说没有什么好的办法,flutter好像没有提供Api让我们可以获得ListView里的所有item加起来的高度(界面渲染之前)。如果有人能解决这个问题,请提出,万分感谢!

* <h3>是否支持单纯RefreshIndicator(material)+上拉加载并且没有弹性的刷新组合?</h3>
可以,只要设置节点属性enableOverScroll = false, enablePullDown = false,在外面包裹一个是否支持
单纯RefreshIndicator就可以了,demo里
[example4](https://github.com/peng8350/flutter_pulltorefresh/blob/master/example/lib/ui/Example4.dart)已经给出了例子

* <h3>为什么child属性从原来widget扩大到scrollView?</h3>
因为本人疏忽的原因,没有考虑到child需要缓存里面的item的问题,所以1.1.3版本已经修正不能缓存的问题

* <h3>有办法实现限制越界回弹的最大距离吗?/h3>
答案是否定的,我知道肯定是要通过修改ScrollPhysics里面的来实现,但我对里面的Api不太明白,尝试过但失败了。如果
你有办法解决这个问题的话,请来个PR


## 开源协议
 
```
 
MIT License

Copyright (c) 2018 Jpeng

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

 
 ```
