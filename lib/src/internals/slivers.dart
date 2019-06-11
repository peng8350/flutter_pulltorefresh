/*
 * Author: Jpeng
 * Email: peng8350@gmail.com
 * Time: 2019/5/2 下午5:09
 */

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
    this.reverse,
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
  final bool reverse;
  final double paintOffsetY;

  @override
  _RenderSliverRefresh createRenderObject(BuildContext context) {
    return _RenderSliverRefresh(
      refreshIndicatorExtent: refreshIndicatorLayoutExtent,
      hasLayoutExtent: floating,
      reverse: reverse,
      paintOffsetY: paintOffsetY,
      refreshStyle: refreshStyle,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant _RenderSliverRefresh renderObject) {
    renderObject
      ..refreshIndicatorLayoutExtent = refreshIndicatorLayoutExtent
      ..hasLayoutExtent = floating
      ..reverse = reverse
      ..paintOffsetY = paintOffsetY;
  }
}

class _RenderSliverRefresh extends RenderSliver
    with RenderObjectWithChildMixin<RenderBox> {
  _RenderSliverRefresh(
      {@required double refreshIndicatorExtent,
      @required bool hasLayoutExtent,
      RenderBox child,
      this.paintOffsetY,
      this.reverse,
      this.refreshStyle})
      : assert(refreshIndicatorExtent != null),
        assert(refreshIndicatorExtent >= 0.0),
        assert(hasLayoutExtent != null),
        _refreshIndicatorExtent = refreshIndicatorExtent,
        _hasLayoutExtent = hasLayoutExtent {
    this.child = child;
  }

  final RefreshStyle refreshStyle;

  // The amount of layout space the indicator should occupy in the sliver in a
  // resting state when in the refreshing mode.
  double get refreshIndicatorLayoutExtent => _refreshIndicatorExtent;
  double _refreshIndicatorExtent;
  double paintOffsetY;
  bool reverse;

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
  void detach() {
    // TODO: implement detach
    super.detach();
  }

  @override
  void performLayout() {
    // Only pulling to refresh from the top is currently supported.
//    assert(constraints.axisDirection == AxisDirection.down);
    assert(constraints.growthDirection == GrowthDirection.forward);
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
    } else if (layoutExtentOffsetCompensation == 0.0) {
      // when FrontStyle init ,it should  be corrected  from 0.0 to 100.0
      geometry = SliverGeometry(
          scrollOffsetCorrection: refreshIndicatorLayoutExtent,
          scrollExtent: refreshIndicatorLayoutExtent);
      layoutExtentOffsetCompensation = -1.0;
      return;
    }
    bool active;
    if (refreshStyle != RefreshStyle.Front) {
      active = constraints.overlap < 0.0 || layoutExtent > 0.0;
    } else {
      active = constraints.scrollOffset < refreshIndicatorLayoutExtent ||
          hasLayoutExtent;
    }
    final double overscrolledExtent = constraints.overlap.abs();
    if (refreshStyle == RefreshStyle.Behind) {
      child.layout(
        constraints.asBoxConstraints(
            maxExtent: overscrolledExtent + layoutExtent),
        parentUsesSize: true,
      );
    } else
      child.layout(
        constraints.asBoxConstraints(maxExtent: refreshIndicatorLayoutExtent),
        parentUsesSize: true,
      );
    if (active) {
      final double needPaintExtent = Math.min(
          Math.max(
            Math.max(child.size.height, layoutExtent) -
                constraints.scrollOffset,
            0.0,
          ),
          constraints.remainingPaintExtent);
      switch (refreshStyle) {
        case RefreshStyle.Follow:
          geometry = SliverGeometry(
            scrollExtent: layoutExtent,
            paintOrigin: -refreshIndicatorLayoutExtent -
                constraints.scrollOffset +
                layoutExtent,
            paintExtent: needPaintExtent,
            hasVisualOverflow:
                overscrolledExtent < refreshIndicatorLayoutExtent,
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
            layoutExtent: Math.min(needPaintExtent,
                Math.max(layoutExtent - constraints.scrollOffset, 0.0)),
          );
          break;
        case RefreshStyle.UnFollow:
          geometry = SliverGeometry(
            scrollExtent: layoutExtent,
            paintOrigin: Math.min(
                -overscrolledExtent - constraints.scrollOffset,
                -refreshIndicatorLayoutExtent -
                    constraints.scrollOffset +
                    layoutExtent),
            paintExtent: needPaintExtent,
            hasVisualOverflow:
                overscrolledExtent < refreshIndicatorLayoutExtent,
            maxPaintExtent: needPaintExtent,
            layoutExtent: Math.min(needPaintExtent,
                Math.max(layoutExtent - constraints.scrollOffset, 0.0)),
          );

          break;
        case RefreshStyle.Front:
          geometry = SliverGeometry(
            scrollExtent: refreshIndicatorLayoutExtent,
            paintOrigin: reverse ? refreshIndicatorLayoutExtent : 0.0,
            paintExtent: 0.01,
            maxPaintExtent: 0.01,
            hasVisualOverflow: true,
            layoutExtent: 0.0,
          );
          break;
      }
    } else {
      geometry = refreshStyle == RefreshStyle.Front
          ? SliverGeometry(scrollExtent: refreshIndicatorLayoutExtent)
          : SliverGeometry.zero;
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

  SliverLoading({
    Key key,
    this.hideWhenNotFull,
    Widget child,
  }) : super(key: key, child: child);

  @override
  _RenderSliverLoading createRenderObject(BuildContext context) {
    return _RenderSliverLoading(
      hideWhenNotFull: hideWhenNotFull,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant _RenderSliverLoading renderObject) {}
}

class _RenderSliverLoading extends RenderSliverSingleBoxAdapter {
  _RenderSliverLoading({
    RenderBox child,
    this.hideWhenNotFull,
  }) {
    this.child = child;
  }

  final bool hideWhenNotFull;
  double headerHeight;

  // This keeps track of the previously applied scroll offsets to the scrollable
  // so that when [refreshIndicatorLayoutExtent] or [hasLayoutExtent] changes,
  // the appropriate delta can be applied to keep everything in the same place
  // visually.
  final double layoutExtentOffsetCompensation = 0.0;

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

  @override
  void performLayout() {
    assert(constraints.growthDirection == GrowthDirection.forward);
    if (child == null) {
      geometry = SliverGeometry.zero;
      return;
    }
    bool active;
    if (hideWhenNotFull) {
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

    double childExtent = child.size.height;
    assert(childExtent != null);
    final double paintedChildSize =
        calculatePaintOffset(constraints, from: 0.0, to: childExtent);
    final double cacheExtent =
        calculateCacheOffset(constraints, from: 0.0, to: childExtent);
    assert(paintedChildSize.isFinite);
    assert(paintedChildSize >= 0.0);
    if (active) {
      geometry = SliverGeometry(
        scrollExtent: childExtent,
        paintExtent: paintedChildSize,
        cacheExtent: cacheExtent,
        maxPaintExtent: childExtent,
        hitTestExtent: paintedChildSize,
        hasVisualOverflow: childExtent > constraints.remainingPaintExtent ||
            constraints.scrollOffset > 0.0,
      );
      setChildParentData(child, constraints, geometry);
    } else {
      geometry = SliverGeometry.zero;
    }
  }
}
