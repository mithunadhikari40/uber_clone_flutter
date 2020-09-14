import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uber_clone/intro/get_moving_faster_screen.dart';
import 'package:uber_clone/screens/reusable/animation/animating_rotating_arc.dart';
import 'package:uber_clone/utils/navigator.dart';

class AgreeTermsAndConditions extends StatelessWidget {
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
                "assets/images/accept_icon.png",
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
            "By tapping the arrow below, you agree to Garib ko Uber's Terms and Private Policy",
            style: TextStyle(
              fontSize: 16.0,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
              left: 8.0, right: 8.0, bottom: 8.0, top: 32.0),
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: "To learn more, see our",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14.0,
                  ),
                ),
                TextSpan(
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Fluttertoast.showToast(msg: "Terms and conditions");
                    },
                  text: " Terms and Conditions ",
                  style: TextStyle(
                      color: Colors.blue,
                      fontSize: 14.0,
                      fontStyle: FontStyle.italic),
                ),
                TextSpan(
                  text: "and",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14.0,
                  ),
                ),
                TextSpan(
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      return Fluttertoast.showToast(msg: "Privacy policy");
                    },
                  text: " Privacy policy",
                  style: TextStyle(
                      color: Colors.blue,
                      fontSize: 14.0,
                      fontStyle: FontStyle.italic),
                ),
              ],
            ),
//            style: TextStyle(
//              color: Colors.grey[600],
//              fontSize: 14.0,
//            ),
          ),
        ),
      ],
    );
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
    });
  }
}
