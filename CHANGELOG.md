## 2.0.0
### Breaking Changes:
* Remove onOffsetChange in SmartRefresher,autoLoad in RefreshConfiguration,scrollController in RefreshController
* add argument to onTwoLevel(callback when closed)

### features
* migrate null-safety
* add needCallback in requestRefresh and requestLoading for avflutoiding the callback of onRefresh or onLoading

### Bug fix
* In NestedScrollView+ClampingScrollPhysics(Android ScrollBehaviour),header can be seen when fling to top.
* unMounted widget used crash error when fast rebuild in requestRefresh
* fix sliverRefreshBody layoutSize instead of -0.001,it will crash error when viewportMainAxis=0

### Other
* Add assert to avoid invalid usage



## 1.6.5
* fix check full page logic.
* fix crash "locking up a deactive widget is unsafe".

## 1.6.4
* fix error crash by deprecated function removed 
* add extra ScrollView reference parameter


## 1.6.3
* fix bug:gesture disabled after refresh complete in an error refreshState
* fix problem:Footer hide back suddenly(this cause by the flutter breaking change)
* add vibrate option to enable vibrate when trigger onRefresh or onLoading
* fix SmartRefresher key in mutiple widgets
* add other languages

## 1.6.2
* fix "_pendingDimenssion is not true" error with the breaking change

## 1.6.1
* fix NestedScrollView requetRefresh error
* fix NestedScollView cast error
* fix twiceloadng when no data return
* add support for update refreshcontroller
* add other language

## 1.6.0
* fix slow bounce back when load more too fast
* fix footer renderError with reverse:true,behaviour return to 1.5.7
* add check null in requestRefresh()
* fix refreshText reverse error(ClassicHeader) when reverse:true

## 1.5.8
* fix breaking change crash error after flutter 1.13.6 upgrade
* add other language
* fix material header frequently setState slow down the performance
* fix bug:loadFinish throw error when dispose widget(short time to trigger)
* fix WaterDropMaterialHeader "color" invalid

## 1.5.7
* add three national language: French,Russian,...
* fix endLoading logic error in callback
* add enableLoadMoreWhenNoMoreData,enable switch to decide whether auto load more when footer state is noMore
* fix requestRefresh callback onRefresh immediately

## 1.5.6
* add new feature:refresh localizations
* The footer layout size should be added to calculate whether the Viewport is full of a screen
* fix physics check error when theme use other platform
* add topHitBoundary,bottomHitBoundary in RefreshConfiguration
* move headerOffset from RefreshConfiguration,move to indicator setting
* In Android systems,default change: fast fling will be stopped in 0 pixels
* Optimized part indicator,auto attach primaryColor from Theme,text style adjust etc..
* Optimize requestRefresh() and requestLoading(),avoid spring back when far from target point,add one parameter controll whether to move down or top

## 1.5.5

### breaking change
* add new canLoading state for footer
* add canLoadingText,canLoadingIcon,completeDuration in footer
* enableLoadingWhenFailed default value change to true
* shouldFollowContentWhenNotFull: in noMore state default return true

### twoLevel
* add TwoLevelHeader,reduce the difficulty of using the second floor function


### Bug fix
* twoLevel bug: fix viewportDimenssion use error,which lead to height dynamic error
* fix underScroll bug when footer is noMore state or hideWhenNotFull=true and viewport not full one screen in Android
* NeverScrollPhysics is ignored,when passing NeverScrollPhysics,it should disable scroll

### other
* add enableBallisticLoad(same with enableBallisticRefresh) in RefreshConfiguration
* add requestTwoLevel method in RefreshController
* add endLoading,readyToLoad for CustomFooter
* add ScrollView's props to SmartRefresher,mostly for SingleChildView not ScrollView

## 1.5.4
* add new RefreshConfiguration constructor "copyAncestor"
* fix bug 1: when !enablePullDown && !enablePullUp crash error
* fix bug 2: "pixels" call on null when refresh completed and ready to springback In a very short time and disposed
* enable "primary" attr working,Avoiding clicking on the status bar to cause scrolling to the top in some stiuation
* requestRefresh() and requestLoading() change to return a future

