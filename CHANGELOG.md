## 1.0.0

* initRelease

## 1.0.1

* Remove bottomColor

## 1.0.2
* Add Failed RefreshMode when catch data failed
* ReMake Default  header and footer builder
* Replace RefreshMode,loadMode to refreshing,loading
* Replace onModeChange to onRefresh,onLoadMore

## 1.0.3
* Fix error Props
* Add  interupt Scroll when failure status

## 1.0.4
* Update README and demo

## 1.0.5
* Remove headerHeight,footerHeight to get height inital
* Make footer stay at the bottom of the world forever
* replace idle to idel(my English mistake)
* Fix defaultIndictor error Icon display

## 1.0.6
* Use Material default LoadingBar
* Add a bool paramter to onOffsetChange to know if pullup or pulldown
* Fix Bug: when pulled up or pull-down, sizeAnimation and IOS elasticity conflict, resulting in beating.

## 1.0.7
* Fix Bug1: The use of ListView as a container to cause a fatal error (continuous sliding) when the bottom control is reclaimed, using the SingleChildScrollView instead of preventing the base control from recovering many times from the exception
* Fix Bug2: When the user continues to call at the same time in the two states of pull-down and drop down, the animation has no callback problem when it enters or fails.

## 1.0.8
* Reproducing bottom indicator, no more manual drag to load more
* Control property values change more,Mainly:1.onModeChange => onRefreshChange,onLoadChange, 2.Add enableAutoLoadMore,3.Remove bottomVisiableRange

## 1.1.0
Notice: This version of the code changes much, Api too
* Transfer state changes to Wrapper of indicator to reduce unnecessary interface refresh.
* No longer using Refreshmode or LoadMode,replaced int because the state is hard to determine.
* Now support the ScrollView in the reverse mode
* The indicators are divided into two categories, loadIndicator and refreshIndicator, and the two support header and footer
* provided a controller to invoke some essential operations inside.
* Move triggerDistance,completeTime such props to Config
* Add ClassicIndicator Convenient construction indicator

## 1.1.1
* Make triigerDistance be equally vaild for LoadWrapper
* Add enableOverScroll attribute

## 1.1.2
* Fix Bug:Refreshing the indicator requires multiple dragging to refresh
* Fix ClassialIndicator syntax errors and display status when no data is added.

## 1.1.3
* Fix contentList's item cannot be cached,Remove shrinkWrap,physics limit
* Fix onOffsetChange callback error,In completion, failure, refresh state is also callback
* Add unfollowIndicator implement in Demo(Example3)

## 1.1.4
* Fix enableOverScroll does not work
* Add default IndicatorBuilder when headerBuilder or footerBuilder is null
* Fix cannot loading when user loosen gesture and listview enter the rebounding

## 1.1.5
* Fix problem of offsetChange
* Fix CustomScrollView didn't work
* Fix refreshIcon not reference in ClassialIndicator

## 1.1.6
* Fix Compile error after flutter update


## 1.2.0
* Fixed the problem that ScrollController was not applied to internal controls
* Optimize RefreshController
* RefreshController changed to  required now
* Add feature:reuqestRefresh can jumpTo Bottom or Top
* Fix problem: Refresh can still be triggered when ScrollView is nested internally
* Remove rendered twice to get indicator height,replaced by using height attribute in Config
* change RefreshStatus from int to enum

## 1.3.0
### Total
* Support reverse ScrollView
* Remove RefreshConfig,LoadConfig,Move to indicator setting
* Add isNestWrapped to Compatible NestedScrollView
* replace headerBuilder,footerBuilder attribute to header,footer
* Separate header and footer operations:onRefresh and onLoading Callback,RefreshStatus is separated into RefreshStatus.LoadStatus
* Fix Bug: twice loading (the footer state change before the ui update)
*

### RefreshController
* Remove sendBack method,replaced by LoadComplete,RefreshComplete ,RefreshFailed,LoadNoData
* Separate refresh and load operations
* Add dispose method for Safety in some situation

### Indicator
* Use another way to achieve drop-down refresh
* Add drop-down refresh indicator style(Follow,UnFollow,Behind)
* Add WaterDropIndicator,CustomIndicator
* Make Custom Indicator easily

## 1.3.1
* Add onClick CallBack for LoadIndicator
* Fix enablepullUp or down invalid
* Fix error Loading after 1.3.0 updated

## 1.3.2
* Fix WaterDropHeader some attributes invalid
* Fix enablePullUp and enablePullDown Dynamic set
* implements auto hide FooterView when less than one page,no need to set enablePullUp to false
* improve safety after disposed

