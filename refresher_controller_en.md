
# SmartRefresher

| Attribute Name     |     Attribute Explain     | Parameter Type | Default Value  | requirement |
|---------|--------------------------|:-----:|:-----:|:-----:|
| child      | your content Scroll Widget   | ? extends ScrollView   |   null |  necessary |
| controller | controll inner headerMode and footerMode  | RefreshController | null | necessary |
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