## 1.5.3
* add new indicator: BezierCircleHeader
* change spring default value ,make it fast and smooth
* fix cast ScrollPosition error with NestedScrollView

## 1.5.2
* change maxOverScrollExtent default to 60
* maxScrollExtent should subtract layoutExtent instead of boxExtent when indicator not floating
* add SmartRefresher builder constructor for some special use stage
* when child is not extends scrollView,it should convert height to viewport's height when child's height is infite,such as PageView,emptyWidget with Center,else it will use LayoutBuilder get height
* header,footer now unlimit the type ,convert to widget,but only sliver widget,Considering the problem of combined indicators
* CustomHeader,CustomFooter expose inner indicator event
* resetNoData should only can work when footer indicator is noMore state
* fix twolevel and refresh prior problem

## 1.5.1
* add api docs in code
* add test to prevent previous bugs as much as possible
* enableScrollWhenCompleted default value change to false,when header spring back,doesn't allow to scroll by gesture
* improve enableScrollWhenCompleted safety ,fix trigger disable scroll times error
* maxScrollExtent should subtract boxExtent when floating(indicator layoutExtent != 0) or not
* maxOverScrollExtent default change to 30.0 in Android,maxUnderScrollExtent default change to 0.0 in Android
* Fix footer onClick not working when click near footer edge
* fix canTwoLevel text showing in other twoLevel state
* when enablePullDown= false && enableTwoLevel = true,it should add header into Viewport
* remove reverse in some header indicators,inner auto check direction,no need to pass paramter
* fix render error in footer when asix = Horizontal & reverse = true

## 1.5.0
* Fix a Big Bug in FrontStyle:When overScroll(pixels <0.0),it shouldn't be disabled gesture
* add shouldFollowContentWhenNotFull 
* add support to scrollable widget
* Fix ignore reverse load more paintOrigin issue 
* change hideFooterWhenNotfull default value to false
* update header default releaseIcon and footer idle default Icon

## 1.4.9
* Fix MaterialClassicHeader,WaterDropHeader some err
* Optimze WaterdropMaterial
* remove hit top in clamping physics
* add springDescrition,dragSpeedRatio in RefreshConfiguration
* fix BehindStyle layoutExtent error

## 1.4.8
* provide three load more style:ShowAlways,HideAlways,ShowWhenLoading
* add linkFooter
* Fix Bug: requestRefresh() interupted when physics =Clamping && offset !=0
* Fix Bug: When viewport not enough onepage ,pull up will change the state to loading,but not callback onLoading
* revert change before:SmartRefresher change Stateless,Fix position may be null in some stiuations
* add enableScrollWhenRefreshCompleted,enableBallisticRefresh,enableLoadingWhenFailed bool in RefreshConfiguration
* enable footerTriggerdistance pass Negative

## 1.4.7
new Feature:
* Add twoLevel refresh feature
* Add linkHeader to link other place header

SmartRefresher:
* Remove headerInsertIndex(only first sliver)
* Fix ignore padding attr when child is BoxScrollView
* add enableTwoLevel,onTwoLevel attr

RefreshConfiguration:
* add enableScrollWhenTwoLevel,closeTwoLevelDistance for twoLevel setting

RefreshController:
* Add refreshToidle, twoLevelComplete new api
* Add initalRefreshStatus,initalLoadStatus new parameter setting default value

ClassicalIndicator:
* remove decoration
* add outerBuilder replace decoration
* add other attr for twoLevel

Bug Fix:
* Fix clicking footer trigger loading when no more state
* footer indicator shouldn't hide when state in noMore,failed and not full in one page

other:
* Remove asSliver usage in all indicators(no need to use,only support first sliver)
* make indicator auto fit boxSize,just like SliverToBoxAdapter

## 1.4.6
* Add horizontal refresh support
* Fix 1.4.5  default physics Bug  in Android simulation
* Fix Problem: when enablePullDown or enablePullUp = false,it still can overScroll or underScroll when use ClampingScrollPhysics
* Add maxOverScrollExtent and maxUnderScrollExtent in RefreshConfiguration

