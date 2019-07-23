/*
 * Author: Jpeng
 * Email: peng8350@gmail.com
 * Time: 2019/5/2 下午5:09
 */

import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'dart:math' as Math;
import 'package:flutter/rendering.dart';
import '../smart_refresher.dart';

class SliverRefresh extends SingleChildRenderObjectWidget {
  const SliverRefresh({
    Key key,
    this.paintOffsetY,
    this.refreshIndicatorLayoutExtent = 0.0,
    this.floating = false,
    Widget child,
    this.refreshStyle,
  })  : assert(refreshIndicatorLayoutExtent != null),
        assert(refreshIndicatorLayoutExtent >= 0.0),
        assert(floating != null),
        super(key: key, child: child);

  // The amount of space the indicator should occupy in the sliver in a
  // resting state when in the refreshing mode.
  final double refreshIndicatorLayoutExtent;

  // _RenderCupertinoSliverRefresh will paint the child in the available
  // space either way but this instructs the _RenderCupertinoSliverRefresh
  // on whether to also occupy any layoutExtent space or not.
  final bool floating;
  final RefreshStyle refreshStyle;
  final double paintOffsetY;

  @override
  _RenderSliverRefresh createRenderObject(BuildContext context) {
    return _RenderSliverRefresh(
      refreshIndicatorExtent: refreshIndicatorLayoutExtent,
      hasLayoutExtent: floating,
      paintOffsetY: paintOffsetY,
      refreshStyle: refreshStyle,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant _RenderSliverRefresh renderObject) {
    final RefreshStatus mode =
        SmartRefresher.of(context).controller.headerMode.value;
    renderObject
      ..refreshIndicatorLayoutExtent = refreshIndicatorLayoutExtent
      ..hasLayoutExtent = floating
      ..context = context
      ..refreshStyle = refreshStyle
      ..updateFlag = mode == RefreshStatus.twoLevelOpening ||
          mode == RefreshStatus.twoLeveling ||
          mode == RefreshStatus.idle
      ..paintOffsetY = paintOffsetY;
  }
}

class _RenderSliverRefresh extends RenderSliverSingleBoxAdapter {
  _RenderSliverRefresh(
      {@required double refreshIndicatorExtent,
      @required bool hasLayoutExtent,
      RenderBox child,
      this.paintOffsetY,
      this.refreshStyle})
      : assert(refreshIndicatorExtent != null),
        assert(refreshIndicatorExtent >= 0.0),
        assert(hasLayoutExtent != null),
        _refreshIndicatorExtent = refreshIndicatorExtent,
        _hasLayoutExtent = hasLayoutExtent {
    this.child = child;
  }

  RefreshStyle refreshStyle;
  BuildContext context;

  // The amount of layout space the indicator should occupy in the sliver in a
  // resting state when in the refreshing mode.
  double get refreshIndicatorLayoutExtent => _refreshIndicatorExtent;
  double _refreshIndicatorExtent;
  double paintOffsetY;
  // need to trigger shouldAceppty user offset ,else it will not limit scroll when enter twolevel or exit
  // also it will crash if you call applyNewDimession when the state change
  // I don't know why flutter limit it, no choice
  bool _updateFlag = false;

  set refreshIndicatorLayoutExtent(double value) {
    assert(value != null);
    assert(value >= 0.0);
    if (value == _refreshIndicatorExtent) return;
    _refreshIndicatorExtent = value;
    markNeedsLayout();
  }

  // The child box will be laid out and painted in the available space either
  // way but this determines whether to also occupy any
  // [SliverGeometry.layoutExtent] space or not.
  bool get hasLayoutExtent => _hasLayoutExtent;
  bool _hasLayoutExtent;

  set hasLayoutExtent(bool value) {
    assert(value != null);
    if (value == _hasLayoutExtent) return;
    _hasLayoutExtent = value;
    markNeedsLayout();
  }

  // This keeps track of the previously applied scroll offsets to the scrollable
  // so that when [refreshIndicatorLayoutExtent] or [hasLayoutExtent] changes,
  // the appropriate delta can be applied to keep everything in the same place
  // visually.
  double layoutExtentOffsetCompensation = 0.0;

  @override
  void performResize() {
    // TODO: implement performResize
    super.performResize();
  }

  @override
  // TODO: implement centerOffsetAdjustment
  double get centerOffsetAdjustment {
    if (refreshStyle == RefreshStyle.Front) {
      final RenderViewportBase renderViewport = parent;
      return Math.max(0.0, -renderViewport.offset.pixels);
    }
    return 0.0;
  }

