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
