import 'dart:io' as io;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uber_clone/intro/sms_code_validation_section.dart';
import 'package:uber_clone/screens/reusable/animation/animating_rotating_arc.dart';
import 'package:uber_clone/screens/reusable/simple_auto_complete_text_view.dart';
import 'package:uber_clone/utils/navigator.dart';

class FirstMobileNumberSection extends StatefulWidget {
  @override
  _FirstMobileNumberSectionState createState() =>
      _FirstMobileNumberSectionState();
}

class _FirstMobileNumberSectionState extends State<FirstMobileNumberSection>
    with TickerProviderStateMixin<FirstMobileNumberSection> {
  TextEditingController _phoneController = TextEditingController();
  String verificationId;
  bool shouldShowUpperSection = true;
  bool shouldHideKeyboard = true;

  GlobalKey<AnimatingRotatingArcState> _arcKey = GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: () {
          if (shouldShowUpperSection) {
            io.exit(0);
          } else {
            this.setState(() {
              shouldShowUpperSection = true;
              shouldHideKeyboard = true;
            });
          }
        },
        child: Stack(
          children: <Widget>[
            ListView(
              children: <Widget>[
                _buildUpperSection(context),
                _buildBackArrow(context),
                _buildLowerSection(context),
              ],
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: _buildGotoNextScreenButton(context),
            ),
          ],
        ),
      ),
    );
  }

  //sends the code to the specified number
  Future<void> _sendCodeToPhoneNumber(String phone) async {
    try {
      final PhoneVerificationCompleted phoneVerificationCompleted =
          (AuthCredential credential) {
        setState(() {
          print(
              'Inside _sendCodeToPhoneNumber: signInWithPhoneNumber auto succeeded: $credential');
        });
      };

      final PhoneVerificationFailed verificationFailed =
          (AuthException exception) {
        setState(() {
          print(
              'Phone number verification failed. Code: ${exception.code}. Message: ${exception.message}');
        });
      };

      final PhoneCodeSent codeSent =
          (String verificationId, [int forceSendingToken]) {
        this.verificationId = verificationId;
        print("Code is sent to $phone");
      };

      final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
          (String verificationId) {
        this.verificationId = verificationId;
        print("Time out exception occured");
      };

      await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: phone,
          timeout: Duration(seconds: 5),
          verificationCompleted: phoneVerificationCompleted,
          verificationFailed: verificationFailed,
          codeSent: codeSent,
          codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
      Future.delayed(Duration(seconds: 2), () {
        _arcKey.currentState.toggleAnimation(false);
        navigateWithAnimationWithBackStack(
            SmsCodeValidationSection(
                verificationId: verificationId, phoneNumber: phone),
            context);
      });
    } on Exception catch (e) {
      _arcKey.currentState.toggleAnimation(false);

      Fluttertoast.showToast(
          msg: "There was some error on sending the message ${e}");
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Widget _buildUpperSection(BuildContext context) {
    print("The dismiss value is $shouldShowUpperSection");
    return _UpperSection(shouldShowThisSection: shouldShowUpperSection);
  }

  Widget _buildLowerSection(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(
              top: shouldShowUpperSection ? 32.0 : 0,
              left: 24.0,
              right: 12.0,
              bottom: 8.0),
          child: Text(
            shouldShowUpperSection
                ? "Getting moving with garib ko uber"
                : "Please enter your mobile number",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 12.0),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(12.0),
              ),
              border: Border.all(color: Colors.blue[400])),
          padding: EdgeInsets.only(bottom: 20.0, top: 8.0, left: 0),
          child: SimpleAutoCompleteTextView(
            shouldHideKeyboard: shouldHideKeyboard,
            onFocusGained: (bool isFocused) {
              addListenerForTextInput(isFocused);
            },
            textInputType: TextInputType.numberWithOptions(),
            onSubmitted: (String value) {
              submitPhoneNumber();
            },
            maxLength: 10,
            hintText: "9810010000",
            controller: _phoneController,
          ),
        ),
        shouldShowUpperSection
            ? Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 32.0),
                  child: InkWell(
                    onTap: () {
                      Fluttertoast.showToast(msg: "You pressed here");
                    },
                    child: Text(
                      "Or connect with social media",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18.0, color: Colors.lightBlue),
                    ),
                  ),
                ),
              )
            : Container()
      ],
    );
  }

  Widget _buildBackArrow(BuildContext context) {
    return shouldShowUpperSection
        ? Container()
        : Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              IconButton(
                onPressed: () {
                  this.setState(() {
                    shouldShowUpperSection = true;
                    shouldHideKeyboard = true;
                  });
                },
                icon: Icon(Icons.arrow_back),
              ),
            ],
          );
  }

  _buildGotoNextScreenButton(BuildContext context) {
    return shouldShowUpperSection
        ? Container()
        : Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Flexible(
                  flex: 4,
                  child: Text(
                      "By continuing you may recieve an SMS for verification. Message and data rates may apply"),
                ),
                Flexible(
                  flex: 3,
                  child: AnimatingRotatingArc(
                    child: FloatingActionButton(
                      onPressed: () {
                        submitPhoneNumber();
                      },
                      backgroundColor: Colors.black,
                      child: Icon(
                        Icons.arrow_forward_ios,
                        size: 32.0,
                      ),
                    ),
                    key: _arcKey,
                  ),
                ),
              ],
            ),
          );
  }

  void submitPhoneNumber() {
    if (validatePhone()) {
      _arcKey.currentState.toggleAnimation(true);
      Future.delayed(Duration(seconds: 3), () {
        _arcKey.currentState.toggleAnimation(false);
        _sendCodeToPhoneNumber("+977" + _phoneController.text);
      });
    } else {
      Fluttertoast.showToast(msg: "Invalid phone number");
      _arcKey.currentState.toggleAnimation(false);
    }
  }

  bool validatePhone() {
    return _phoneController.text.length > 8;
  }

  void addListenerForTextInput(bool isFocused) {
    if (isFocused) {
      this.setState(() {
        shouldShowUpperSection = false;
        shouldHideKeyboard = false;
      });
    }
  }
}

class _UpperSection extends StatelessWidget {
  const _UpperSection({
    Key key,
    @required this.shouldShowThisSection,
  }) : super(key: key);

  final bool shouldShowThisSection;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return AnimatedContainer(
      duration: Duration(milliseconds: 500),
      height: shouldShowThisSection ? size.height * .6 : 0,
      width: shouldShowThisSection ? size.width : 0,
      color: shouldShowThisSection ? Colors.green[200] : Colors.lightBlue,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(4.0),
            color: Colors.white,
            width: size.height / 6,
            height: size.height / 6,
            child: Center(
                child: Text(
              "Garib ko uber",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24.0),
            )),
          )
        ],
      ),
    );
  }
}
