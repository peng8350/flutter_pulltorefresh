# Indicator properties

## Common header attributes (not every indicator, but most have these attributes)
* double  height: 1.4.7 updated,it mean the visual height of indicator
* refreshStyle: Styles used to define header refresh indicators,There is four style:Front,Behind,Follow(default),UnFollow
* completeDuration: stop time when state in success or fail

## common Footer attributes
* double  height: 1.4.7 updated,it mean the visual height of indicator
* () => {} onClick：click footer indicator callback
* loadStyle:Styles used to define footer load indicators,There is four style:ShowWhenLoading,ShowAlways(default),hideAlways


## ClassicHeader,ClassicFooter(Not Support Behind)
* outerBuilder: use to give child extra feature,such as background,padding
* String idleText:Text displayed when the indicator is idle
* Widget idleIcon:Icon displayed when the indicator is idle
* String  refreshingText:Text displayed when the indicator is refreshing
* Widget  refreshingIcon:Icon displayed when the indicator is refreshing
* .....the same above
* double spacing: Spacing between icons and text
* TextStyle textStyle: textStyle
* IconPosition iconPos:IconPosition(Left,Top,Right,Bottom)
* RefreshStyle refreshStyle,height,triggerDistance,autoLoad: the same Above


## WaterDropHeader
* Color waterDropColor:WaterDrop Color
* Widget idleIcon:It refers to the middle part of the water droplet in the process of user dragging.
* Widget refresh: Content displayed during refresh
* Widget complete:Content displayed during complete
* Widget failed:Content displayed during fail

## MaterialClassicHeader,WaterDropMaterialHeader
This internal implementation is implemented with something inside the flutter RefreshIndicator.many of its attributes mean the same thing, so I won't list them.
* double distance:When preparing to trigger refresh, the indicator should be placed at a distance of not more than 100.0 from the top.

