/*
 * Author: Jpeng
 * Email: peng8350@gmail.com
 * Time: 2019/5/2 下午5:09
 */

import 'package:flutter/material.dart';
import 'dart:math' as Math;
import 'package:flutter/rendering.dart';
import '../smart_refresher.dart';
import 'package:flutter/cupertino.dart';

class SliverRefresh extends SingleChildRenderObjectWidget {
  const SliverRefresh(
      {Key key,
      this.refreshIndicatorLayoutExtent = 0.0,
      this.hasLayoutExtent = false,
      Widget child,
      this.refreshStyle,
      this.reverse})
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

  final bool reverse;

  @override
  _RefreshRenderSliver createRenderObject(BuildContext context) {
    return _RefreshRenderSliver(
      refreshIndicatorExtent: refreshIndicatorLayoutExtent,
      hasLayoutExtent: hasLayoutExtent,
      reverse: reverse,
      refreshStyle: refreshStyle,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant _RefreshRenderSliver renderObject) {
    renderObject
      ..refreshIndicatorLayoutExtent = refreshIndicatorLayoutExtent
      ..hasLayoutExtent = hasLayoutExtent
        ;

  }
}

class _RefreshRenderSliver extends RenderSliver
    with RenderObjectWithChildMixin<RenderBox> {
  _RefreshRenderSliver(
      {@required double refreshIndicatorExtent,
      @required bool hasLayoutExtent,
      RenderBox child,
      this.reverse,
      this.refreshStyle})
      : assert(refreshIndicatorExtent != null),
        assert(refreshIndicatorExtent >= 0.0),
        assert(hasLayoutExtent != null),
        _refreshIndicatorExtent = refreshIndicatorExtent,
        _hasLayoutExtent = hasLayoutExtent {
    this.child = child;
  }

  final bool reverse;

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
//    assert(constraints.axisDirection == AxisDirection.down);
    assert(constraints.growthDirection == GrowthDirection.forward);
    // The new layout extent this sliver should now have.
    final double layoutExtent =
        (_hasLayoutExtent ? 1.0 : 0.0) * _refreshIndicatorExtent;
    // If the new layoutExtent instructive changed, the SliverGeometry's
    // layoutExtent will take that value (on the next performLayout run). Shift
    // the scroll offset first so it doesn't make the scroll position suddenly jump.
    if (layoutExtent != layoutExtentOffsetCompensation&&refreshStyle!=RefreshStyle.Front) {

      geometry = SliverGeometry(
        scrollOffsetCorrection: layoutExtent - layoutExtentOffsetCompensation,
      );
      layoutExtentOffsetCompensation = layoutExtent;
      return;
    }
    final bool active = constraints.overlap < 0.0 || layoutExtent > 0.0;
    final double overscrolledExtent =
        constraints.overlap < 0.0 ? constraints.overlap.abs() : 0.0;

    if (refreshStyle == RefreshStyle.Back) {
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
            scrollExtent:0.0,
            /* I don't know why in reverse mode,it own a distance 40 from bottom,may be this is related with SafeArea in IOS,
              check a lot
             */
            paintOrigin: reverse?-overscrolledExtent-40.0:-overscrolledExtent,
            paintExtent: hasLayoutExtent?100.0:Math.max(
              Math.max(child.size.height, layoutExtent) -
                  constraints.scrollOffset,
              0.0,
            ),
            maxPaintExtent: hasLayoutExtent?100.0:Math.max(
              Math.max(child.size.height, layoutExtent) -
                  constraints.scrollOffset,
              0.0,
            ),
            layoutExtent: 0.0,
          );
          break;
      }
    } else {
      geometry = SliverGeometry.zero;
    }
  }



  @override
  void paint(PaintingContext paintContext, Offset offset) {
    paintContext.paintChild(child, offset);
  }

  @override
  void applyPaintTransform(RenderObject child, Matrix4 transform) {}
}
