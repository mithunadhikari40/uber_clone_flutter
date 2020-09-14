import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uber_clone/intro/first_mobile_number_section.dart';
import 'package:uber_clone/screens/reusable/animation/animating_rotating_arc.dart';
import 'package:uber_clone/utils/navigator.dart';

enum USER_VERIFICATION { UNDER_PROCESS, AUTHORIZED, UNAUTHORIZED }

class PasswordEnteringSection extends StatefulWidget {
  @override
  _PasswordEnteringSectionState createState() =>
      _PasswordEnteringSectionState();
}

class _PasswordEnteringSectionState extends State<PasswordEnteringSection>
    with TickerProviderStateMixin<PasswordEnteringSection> {
  TextEditingController _passwordController = TextEditingController();

  GlobalKey<AnimatingRotatingArcState> _arcKey = GlobalKey();
  USER_VERIFICATION userVerified = USER_VERIFICATION.UNDER_PROCESS;
  String errorMessage = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: <Widget>[
        ListView(
          children: <Widget>[
            _buildBackArrow(context),
            _buildDescriptionSection(context),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: _buildLowerSection(context),
            ),
            _buildCodeErrorSection(context)
          ],
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: _buildGotoNextScreenButton(context),
        ),
      ]),
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Widget _buildLowerSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(12.0),
          ),
          border: Border.all(color: Colors.blue[400])),
      padding: EdgeInsets.only(bottom: 20.0, top: 8.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Container(
          margin: EdgeInsets.only(left: 10, top: 0),
          child: TextField(
            autofocus: true,
            obscureText: true,
            style: TextStyle(fontSize: 20.0),
            cursorColor: Colors.black,
            keyboardType: TextInputType.text,
            controller: _passwordController,
            textInputAction: TextInputAction.go,
            onSubmitted: (value) {
              submitPassword(value);
            },
            decoration: InputDecoration(
              hintText: "Your password",
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(left: 15.0, top: 16.0),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackArrow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        IconButton(
          onPressed: () {
            _arcKey.currentState.toggleAnimation(false);
            navigateWithAnimationWithBackStack(
                PasswordEnteringSection(), context);
          },
          icon: Icon(Icons.arrow_back),
        ),
      ],
    );
  }

  _buildGotoNextScreenButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 24.0),
      child: AnimatingRotatingArc(
        child: FloatingActionButton(
          onPressed: () {
            submitPassword(_passwordController.text);
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

  bool validatePassword() {
    return _passwordController.text.length > 5;
  }

  _buildCodeErrorSection(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
        child: userVerified == USER_VERIFICATION.AUTHORIZED
            ? Container()
            : Text(
                errorMessage,
                style: TextStyle(color: Colors.red[400]),
              ));
  }

  submitPassword(String password) {
    _arcKey.currentState.toggleAnimation(true);

    if (validatePassword()) {
      this.setState(() {
        userVerified = USER_VERIFICATION.AUTHORIZED;
        errorMessage = "";
      });
      _arcKey.currentState.toggleAnimation(false);

      navigateWithAnimationWithBackStack(FirstMobileNumberSection(), context);
    } else {
      this.setState(() {
        errorMessage = "The password must be at least 5 characters long";
        userVerified = USER_VERIFICATION.UNAUTHORIZED;
      });

      Fluttertoast.showToast(
          msg: "The password must be at least 5 characters long");
      _arcKey.currentState.toggleAnimation(false);
    }
  }

  _buildDescriptionSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 24.0),
      child: Text(
        "Please enter your password ",
        style: TextStyle(fontSize: 20.0),
      ),
    );
  }
}
