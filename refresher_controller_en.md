
# SmartRefresher

| Attribute Name     |     Attribute Explain     | Parameter Type | Default Value  | requirement |
|---------|--------------------------|:-----:|:-----:|:-----:|
| controller | controll inner headerMode and footerMode  | RefreshController | null | necessary |
| child      | your content  Widget   | ? extends Wiget   |   null |  optional |
| header | refresh indicator  | ? extends RefreshIndicator  | ClassicHeader | optional|
| footer | load indicator     | ? extends LoadIndicator | ClassicFooter | optional |
| enablePullDown | switch of pulldownrefresh     | boolean | true | optional |
| enablePullUp |   switch of pullupload | boolean | false | optional |
| onRefresh | callback when refreshing  | () => Void | null | optional |
| onLoading | callback when loading   | () => Void | null | optional |
| onOffsetChange | callBack the Visible range of indicator  | (bool,double) => Void | null | optional |
| isNestWrapped | set true to compatible NestedScrollView | bool | false | optional |


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
      void refreshCompleted();
      // Top Indicator Refresh Failed
      void refreshFailed();
      // Bottom Indicator Loading Completed
      void loadComplete();
      // The bottom indicator enters a state without more data
      void loadNoData();
      // Refresh the bottom indicator status to idle
      void resetNoData();
      // Internal exposure of ScrollController is required for a very special situation, such as NestedScrollView, which can be used to obtain innerScrollController.
      ScrollController scrollController;

```

# RefreshConfiguration
* headerBuilder: Header construction indicator, to return RefreshIndicator type, under the subtree SmartRefresher refers to it by default without header attr
* footerBuilder: The tail constructed indicator returns the LoadIndicator type, which SmartRefresher under the subtree refers to by default without footer
* double headerTriggerDistance: trigger refresh distance
* double footerTriggerDistance: trigger loading distance
* skipCanRefresh: Skip the canRefresh state and go directly to refresh state
* bool hideWhenNotFull:Whether to automatically hide the bottom indicator when the page is less than one page, default to true
* () => {} onClick：Click on the callback method of the indicator to manually load data or reset the status of no data
* autoLoad:Whether to turn on the function of automatic loading at a certain distance