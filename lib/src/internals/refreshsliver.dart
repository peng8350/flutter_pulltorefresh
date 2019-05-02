/*
 * Author: Jpeng
 * Email: peng8350@gmail.com
 * Time: 2019/5/2 下午5:09
 */

import 'package:flutter/material.dart';
import 'dart:math' as Math;
import 'package:flutter/rendering.dart';
import '../smart_refresher.dart';

class SliverRefresh extends SingleChildRenderObjectWidget {
  const SliverRefresh(
      {Key key,
      this.refreshIndicatorLayoutExtent = 0.0,
      this.hasLayoutExtent = false,
      Widget child,
      this.refreshStyle,
      this.up})
      : assert(refreshIndicatorLayoutExtent != null),
        assert(refreshIndicatorLayoutExtent >= 0.0),
        assert(hasLayoutExtent != null),
        super(key: key, child: child);

  // The amount of space the indicator should occupy in the sliver in a
  // resting state when in the refreshing mode.
  final double refreshIndicatorLayoutExtent;

  // _RenderCupertinoSliverRefresh will paint the child in the available
  // space either way but this instructs the _RenderCupertinoSliverRefresh
  // on whether to also occupy any layoutExtent space or not.
  final bool hasLayoutExtent;

  final RefreshStyle refreshStyle;

  final bool up;

  @override
  _RefreshRenderSliver createRenderObject(BuildContext context) {
    return _RefreshRenderSliver(
      refreshIndicatorExtent: refreshIndicatorLayoutExtent,
      hasLayoutExtent: hasLayoutExtent,
      up: up,
      refreshStyle: refreshStyle,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant _RefreshRenderSliver renderObject) {
    renderObject
      ..refreshIndicatorLayoutExtent = refreshIndicatorLayoutExtent
      ..hasLayoutExtent = hasLayoutExtent;
  }
}

class _RefreshRenderSliver extends RenderSliver
    with RenderObjectWithChildMixin<RenderBox> {
  _RefreshRenderSliver(
      {@required double refreshIndicatorExtent,
      @required bool hasLayoutExtent,
      RenderBox child,
      this.up,
      this.refreshStyle})
      : assert(refreshIndicatorExtent != null),
        assert(refreshIndicatorExtent >= 0.0),
        assert(hasLayoutExtent != null),
        _refreshIndicatorExtent = refreshIndicatorExtent,
        _hasLayoutExtent = hasLayoutExtent {
    this.child = child;
  }

  final bool up;

  final RefreshStyle refreshStyle;
  // The amount of layout space the indicator should occupy in the sliver in a
  // resting state when in the refreshing mode.
  double get refreshIndicatorLayoutExtent => _refreshIndicatorExtent;
  double _refreshIndicatorExtent;
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
  void performLayout() {
    // Only pulling to refresh from the top is currently supported.
    assert(constraints.axisDirection == AxisDirection.down);
    assert(constraints.growthDirection == GrowthDirection.forward);

    // The new layout extent this sliver should now have.
    final double layoutExtent =
        (_hasLayoutExtent ? 1.0 : 0.0) * _refreshIndicatorExtent;
    // If the new layoutExtent instructive changed, the SliverGeometry's
    // layoutExtent will take that value (on the next performLayout run). Shift
    // the scroll offset first so it doesn't make the scroll position suddenly jump.
    if (layoutExtent != layoutExtentOffsetCompensation) {
      geometry = SliverGeometry(
        scrollOffsetCorrection: layoutExtent - layoutExtentOffsetCompensation,
      );
      layoutExtentOffsetCompensation = layoutExtent;
      // Return so we don't have to do temporary accounting and adjusting the
      // child's constraints accounting for this one transient frame using a
      // combination of existing layout extent, new layout extent change and
      // the overlap.
      return;
    }

    final bool active = constraints.overlap < 0.0 || layoutExtent > 0.0;
    final double overscrolledExtent =
        constraints.overlap < 0.0 ? constraints.overlap.abs() : 0.0;

    // Layout the child giving it the space of the currently dragged overscroll
    // which may or may not include a sliver layout extent space that it will
    // keep after the user lets go during the refresh process.
    if (refreshStyle == RefreshStyle.Back) {
      child.layout(
        constraints.asBoxConstraints(maxExtent: overscrolledExtent+layoutExtent),
        parentUsesSize: true,
      );
//      print(child.layer.depth);
    }
//      child.layout(
//        parentUsesSize: true,
//      );
    if (active) {
      switch (refreshStyle) {
        case RefreshStyle.Follow:
          geometry = SliverGeometry(
            scrollExtent: layoutExtent,
            paintOrigin: -refreshIndicatorLayoutExtent -
                constraints.scrollOffset +
                layoutExtent,
            paintExtent: Math.max(
              Math.max(child.size.height, layoutExtent) -
                  constraints.scrollOffset,
              0.0,
            ),
            maxPaintExtent: Math.max(
              Math.max(child.size.height, layoutExtent) -
                  constraints.scrollOffset,
              0.0,
            ),
            layoutExtent:
                Math.max(layoutExtent - constraints.scrollOffset, 0.0),
          );

          break;
        case RefreshStyle.Back:
          geometry = SliverGeometry(
            scrollExtent: layoutExtent,
            paintOrigin: -overscrolledExtent - constraints.scrollOffset,
            paintExtent: Math.max(
              Math.max(child.size.height, layoutExtent) - constraints.scrollOffset,
              0.0,
            ),
            maxPaintExtent: Math.max(
              Math.max(child.size.height, layoutExtent) - constraints.scrollOffset,
              0.0,
            ),
            layoutExtent: Math.max(layoutExtent - constraints.scrollOffset, 0.0),
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
            paintExtent: Math.max(
              Math.max(child.size.height, layoutExtent) -
                  constraints.scrollOffset,
              0.0,
            ),
            maxPaintExtent: Math.max(
              Math.max(child.size.height, layoutExtent) -
                  constraints.scrollOffset,
              0.0,
            ),
            layoutExtent:
                Math.max(layoutExtent - constraints.scrollOffset, 0.0),
          );

          break;
        case RefreshStyle.Front:
          geometry = SliverGeometry(
            scrollExtent: layoutExtent,
            paintOrigin: -overscrolledExtent ,
            paintExtent: Math.max(
              Math.max(child.size.height, layoutExtent) -
                  constraints.scrollOffset,
              0.0,
            ),
            maxPaintExtent: Math.max(
              Math.max(child.size.height, layoutExtent) -
                  constraints.scrollOffset,
              0.0,
            ),
            layoutExtent:
            0.0,
          );
          break;
      }
    } else {
      // If we never started overscrolling, return no geometry.
      geometry = SliverGeometry.zero;
    }
  }

  @override
  void paint(PaintingContext paintContext, Offset offset) {
    if (constraints.overlap < 0.0 ||
        constraints.scrollOffset + child.size.height > 0) {
      paintContext.paintChild(child, offset);
    }
  }

  // Nothing special done here because this sliver always paints its child
  // exactly between paintOrigin and paintExtent.
  @override
  void applyPaintTransform(RenderObject child, Matrix4 transform) {}
}
