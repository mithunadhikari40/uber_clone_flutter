import 'dart:math' as Math;

import 'package:flutter/material.dart';

class AnimatingRotatingArc extends StatefulWidget {
  final Widget child;

  const AnimatingRotatingArc({Key key, this.child}) : super(key: key);

  @override
  AnimatingRotatingArcState createState() => new AnimatingRotatingArcState();
}

class AnimatingRotatingArcState extends State<AnimatingRotatingArc>
    with TickerProviderStateMixin<AnimatingRotatingArc> {
  AnimationController _controller;
  Animation<double> _animation;
  double borderWidth = 0.0;
  double spaceLength = 0.0;

  @override
  void initState() {
    super.initState();
    _controller =
        new AnimationController(vsync: this, duration: Duration(seconds: 2));
    _animation = new Tween(begin: 0.0, end: Math.pi * 2.0).animate(_controller);
//    controller.repeat();
  }

  toggleAnimation(bool toggle) {
    if (toggle) {
      _controller.repeat();
      this.setState(() {
        borderWidth = 3.0;
        spaceLength = 2.0;
      });
    } else {
      _controller.reset();
      this.setState(() {
        borderWidth = 0.0;
        spaceLength = 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return new CustomPaint(
          painter: OvalPainter(
              color: Colors.blue,
              borderWidth: borderWidth,
              dashLength: 5.0,
              spaceLength: spaceLength,
              offset: _animation.value),
          child: child,
        );
      },
      child: Container(
        width: 60.0,
        height: 60.0,
        padding: EdgeInsets.all(3.0),
        child: widget.child,
      ),
    );
  }
}

class OvalPainter extends CustomPainter {
  final Color color;
  final double borderWidth;
  final double dashLength;
  final double spaceLength;
  final double offset;

  OvalPainter(
      {@required this.borderWidth,
      @required this.dashLength,
      @required this.spaceLength,
      @required this.offset,
      @required this.color});

  double lastShortestSide;
  double lastDashLength;
  double lastSpaceLength;

  Path lastPath;

  @override
  void paint(Canvas canvas, Size size) {
    Rect rect = Offset.zero & size;

    var radius = rect.shortestSide / 2;

    canvas.translate(radius, radius);
    canvas.rotate(offset);

    Path path;
    if (lastShortestSide == rect.shortestSide &&
        dashLength == lastDashLength &&
        spaceLength == lastSpaceLength &&
        lastPath != null) {
      path = lastPath;
    } else {
      path = _getDashedCircularPath(
          rect.shortestSide / 2, dashLength, spaceLength);
      lastPath = path;
      lastShortestSide = rect.shortestSide;
      lastDashLength = dashLength;
      lastSpaceLength = spaceLength;
    }
    path = lastPath;

    canvas.drawPath(
      path,
      new Paint()
        ..style = PaintingStyle.stroke
        ..color = color
        ..strokeWidth = borderWidth,
    );
  }

  @override
  bool shouldRepaint(OvalPainter oldDelegate) {
    return offset != oldDelegate.offset ||
        color != oldDelegate.color ||
        borderWidth != oldDelegate.borderWidth;
//        dashLength != oldDelegate.dashLength ||
//        spaceLength != oldDelegate.spaceLength;
  }

  static Path _getDashedCircularPathFromNumber(
      double radius, int numSections, double dashPercentage) {
    var tau = 2 * Math.pi;
    var actualTotalLength = tau / numSections;
    var actualDashLength = actualTotalLength * dashPercentage;

    double offset = 0.0;
    Rect rect = new Rect.fromCircle(center: Offset.zero, radius: radius);

    Path path = new Path();
    for (int i = 0; i < numSections; ++i) {
      path.arcTo(rect, offset, actualDashLength, true);
      offset += actualTotalLength;
    }

    return path;
  }

  static Path _getDashedCircularPath(
      double radius, double dashLength, double spaceLength) {
    // first, find number of radians that dashlength + spacelength take
    var tau = 2 * Math.pi;
    var circumference = radius * tau;
    var dashSpaceLength = dashLength + spaceLength;
    var num = circumference / (dashSpaceLength);
    // we'll floor the value so that it's close-ish to the same amount as requested but
    // instead will be the same all around
    var closeNum = num.floor();

    return _getDashedCircularPathFromNumber(
        radius, closeNum, dashLength / dashSpaceLength);
  }
}
