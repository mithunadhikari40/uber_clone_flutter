import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uber_clone/intro/email_entering_section.dart';
import 'package:uber_clone/screens/reusable/animation/animating_rotating_arc.dart';
import 'package:uber_clone/utils/navigator.dart';

class GetMovingFasterScreen extends StatelessWidget {
  final _arcKey = GlobalKey<AnimatingRotatingArcState>();

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Stack(
          overflow: Overflow.visible,
          children: <Widget>[
            Positioned(
              top: 20,
              left: -20,
              child: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    navigateWithAnimationWithBackStack(
                        GetMovingFasterScreen(), context);
                  }),
            ),
            Positioned(
              left: size.width / 5,
              right: size.width / 5,
              top: size.height / 6,
              child: Image.asset(
                "assets/images/car_location.png",
              ),
            ),
            Positioned.fill(
              top: 300,
              child: _buildCenterWidget(context),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: _buildNavigationButton(context),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCenterWidget(BuildContext context) {
    return ListView(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "Get moving faster with garib ko uber",
            style: TextStyle(
              fontSize: 16.0,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "For a reliable trip, Garib ko uber collects location data from the time you open the app until a trip ends. This improves pick ups, supports and more.",
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14.0,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(
            child: Text(
              "Learn more",
              style: TextStyle(color: Colors.lightBlue),
            ),
            onTap: () {
              _learnMoreAboutUs(context);
            },
          ),
        )
      ],
    );
  }

  void _learnMoreAboutUs(BuildContext context) {
    Fluttertoast.showToast(msg: "You clikced here");
  }

  Widget _buildNavigationButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.0),
      child: AnimatingRotatingArc(
        child: FloatingActionButton(
          onPressed: () {
            _navigateToNextScreen(context);
          },
          backgroundColor: Colors.black,
          child: Icon(
            Icons.arrow_forward_ios,
            size: 32.0,
          ),
        ),
        key: _arcKey,
      ),
    );
  }

  void _navigateToNextScreen(BuildContext context) {
    _arcKey.currentState.toggleAnimation(true);
    Future.delayed(Duration(seconds: 3), () {
      _arcKey.currentState.toggleAnimation(false);
      navigateWithAnimationWithBackStack(EmailEnteringSection(), context);
    });
  }
}