## 1.4.5
* Remake FrontStyle implements principle,Make it close to the first three styles,Fix some small problems also:
1.when tap StatusBar,it will trigger refresh instead of scroll to top
2.It seems odd to set aside 100 heights in front of scrollOffset for FrontStyle
3.When hideWhenNotFull = false, dragging to pull down will cause loading together

* Remake RefreshPhysics,Simpify code,child support physics setting now.
* ClassicIndicator default refreshingIcon:in iOS use ActivityIndicator,in Android use CircularProgressIndicator

## 1.4.4
* Fix Bug:Multiples ScrollPositions shared one ScrollController,when calling controller.requestRefresh cause refresh together( such as keepAlive Widget )
* When the user Dragging ScrollView(pull up), disable make it change to loading state
* Add one new LoadStatus:failed(provide click to retry loading)
* Fix some defaultIcon:noMoreIcon default Invisible

## 1.4.3
* change "child" attr limit type from ScrollView to Widget

## 1.4.2
* Improving hideWhenNotFull judgment mechanism
* Fix triggerDistance error after 1.4.0-1.4.1

## 1.4.1
* Remove isNestedWrapped(deprecated from 1.3.8)
* Add headerInsertIndex attr in SmartRefresher
* Rename IndicatorConfiguration to RefreshConfiguration
* Move some attr from Indicator to RefreshConfiguration:offset,skipCanRefresh,triggerDistance,autoLoad,hideWhenNotFull
* Add decoration for classicIndicator(both header and footer)
* Add Fade effect for WaterDropHeader when dismiss
* Simplify reverse operation,Add MaterialClassicHeader,WaterDropMaterialHeader reverse feature

## 1.4.0
* Fix one serious Bug after 1.3.8 upgrade to 1.3.9:enablePullDown = false throw error

## 1.3.9
* Avoid inner inject padding by buildSlivers in child(ListView,GridView)
* Add initialRefresh in RefreshController(when you need to requestRefresh in initState)
* Fix exception RefreshBouncingPhysics velocity value
* Add IndicatorConfiguration for build indicator for subtrees SmartRefresher
* Add SkipCanRefresh,CompleteDuration attr in header
* Fix trigger more times loading when no data come in and too fast loadComplete
* remove center,anchor in CustomScrollView to Compatible with old versions

## 1.3.8
* Temporary fix deadly bug: PrimaryScrollController cannot shared by multiple Indicators

## 1.3.7
* Adding an asSlivers constructor can be inserted into slivers as a Sliver
* Fix FrontStyle cannot support dynamic change enablePullDown
* Fix FrontStyle cannot enter refresh state when init
* Optimize indicator internal code to avoid locking widgets
* Fix iOS click status cannot roll back without ScrollController in child
* Fix one ignored situation after finish refresh -> completed(not in visual range)

## 1.3.6
* Fix NestedScrollView issue in 1.3.5
* decrease default triggerDistance from 100.0 to 80.0
* improve dragging scrolling speed of Front Style
* Add offset attr in Front Style

## 1.3.5
* Add hideWhenNotFull bool to disable auto hide footer when  data not enough one page
* Add one new RefreshStyle:Front(just like RefreshIndicator)
* Fix a bug: When the head overflows the view area, there is no clipping operation
* Add material header(two indicator for FrontStyle)
* Remove enableOverScroll

## 1.3.3
* Fixed the request Refresh problem: Sometimes it takes two times to be effective
* Add child key support
* Fix Bug:Pull-down triggers need to be pulled down more distances to trigger
* Add resetNoData to resume footer state to idle

## 1.3.2
* Fix WaterDropHeader some attributes invalid
* Fix enablePullUp and enablePullDown Dynamic set
* implements auto hide FooterView when less than one page,no need to set enablePullUp to false
* improve safety after disposed

## 1.3.1
* Add onClick CallBack for LoadIndicator
* Fix enablepullUp or down invalid
* Fix error Loading after 1.3.0 updated