  @override
  void layout(Constraints constraints, {bool parentUsesSize = false}) {
    // TODO: implement layout
    if (refreshStyle == RefreshStyle.Front) {
      final RenderViewportBase renderViewport = parent;
      super.layout(
          (constraints as SliverConstraints)
              .copyWith(overlap: Math.min(0.0, renderViewport.offset.pixels)),
          parentUsesSize: true);
    } else {
      super.layout(constraints, parentUsesSize: parentUsesSize);
    }
  }

  set updateFlag(u) {
    _updateFlag = u;
    markNeedsLayout();
  }

  @override
  void performLayout() {
    if (_updateFlag) {
      // ignore: INVALID_USE_OF_PROTECTED_MEMBER
      Scrollable.of(context).position.applyNewDimensions();
      _updateFlag = false;
    }

    // The new layout extent this sliver should now have.
    final double layoutExtent =
        (_hasLayoutExtent ? 1.0 : 0.0) * _refreshIndicatorExtent;
    // If the new layoutExtent instructive changed, the SliverGeometry's
    // layoutExtent will take that value (on the next performLayout run). Shift
    // the scroll offset first so it doesn't make the scroll position suddenly jump.
    if (refreshStyle != RefreshStyle.Front) {
      if (layoutExtent != layoutExtentOffsetCompensation) {
        geometry = SliverGeometry(
          scrollOffsetCorrection: layoutExtent - layoutExtentOffsetCompensation,
        );
        layoutExtentOffsetCompensation = layoutExtent;
        return;
      }
    }
    bool active = constraints.overlap < 0.0 || layoutExtent > 0.0;
    final double overscrolledExtent = constraints.overlap.abs();
    if (refreshStyle == RefreshStyle.Behind) {
      child.layout(
        constraints.asBoxConstraints(
            maxExtent: overscrolledExtent + layoutExtent),
        parentUsesSize: true,
      );
    } else
      child.layout(
        constraints.asBoxConstraints(),
        parentUsesSize: true,
      );
    final double boxExtent = (constraints.axisDirection == AxisDirection.up ||
            constraints.axisDirection == AxisDirection.down)
        ? child.size.height
        : child.size.width;

    if (active) {
      final double needPaintExtent = Math.min(
          Math.max(
            Math.max(
                    (constraints.axisDirection == AxisDirection.up ||
                            constraints.axisDirection == AxisDirection.down)
                        ? child.size.height
                        : child.size.width,
                    layoutExtent) -
                constraints.scrollOffset,
            0.0,
          ),
          constraints.remainingPaintExtent);
      switch (refreshStyle) {
        case RefreshStyle.Follow:
          geometry = SliverGeometry(
            scrollExtent: layoutExtent,
            paintOrigin: -boxExtent - constraints.scrollOffset + layoutExtent,
            paintExtent: needPaintExtent,
            hitTestExtent: needPaintExtent,
            hasVisualOverflow: overscrolledExtent < boxExtent,
            maxPaintExtent: needPaintExtent,
            layoutExtent: Math.min(needPaintExtent,
                Math.max(layoutExtent - constraints.scrollOffset, 0.0)),
          );

          break;
        case RefreshStyle.Behind:
          geometry = SliverGeometry(
            scrollExtent: layoutExtent,
            paintOrigin: -overscrolledExtent - constraints.scrollOffset,
            paintExtent: needPaintExtent,
            maxPaintExtent: needPaintExtent,
            layoutExtent:
                Math.max(layoutExtent - constraints.scrollOffset, 0.0),
          );
          break;
        case RefreshStyle.UnFollow:
          geometry = SliverGeometry(
            scrollExtent: layoutExtent,
            paintOrigin: Math.min(
                -overscrolledExtent - constraints.scrollOffset,
                -boxExtent - constraints.scrollOffset + layoutExtent),
            paintExtent: needPaintExtent,
            hasVisualOverflow: overscrolledExtent < boxExtent,
            maxPaintExtent: needPaintExtent,
            layoutExtent: Math.min(needPaintExtent,
                Math.max(layoutExtent - constraints.scrollOffset, 0.0)),
          );

          break;
        case RefreshStyle.Front:
          geometry = SliverGeometry(
            paintOrigin: constraints.axisDirection == AxisDirection.up ||
                    constraints.crossAxisDirection == AxisDirection.left
                ? boxExtent
                : 0.0,
            visible: true,
            hasVisualOverflow: true,
          );
          break;
      }
      setChildParentData(child, constraints, geometry);
    } else {
      geometry = SliverGeometry.zero;
    }
  }

  @override
  void paint(PaintingContext paintContext, Offset offset) {
    paintContext.paintChild(child, Offset(offset.dx, offset.dy + paintOffsetY));
  }

