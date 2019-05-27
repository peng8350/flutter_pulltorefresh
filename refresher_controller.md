
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

# IndicatorConfiguration(1.3.9新增)
增加这个功能,主要是考虑到一个App都是同样的顶部和底部指示器,或者多个页面之间拥有同样的指示器。所以使用IndicatorConfiguration,可以减少重复的工作。
在这个组件的子树下的SmartRefresher都会去引用IndicatorConfiguration里的指示器,假如SmartRefresher内部拥有header或者footer,则不会使用IndicatorConfiguration
里的指示器,而是使用自身的header和footer