## 1.3.0
### Total
* Support reverse ScrollView
* Remove RefreshConfig,LoadConfig,Move to indicator setting
* Add isNestWrapped to Compatible NestedScrollView
* replace headerBuilder,footerBuilder attribute to header,footer
* Separate header and footer operations:onRefresh and onLoading Callback,RefreshStatus is separated into RefreshStatus.LoadStatus
* Fix Bug: twice loading (the footer state change before the ui update)

### RefreshController
* Remove sendBack method,replaced by LoadComplete,RefreshComplete ,RefreshFailed,LoadNoData
* Separate refresh and load operations
* Add dispose method for Safety in some situation

### Indicator
* Use another way to achieve drop-down refresh
* Add drop-down refresh indicator style(Follow,UnFollow,Behind)
* Add WaterDropIndicator,CustomIndicator
* Make Custom Indicator easily

## 1.2.0
* Fixed the problem that ScrollController was not applied to internal controls
* Optimize RefreshController
* RefreshController changed to  required now
* Add feature:reuqestRefresh can jumpTo Bottom or Top
* Fix problem: Refresh can still be triggered when ScrollView is nested internally
* Remove rendered twice to get indicator height,replaced by using height attribute in Config
* change RefreshStatus from int to enum

## 1.1.6
* Fix Compile error after flutter update

## 1.1.5
* Fix problem of offsetChange
* Fix CustomScrollView didn't work
* Fix refreshIcon not reference in ClassialIndicator

## 1.1.4
* Fix enableOverScroll does not work
* Add default IndicatorBuilder when headerBuilder or footerBuilder is null
* Fix cannot loading when user loosen gesture and listview enter the rebounding

## 1.1.3
* Fix contentList's item cannot be cached,Remove shrinkWrap,physics limit
* Fix onOffsetChange callback error,In completion, failure, refresh state is also callback
* Add unfollowIndicator implement in Demo(Example3)

## 1.1.2
* Fix Bug:Refreshing the indicator requires multiple dragging to refresh
* Fix ClassialIndicator syntax errors and display status when no data is added.

## 1.1.1
* Make triigerDistance be equally vaild for LoadWrapper
* Add enableOverScroll attribute

## 1.1.0
Notice: This version of the code changes much, Api too
* Transfer state changes to Wrapper of indicator to reduce unnecessary interface refresh.
* No longer using Refreshmode or LoadMode,replaced int because the state is hard to determine.
* Now support the ScrollView in the reverse mode
* The indicators are divided into two categories, loadIndicator and refreshIndicator, and the two support header and footer
* provided a controller to invoke some essential operations inside.
* Move triggerDistance,completeTime such props to Config
* Add ClassicIndicator Convenient construction indicator

## 1.0.8
* Reproducing bottom indicator, no more manual drag to load more
* Control property values change more,Mainly:1.onModeChange => onRefreshChange,onLoadChange, 2.Add enableAutoLoadMore,3.Remove bottomVisiableRange

## 1.0.7
* Fix Bug1: The use of ListView as a container to cause a fatal error (continuous sliding) when the bottom control is reclaimed, using the SingleChildScrollView instead of preventing the base control from recovering many times from the exception
* Fix Bug2: When the user continues to call at the same time in the two states of pull-down and drop down, the animation has no callback problem when it enters or fails.

## 1.0.6
* Use Material default LoadingBar
* Add a bool paramter to onOffsetChange to know if pullup or pulldown
* Fix Bug: when pulled up or pull-down, sizeAnimation and IOS elasticity conflict, resulting in beating.

## 1.0.5
* Remove headerHeight,footerHeight to get height inital
* Make footer stay at the bottom of the world forever
* replace idle to idel(my English mistake)
* Fix defaultIndictor error Icon display

## 1.0.4
* Update README and demo

## 1.0.3
* Fix error Props
* Add  interupt Scroll when failure status

## 1.0.2
* Add Failed RefreshMode when catch data failed
* ReMake Default  header and footer builder
* Replace RefreshMode,loadMode to refreshing,loading
* Replace onModeChange to onRefresh,onLoadMore

## 1.0.1
* Remove bottomColor

## 1.0.0
* initRelease