  @override
  void applyPaintTransform(RenderObject child, Matrix4 transform) {}
}

class SliverLoading extends SingleChildRenderObjectWidget {
  final bool hideWhenNotFull;
  final LoadStatus mode;
  final double layoutExtent;
  final bool shouldFollowContent;

  SliverLoading({
    Key key,
    this.mode,
    this.shouldFollowContent,
    this.layoutExtent,
    this.hideWhenNotFull,
    Widget child,
  }) : super(key: key, child: child);

  @override
  _RenderSliverLoading createRenderObject(BuildContext context) {
    return _RenderSliverLoading(
        hideWhenNotFull: hideWhenNotFull,
        mode: mode,
        shouldFollowContent: shouldFollowContent,
        layoutExtent: layoutExtent);
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant _RenderSliverLoading renderObject) {
    renderObject
      ..mode = mode
      ..layoutExtent = layoutExtent
      ..shouldFollowContent = shouldFollowContent
      ..hideWhenNotFull = hideWhenNotFull;
  }
}

class _RenderSliverLoading extends RenderSliverSingleBoxAdapter {
  _RenderSliverLoading({
    RenderBox child,
    this.mode,
    double layoutExtent,
    this.shouldFollowContent,
    this.hideWhenNotFull,
  }) {
    this.layoutExtent = layoutExtent;
    this.child = child;
  }

  bool shouldFollowContent;
  bool hideWhenNotFull;

  LoadStatus mode;

  double _layoutExtent;

  set layoutExtent(extent) {
    if (extent == _layoutExtent) return;
    _layoutExtent = extent;
    markNeedsLayout();
  }

  get layoutExtent => _layoutExtent;

  bool _computeIfFull(SliverConstraints cons) {
    final RenderViewport viewport = parent;
    RenderSliver sliverP = viewport.firstChild;
    double totalScrollExtent = cons.precedingScrollExtent;
    while (sliverP != this) {
      if (sliverP is _RenderSliverRefresh) {
        totalScrollExtent -= sliverP.geometry.scrollExtent;
        break;
      }
      sliverP = viewport.childAfter(sliverP);
    }
    return totalScrollExtent >= cons.viewportMainAxisExtent;
  }

  /*
  many sitiuation: 1. reverse 2. not reverse
  3. follow content 4. unfollow content
  5. not full 6. full
   */
  double computePaintOrigin(double boxExtent, bool reverse) {
    if (_computeIfFull(constraints) || shouldFollowContent) {
      if (reverse) {
        return boxExtent-layoutExtent ;
      }
      return 0.0;
    } else {
      if (reverse) {
        return Math.max(
                constraints.viewportMainAxisExtent -
                    constraints.precedingScrollExtent,
                0.0) +
            boxExtent -layoutExtent  ;
      } else {
        return Math.max(
            constraints.viewportMainAxisExtent -
                constraints.precedingScrollExtent,
            0.0);
      }
    }
  }

  @override
  void performLayout() {
    assert(constraints.growthDirection == GrowthDirection.forward);
    if (child == null) {
      geometry = SliverGeometry.zero;
      return;
    }
    bool active;

    if (hideWhenNotFull && mode == LoadStatus.idle) {
      active = _computeIfFull(constraints);
    } else {
      active = true;
    }
    if (active) {
      child.layout(constraints.asBoxConstraints(), parentUsesSize: true);
    } else {
      child.layout(constraints.asBoxConstraints(maxExtent: 0.0, minExtent: 0.0),
          parentUsesSize: true);
    }
    double childExtent = constraints.axis == Axis.vertical
        ? child.size.height
        : child.size.width;
    assert(childExtent != null);
    final double paintedChildSize =
        calculatePaintOffset(constraints, from: 0.0, to: childExtent);
    final double cacheExtent =
        calculateCacheOffset(constraints, from: 0.0, to: childExtent);
    assert(paintedChildSize.isFinite);
    assert(paintedChildSize >= 0.0);
    if (active) {
      // consider reverse loading and HideAlways==loadStyle
      geometry = SliverGeometry(
        scrollExtent: layoutExtent,
        paintExtent: paintedChildSize,
        // this need to fix later
        paintOrigin: computePaintOrigin(
            childExtent,
            constraints.axisDirection == AxisDirection.up ||
                constraints.axisDirection == AxisDirection.left),
        cacheExtent: cacheExtent,
        maxPaintExtent: childExtent,
        hitTestExtent: paintedChildSize,
        visible: true,
        hasVisualOverflow: true,
      );
      setChildParentData(child, constraints, geometry);
    } else {
      geometry = SliverGeometry.zero;
    }
  }
}
