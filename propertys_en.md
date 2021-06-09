
# SmartRefresher

| Attribute Name     |     Attribute Explain     | Parameter Type | Default Value  | requirement |
|---------|--------------------------|:-----:|:-----:|:-----:|
| controller | controll inner headerMode and footerMode  | RefreshController | null | necessary |
| child      | your content  Widget   | ? extends Wiget   |   null |  optional |
| header | refresh indicator  | ? extends Widget  | ClassicHeader | optional|
| footer | load indicator     | ? extends Widget | ClassicFooter | optional |
| enablePullDown | switch of pulldownrefresh     | boolean | true | optional |
| enableTwoLevel |   whether to open the function of twoLevel for header | boolean | false | 可选 |
| enablePullUp |   switch of pullupload | boolean | false | optional |
| onRefresh | callback when refreshing  | () => Void | null | optional |
| onLoading | callback when loading   | () => Void | null | optional |
| onOffsetChange(2.0.0 removed) | callBack the Visible range of indicator  | (bool,double) => Void | null | optional |
| onTwoLevel | callback when second floor is opening   | () => Void | null | 可选 |


# RefreshController Api

```
      //  Request top indicator refresh to trigger onRefresh
      void requestRefresh(
          {Duration duration: const Duration(milliseconds: 300),
          Curve curve: Curves.linear});
     // Request bottom indicator to load data and trigger onLoading
      void requestLoading(
          {Duration duration: const Duration(milliseconds: 300),
          Curve curve: Curves.linear}) ;
      // Top Indicator Refresh Success
      void refreshCompleted({});
      // Top Indicator Refresh Failed
      void refreshFailed();
      // Bottom Indicator Loading Completed
      // set to idle, and hide back
      void refreshToIdle();
       // close second floor
       void twoLevelComplete(
             {Duration duration: const Duration(milliseconds: 500),
             Curve curve: Curves.linear};
      void loadComplete();
      // The bottom indicator enters a state without more data
      void loadNoData();
      // Refresh the bottom indicator status to idle
      // footer load failed
      void loadFailed()
      void resetNoData();

```

# RefreshConfiguration

| Attribute Name     |     Attribute Explain     | Parameter Type | Default Value  | requirement |
|---------|--------------------------|:-----:|:-----:|:-----:|
| child | you know,no need to explain  | Widget | null | 必要|
| springDescription | custom spring animate config  | SpringDescription | default | 可选 |
| dragSpeedRatio | the speed ratio when dragging overscroll ,compute=origin physics dragging speed *dragSpeedRatio  | double | 1.0 | 可选 |

Refresh(header):

| Attribute Name     |     Attribute Explain     | Parameter Type | Default Value  | requirement |
|---------|--------------------------|:-----:|:-----:|:-----:|
| headerBuilder | the header indicator builder  | () =>  ? extends RefreshIndicator | null | 可选 |
| headerTriggerDistance | overScroll distance of  trigger refresh     | double | 80.0 | 可选 |
| maxOverScrollExtent | max overScroll distance   | double | ios:inf,android:60 | 可选 |
| skipCanRefresh | if skip canRefresh state,enter refreshing state directly  | bool | false | 可选 |
| enableScrollWhenTwoLevel | whether enable scroll when into twoLevel   | bool | false | 可选 |
| twiceTriggerDistance | the overScroll distance of trigger twoLevel  | double | 150.0 | 可选 |
| closeTwoLevelDistance | Close the bottom crossing distance on the second floor, premise:enableScrollWhenTwoLevel is true  | double | 80.0 | 可选 |
| enableBallisticRefresh | whether trigger refresh by BallisticScrollActivity(it mean use is not dragging on the screen)  | bool | false | 可选 |
| enableScrollWhenRefreshCompleted | Whether the user is allowed to slide scrollable when the refresh is complete and ready to bounce back  | bool | true | 可选 |
| topHitBoundary | When fast fling to top, setting a top boundary make the bouncing stop     | double | ios:inf,android:0 | 可选 |


Load more(footer):

| Attribute Name     |     Attribute Explain     | Parameter Type | Default Value  | requirement |
|---------|--------------------------|:-----:|:-----:|:-----:|
| footerBuilder      | the footer indicator builder   | () =>  ? extends LoadIndicator  |   null |  可选 |
| hideWhenNotFull | whether to hide footer when scrollview not enough one page   | bool | true | 可选 |
| autoLoad(2.0.0 removed) | Autoload more, if false, sliding bottom will not trigger, but provide more click loading methods  | bool | true | 可选 |
| enableLoadingWhenFailed |  whether allowed to use gesture pull-up trigger to load more when failed state  | bool | true| 可选 |
| enableLoadingWhenNoData |  whether allowed to use gesture pull-up trigger to load more when no more data state  | bool | false| 可选 |
| maxUnderScrollExtent | max underScroll distance  | double | ios:inf,android:0 | 可选 |
| footerTriggerDistance |   the extentAfter distance of  trigger loading  | double | 15.0 | 可选 |

| enableBallisticRefresh | whether trigger loading by BallisticScrollActivity(it mean use is not dragging on the screen)  | bool | true | 可选 |
| shouldFooterFollowWhenNotFull | When not full one page,If it should follow content for different status,premise: hideFooterWhenNotFull = false | (LoadStatus) => bool | () => false | 可选 |
| bottomHitBoundary | When fast fling to bottom, setting a bottom boundary make the bouncing stop     | double | ios:inf,android:0 | 可选 |