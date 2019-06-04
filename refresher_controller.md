
# SmartRefresher

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
| isNestWrapped | 如果SmartRefesher被NestedScrollView包裹着,需要设置为true  | bool | false | optional |


# RefreshController Api

```
      //  请求顶部指示器刷新,触发onRefresh
      void requestRefresh(
          {Duration duration: const Duration(milliseconds: 300),
          Curve curve: Curves.linear});
     // 请求底部指示器加载数据,触发onLoading
      void requestLoading(
          {Duration duration: const Duration(milliseconds: 300),
          Curve curve: Curves.linear}) ;
      // 顶部指示器刷新成功
      void refreshCompleted();
      // 顶部指示器刷新失败
      void refreshFailed();
      // 底部指示器加载完成
      void loadComplete();
      // 底部指示器进入一个没有更多数据的状态
      void loadNoData();
      // 刷新底部指示器状态为idle
      void resetNoData();
      // 内部暴露ScrollController,是为了某一种很特殊的情况需要去获取它,比如NestedScrollView,要获取innerScrollController,可以使用到它
      ScrollController scrollController;

```

# RefreshConfiguration
* headerBuilder: 头部构造的指示器,要返回RefreshIndicator类型,子树下的SmartRefresher没有header情况下默认引用它
* footerBuilder: 尾部构造的指示器,要返回LoadIndicator类型,子树下的SmartRefresher没有footer情况下默认引用它
* double headerTriggerDistance: 头部触发刷新的越界距离
* double footerTriggerDistance: 尾部触发刷新的越界距离
* skipCanRefresh: 跳过canRefresh状态直接进入刷新状态
* bool hideWhenNotFull:当页面不满一页时，是否要自动隐藏掉底部指示器,默认为true
* bool autoLoad: 是否开启到达一定距离自动加载的功能