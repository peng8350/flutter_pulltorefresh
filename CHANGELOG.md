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

## 1.3.3
* Fixed the request Refresh problem: Sometimes it takes two times to be effective
* Add child key support
* Fix Bug:Pull-down triggers need to be pulled down more distances to trigger
* Add resetNoData to resume footer state to idle

## 1.3.5
* Add hideWhenNotFull bool to disable auto hide footer when  data not enough one page
* Add one new RefreshStyle:Front(just like RefreshIndicator)
* Fix a bug: When the head overflows the view area, there is no clipping operation
* Add material header(two indicator for FrontStyle)
* Remove enableOverScroll

## 1.3.6
* Fix NestedScrollView issue in 1.3.5
* decrease default triggerDistance from 100.0 to 80.0
* improve dragging scrolling speed of Front Style
* Add offset attr in Front Style

## 1.3.7
* Adding an asSlivers constructor can be inserted into slivers as a Sliver
* Fix FrontStyle cannot support dynamic change enablePullDown
* Fix FrontStyle cannot enter refresh state when init
* Optimize indicator internal code to avoid locking widgets
* Fix iOS click status cannot roll back without ScrollController in child
* Fix one ignored situation after finish refresh -> completed(not in visual range)

## 1.3.8
* Temporary fix deadly bug: PrimaryScrollController cannot shared by multiple Indicators

## 1.3.9
* Avoid inner inject padding by buildSlivers in child(ListView,GridView)
* Add initialRefresh in RefreshController(when you need to requestRefresh in initState)
* Fix exception RefreshBouncingPhysics velocity value
* Add IndicatorConfiguration for build indicator for subtrees SmartRefresher
* Add SkipCanRefresh,CompleteDuration attr in header
* Fix trigger more times loading when no data come in and too fast loadComplete
* remove center,anchor in CustomScrollView to Compatible with old versions

## 1.4.0
* Fix one serious Bug after 1.3.8 upgrade to 1.3.9:enablePullDown = false throw error

## 1.4.1
* Remove isNestedWrapped(deprecated from 1.3.8)
* Add headerInsertIndex attr in SmartRefresher
* Rename IndicatorConfiguration to RefreshConfiguration
* Move some attr from Indicator to RefreshConfiguration:offset,skipCanRefresh,triggerDistance,autoLoad,hideWhenNotFull
* Add decoration for classicIndicator(both header and footer)
* Add Fade effect for WaterDropHeader when dismiss
* Simplify reverse operation,Add MaterialClassicHeader,WaterDropMaterialHeader reverse feature

## 1.4.2
* Improving hideWhenNotFull judgment mechanism
* Fix triggerDistance error after 1.4.0-1.4.1

## 1.4.3
* change "child" attr limit type from ScrollView to Widget