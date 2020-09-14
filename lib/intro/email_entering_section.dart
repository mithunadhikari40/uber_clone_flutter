import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uber_clone/intro/password_entering_section.dart';
import 'package:uber_clone/intro/sms_code_validation_section.dart';
import 'package:uber_clone/screens/reusable/animation/animating_rotating_arc.dart';
import 'package:uber_clone/utils/navigator.dart';

enum USER_VERIFICATION { UNDER_PROCESS, AUTHORIZED, UNAUTHORIZED }

class EmailEnteringSection extends StatefulWidget {
  @override
  _EmailEnteringSectionState createState() => _EmailEnteringSectionState();
}

class _EmailEnteringSectionState extends State<EmailEnteringSection>
    with TickerProviderStateMixin<EmailEnteringSection> {
  TextEditingController _emailController = TextEditingController();

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
    _emailController.dispose();
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
            style: TextStyle(fontSize: 20.0),
            cursorColor: Colors.black,
            keyboardType: TextInputType.emailAddress,
            controller: _emailController,
            textInputAction: TextInputAction.go,
            onSubmitted: (value) {
              submitEmailAddress(value);
            },
            decoration: InputDecoration(
              hintText: "someone@example.com",
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
                SmsCodeValidationSection(
                  phoneNumber: _emailController.text,
                  verificationId: "",
                ),
                context);
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
            submitEmailAddress(_emailController.text);
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

  bool validateEmail() {
    return _emailController.text.length > 5 &&
        _emailController.text.contains("@") &&
        _emailController.text.contains(".");
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

  submitEmailAddress(String email) {
    _arcKey.currentState.toggleAnimation(true);

    if (validateEmail()) {
      this.setState(() {
        userVerified = USER_VERIFICATION.AUTHORIZED;
        errorMessage = "";
      });
      _arcKey.currentState.toggleAnimation(false);

      navigateWithAnimationWithBackStack(PasswordEnteringSection(), context);
    } else {
      this.setState(() {
        errorMessage = "The email address you have entered is not valid";
        userVerified = USER_VERIFICATION.UNAUTHORIZED;
      });

      Fluttertoast.showToast(msg: "Invalid email address");
      _arcKey.currentState.toggleAnimation(false);
    }
  }

  _buildDescriptionSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 24.0),
      child: Text(
        "What's your email address? ",
        style: TextStyle(fontSize: 20.0),
      ),
    );
  }
}
