
# SmartRefresher

| Attribute Name     |     Attribute Explain     | Parameter Type | Default Value  | requirement |
|---------|--------------------------|:-----:|:-----:|:-----:|
| controller | 控制内部状态  | RefreshController | null | 必要 |
| child      | 你的内容部件   | ? extends Widget   |   null |  可选 |
| header | 头部指示器构造  | ? extends Widget  | ClassicHeader | 可选|
| footer | 尾部指示器构造     | ? extends Widget | ClassicFooter | 可选 |
| enablePullDown | 是否允许下拉     | boolean | true | 可选 |
| enableTwoLevel |   是否允许打开头部指示器二楼的功能 | boolean | false | 可选 |
| enablePullUp |   是否允许上拉 | boolean | false | 可选 |
| onRefresh | 进入下拉刷新时的回调   | () => Void | null | 可选 |
| onLoading | 进入上拉加载时的回调   | () => Void | null | 可选 |
| onOffsetChange(2.0.0 removed) | 它将在超出边缘范围拖动时回调  | (bool,double) => Void | null | 可选 |
| onTwoLevel | 当准备打开二楼时的回调   | () => Void | null | 可选 |


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
      //  主动打开二楼
      void requestTwoLevel(
                {Duration duration: const Duration(milliseconds: 300),
                Curve curve: Curves.linear});

      // 顶部指示器刷新成功,是否要还原底部没有更多数据状态
      void refreshCompleted({bool resetFooterState:false});
      // 不显示任何状态,直接变成idle状态隐藏掉
      void refreshToIdle();
      // 顶部指示器刷新失败
      void refreshFailed();
      // 关闭二楼
      void twoLevelComplete(
       {Duration duration: const Duration(milliseconds: 500),
       Curve curve: Curves.linear};
      // 底部指示器加载完成
      void loadComplete();
      // 底部指示器进入一个没有更多数据的状态
      void loadNoData();
      // 底部加载失败
      void loadFailed()
      // 刷新底部指示器状态为idle
      void resetNoData();

```

# RefreshConfiguration

| Attribute Name     |     Attribute Explain     | Parameter Type | Default Value  | requirement |
|---------|--------------------------|:-----:|:-----:|:-----:|
| child | 不用解析你明白  | Widget  | null | 必要|
| springDescription | 自定义弹性动画的配置,三个属性  | SpringDescription | default | 可选 |
| dragSpeedRatio | 越界回弹时拖动的速度比例,公式:原始滑动引擎拖动速度*dragSpeedRatio  | double | 1.0 | 可选 |

刷新全局设置(header):

| Attribute Name     |     Attribute Explain     | Parameter Type | Default Value  | requirement |
|---------|--------------------------|:-----:|:-----:|:-----:|
| headerBuilder | 默认头部指示器全局构造器  | () =>  ? extends RefreshIndicator | null | 可选 |
| headerTriggerDistance | 触发下拉刷新的越界距离     | double | 80.0 | 可选 |
| maxOverScrollExtent | 最大顶部越界距离(拖动时)  | double | ios:inf,android:60 | 可选 |
| skipCanRefresh | 直接跳过canRefresh状态进入刷新   | bool | false | 可选 |
| enableScrollWhenTwoLevel | 当进入二楼时,是否允许上下滑动   | bool | false | 可选 |
| twiceTriggerDistance | 触发进入二楼的越界距离   | double | 150.0 | 可选 |
| closeTwoLevelDistance | 关闭二楼底部的底部越界距离,前提enableScrollWhenTwoLevel要为true  | double | 80.0 | 可选 |
| enableBallisticRefresh | 是否可以通过惯性来触发刷新  | bool | false | 可选 |
| enableScrollWhenRefreshCompleted |是否允许用户手势滑动当刷新完毕准备回弹回去时 | bool | true | 可选 |
| topHitBoundary | 当快速惯性滑动时,顶部位置应该要在哪个位置停下来  | double | ios:inf,android:0 | 可选 |


加载更多全局设置(footer):

| Attribute Name     |     Attribute Explain     | Parameter Type | Default Value  | requirement |
|---------|--------------------------|:-----:|:-----:|:-----:|
| footerBuilder      | 默认尾部指示器全局构造器   | () =>  ? extends LoadIndicator  |   null |  可选 |
| hideWhenNotFull | 当ScrollView不满一页时,是否要隐藏底部指示器   | bool | false | 可选 |
| autoLoad(2.0.0 removed) | 自动加载更多,假如为false,滑动底部不会触发,但提供点击加载更多的方法  | bool | true | 可选 |
| enableLoadingWhenFailed |  是否允许通过手势来触发加载更多当失败的状态  | bool | true| 可选 |
| enableLoadingWhenNodata |  是否允许通过手势来触发加载更多当没有更多数据的状态  | bool | false| 可选 |
| footerTriggerDistance |   距离底部边缘触发加载更多的距离,注意这个属性和header的不同,它可以为负数,负数代表越界 | double | 15.0 | 可选 |
| maxUnderScrollExtent | 最大底部越界距离(拖动时)   | double | ios:inf,android:0 | 可选 |
| enableBallisticLoad | 是否可以通过惯性来触发加载更多  | bool | true | 可选 |
| shouldFooterFollowWhenNotFull | 当不满一个屏幕时,对于不同状态要不要跟随内容列表,前提hideFooterWhenNotFull = false | (LoadStatus) => bool | () => false | 可选 |
| bottomHitBoundary | 当快速惯性滑动时,底部位置应该要在哪个位置停下来   | double | ios:inf,android:0 | 可选 |