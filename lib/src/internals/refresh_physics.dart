/*
    Author: Jpeng
    Email: peng8350@gmail.com
    createTime:2018-05-02 14:39
 */

import 'package:flutter/widgets.dart';
import 'dart:math' as math;

/*
    this class  is copy from BouncingScrollPhysics,
    because it doesn't fit my idea,
    Fixed the problem that child parts could not be dragged without data.
 */
class RefreshBouncePhysics extends BouncingScrollPhysics {
  /// Creates scroll physics that bounce back from the edge.
  const RefreshBouncePhysics({ScrollPhysics parent}) : super(parent: parent);

  @override
  RefreshBouncePhysics applyTo(ScrollPhysics ancestor) {
    return RefreshBouncePhysics(parent: buildParent(ancestor));
  }

  @override
  bool shouldAcceptUserOffset(ScrollMetrics position) {
    // TODO: implement shouldAcceptUserOffset
    return true;
  }
}

class RefreshClampPhysics extends ScrollPhysics {
  final double springBackDistance;

  /// Creates scroll physics that bounce back from the edge.
  const RefreshClampPhysics(
      {ScrollPhysics parent, this.springBackDistance: 100.0})
      : super(parent: parent);

  @override
  RefreshClampPhysics applyTo(ScrollPhysics ancestor) {
    return RefreshClampPhysics(
        parent: buildParent(ancestor),
        springBackDistance: this.springBackDistance);
  }

  @override
  bool shouldAcceptUserOffset(ScrollMetrics position) {
    // TODO: implement shouldAcceptUserOffset
    return true;
  }

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    // TODO: implement applyPhysicsToUserOffset
    final ScrollPosition scrollPosition = position as ScrollPosition;
    if (position.extentBefore < springBackDistance) {
      final double newPixels = position.pixels - offset * 0.5;

      if (scrollPosition.userScrollDirection.index == 2) {
        if (newPixels > springBackDistance) {
          return position.pixels - springBackDistance;
        } else {
          return offset * 0.5;
        }
      }
      return offset * 0.5;
    }
    return super.applyPhysicsToUserOffset(position, offset);
  }

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    final ScrollPosition scrollPosition = position as ScrollPosition;
    if (scrollPosition.extentBefore < springBackDistance) {
      if (scrollPosition.activity is BallisticScrollActivity) {
        //spring Back
        if (value > position.pixels) {
          return 0.0;
        }
      }
      if (scrollPosition.activity is DragScrollActivity) {
        if (value < position.pixels &&
            position.pixels <= position.minScrollExtent) // underscroll
          return value - position.pixels;
        if (value < position.minScrollExtent &&
            position.minScrollExtent < position.pixels) // hit top edge
          return value - position.minScrollExtent;

        return 0.0;
      }
    }
    if (value < position.pixels &&
        position.pixels <= position.minScrollExtent) // underscroll
      return value - position.pixels;
    if (value < position.minScrollExtent &&
        position.minScrollExtent < position.pixels) // hit top edge
      return value - position.minScrollExtent;
    if (position.maxScrollExtent <= position.pixels &&
        position.pixels < value) // overscroll
      return value - position.pixels;
    if (position.pixels < position.maxScrollExtent &&
        position.maxScrollExtent < value) // hit bottom edge
      return value - position.maxScrollExtent;
    return 0.0;
  }

  @override
  Simulation createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    final Tolerance tolerance = this.tolerance;
    if (position.extentBefore < springBackDistance) {
      return ScrollSpringSimulation(
        spring,
        math.max(0.0, position.pixels),
        springBackDistance,
        0.0,
        tolerance: tolerance,
      );
    }
    if (velocity.abs() <= tolerance.velocity.abs()) return null;
    return RefreshClampingSimulation(
      position: position.pixels,
      velocity: velocity,
      extentBefore:
          velocity < 0 ? position.extentBefore - springBackDistance : -1.0,
      tolerance: tolerance,
    );
  }
}

class RefreshClampingSimulation extends ClampingScrollSimulation {
  /// Creates a scroll physics simulation that matches Android scrolling.
  RefreshClampingSimulation({
    double position,
    double velocity,
    this.extentBefore,
    double friction = 0.015,
    Tolerance tolerance = Tolerance.defaultTolerance,
  })  : assert(_flingVelocityPenetration(0.0) == _initialVelocityPenetration),
        super(
            tolerance: tolerance,
            position: position,
            velocity: velocity,
            friction: friction) {
    if (extentBefore != -1.0) {
      _duration = _flingDuration(velocity);
      _distance = math.min(
          (velocity * _duration / _initialVelocityPenetration).abs(),
          extentBefore);
      if (_distance == extentBefore) {
        _duration = _distance / 1000;
      }
    } else {
      _duration = _flingDuration(velocity);
      _distance = (velocity * _duration / _initialVelocityPenetration).abs();
    }
  }

  final double extentBefore;
  double _duration;
  double _distance;

  static final double _kDecelerationRate = math.log(0.78) / math.log(0.9);

  static double _decelerationForFriction(double friction) {
    return friction * 61774.04968;
  }

  // See getSplineFlingDuration(). Returns a value in seconds.
  double _flingDuration(double velocity) {
    // See mPhysicalCoeff
    final double scaledFriction = friction * _decelerationForFriction(0.84);

    // See getSplineDeceleration().
    final double deceleration =
        math.log(0.35 * velocity.abs() / scaledFriction);

    return math.exp(deceleration / (_kDecelerationRate - 1.0));
  }

  // Based on a cubic curve fit to the Scroller.computeScrollOffset() values
  // produced for an initial velocity of 4000. The value of Scroller.getDuration()
  // and Scroller.getFinalY() were 686ms and 961 pixels respectively.
  //
  // Algebra courtesy of Wolfram Alpha.
  //
  // f(x) = scrollOffset, x is time in milliseconds
  // f(x) = 3.60882×10^-6 x^3 - 0.00668009 x^2 + 4.29427 x - 3.15307
  // f(x) = 3.60882×10^-6 x^3 - 0.00668009 x^2 + 4.29427 x, so f(0) is 0
  // f(686ms) = 961 pixels
  // Scale to f(0 <= t <= 1.0), x = t * 686
  // f(t) = 1165.03 t^3 - 3143.62 t^2 + 2945.87 t
  // Scale f(t) so that 0.0 <= f(t) <= 1.0
  // f(t) = (1165.03 t^3 - 3143.62 t^2 + 2945.87 t) / 961.0
  //      = 1.2 t^3 - 3.27 t^2 + 3.065 t
  static const double _initialVelocityPenetration = 3.065;

  static double _flingDistancePenetration(double t) {
    return (1.2 * t * t * t) -
        (3.27 * t * t) +
        (_initialVelocityPenetration * t);
  }

  // The derivative of the _flingDistancePenetration() function.
  static double _flingVelocityPenetration(double t) {
    return (3.6 * t * t) - (6.54 * t) + _initialVelocityPenetration;
  }

  @override
  double x(double time) {
    final double t = (time / _duration).clamp(0.0, 1.0);
    return position + _distance * _flingDistancePenetration(t) * velocity.sign;
  }

  @override
  double dx(double time) {
    final double t = (time / _duration).clamp(0.0, 1.0);
    return _distance * _flingVelocityPenetration(t) * velocity.sign / _duration;
  }

  @override
  bool isDone(double time) {
    return time >= _duration;
  }
}
