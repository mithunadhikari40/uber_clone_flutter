import 'package:flutter/material.dart';
import 'dart:math';

class RotatingArc extends StatefulWidget {
  final Widget child;
  final Color arcColor;
  final double arcWidth;
  final int arcLength;

  RotatingArc(
      {@required Key key,
        @required this.child,
        this.arcColor,
        this.arcWidth,
        this.arcLength})
      : super(key: key) {
    assert(child != null, arcLength <= 100,);
  }

  @override
  RotatingArcState createState() => RotatingArcState();
}

class RotatingArcState extends State<RotatingArc>
    with SingleTickerProviderStateMixin {
  AnimationController animationController;
  bool animating = false;

  void toggleAnimation(bool animate) {
    print('yo ta call vayo ta bro haru ${animate}');
    setState(() {
      animating = animate;
    });
  }

  void resetAnimation() {
    setState(() {
      animating = false;
    });
    animationController.reset();
  }

  @override
  void initState() {
    animationController = new AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );
    animationController.repeat();
    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  Widget getCircularChild() {
    return ClipOval(
      child: widget.child,
      clipper: CircleClipper(),
    );
  }

  @override
  Widget build(BuildContext context) {
    animating ? animationController.repeat() : animationController.stop();
    return AnimatedBuilder(
      animation: animationController,
      builder: (BuildContext context, Widget _widget) {
        return Transform.rotate(
            angle: animationController.value * -6.3, child: _widget);
      },
      child: widget.child,
    );
  }
}

class CircleClipper extends CustomClipper<Rect> {
  @override
  Rect getClip(Size size) {
    return Rect.fromCircle(
        center: Offset(size.width / 2, size.height / 2),
        radius: min(size.width, size.height) / 2);
  }

  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) => true;
}

class CirclePainter extends CustomPainter {
  final Color arcColor;
  final double arcWidth;
  final double arcLength;
  final trackPaint;
  final arcPaint;
  final bool show;

  CirclePainter({this.arcColor, this.arcWidth, this.arcLength, this.show})
      : trackPaint = Paint()
    ..color = Colors.black
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.0,
        arcPaint = Paint()
          ..color = arcColor ?? Colors.blue
          ..style = PaintingStyle.stroke
          ..strokeWidth = arcWidth ?? 5.0
          ..strokeCap = StrokeCap.round;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;
    // canvas.drawCircle(center, radius, trackPaint);
    canvas.drawArc(
        Rect.fromCircle(
          center: center,
          radius: radius,
        ),
        -pi / 2,
        2 * pi * (15 / 100),
        false,
        arcPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
