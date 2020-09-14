import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pin_view/pin_view.dart';
import 'package:uber_clone/intro/first_mobile_number_section.dart';
import 'package:uber_clone/intro/personal_information_section.dart';
import 'package:uber_clone/screens/reusable/animation/animating_rotating_arc.dart';
import 'package:uber_clone/utils/navigator.dart';

enum USER_VERIFICATION { UNDER_PROCESS, AUTHORIZED, UNAUTHORIZED }

class SmsCodeValidationSection extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;

  SmsCodeValidationSection({this.phoneNumber, this.verificationId});

  @override
  _SmsCodeValidationSectionState createState() =>
      _SmsCodeValidationSectionState();
}

class _SmsCodeValidationSectionState extends State<SmsCodeValidationSection> {
  GlobalKey<AnimatingRotatingArcState> _arcKey = GlobalKey();

  USER_VERIFICATION userVerified = USER_VERIFICATION.UNDER_PROCESS;

  Timer _timer;
  int resendCodeIn = 15;
  String verificationId;

  @override
  void initState() {
    super.initState();
    _countDownResendCodeSection();
    verificationId = widget.verificationId;
//    _sendCodeToPhoneNumber(widget.phoneNumber);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          ListView(
            children: <Widget>[
              _buildBackArrow(context),
              _buildDescriptionText(context),
              _buildSmsCodeEnteringSection(context),
              _buildCodeErrorSection(context),
            ],
          ),
          _buildLowerSection(context),
        ],
      ),
    );
  }

  _backButtonHandler(BuildContext context) {
    navigateWithAnimationDestroyingBackStack(
        FirstMobileNumberSection(), context);
  }

  _buildBackArrow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        IconButton(
          onPressed: () {
            _backButtonHandler(context);
          },
          icon: Icon(Icons.arrow_back),
        ),
      ],
    );
  }

  _buildSmsCodeEnteringSection(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: PinView(
          count: 6,
//        dashPositions: [3],

          // this makes fields not focusable
//        sms: smsListener // listener we created
          submit: (String pin) {
            _signInWithPhoneNumber(pin, context);

            print("The pin entered by the user is $pin");
          }),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }

  _buildDescriptionText(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: RichText(
        text: TextSpan(children: [
          TextSpan(
              text:
                  "Enter the 6-digit code sent to you at ${widget.phoneNumber}. ",
              style: TextStyle(color: Colors.black, fontSize: 20.0)),
          TextSpan(
              text: resendCodeIn <= 0
                  ? "Did you enter the correct phone number ? "
                  : "",
              style: TextStyle(color: Colors.yellow[800], fontSize: 20.0))
        ]),
      ),
    );
  }

  _buildLowerSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: InkWell(
                    onTap: () {
                      if (resendCodeIn > 1)
                        return;
                      else {
                        _confirmMobileNumber(context);
                      }
                    },
                    child: Text(
                      resendCodeIn > 1
                          ? "Resend code in 00: $resendCodeIn"
                          : "I am having trouble",
                      style: TextStyle(color: Colors.blue, fontSize: 18.0),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: InkWell(
                    onTap: () {
                      navigateWithAnimationDestroyingBackStack(
                          FirstMobileNumberSection(), context);
                    },
                    child: Text(
                      "Edit my mobile number",
                      style: TextStyle(color: Colors.blue, fontSize: 18.0),
                    ),
                  ),
                )
              ],
            ),
            AnimatingRotatingArc(
              child: FloatingActionButton(
                onPressed: () {
                  navigateToInfoSection(context);
                },
                backgroundColor: Colors.black,
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: 32.0,
                ),
              ),
              key: _arcKey,
            ),
          ],
        ),
      ),
    );
  }

  void navigateToInfoSection(BuildContext context) {
    if (userVerified == USER_VERIFICATION.AUTHORIZED) {
      _arcKey.currentState.toggleAnimation(true);
      Future.delayed(Duration(seconds: 2), () {
        _arcKey.currentState.toggleAnimation(false);
        navigateWithAnimationWithBackStack(
            PersonalInformationSection(
                /* phoneNumber: widget.phoneNumber,
                verificationId: widget.verificationId*/
                ),
            context);
      });
    } else {
      _buildCodeErrorSection(context);
    }
  }

  //sends the code to the specified number
//  Future<void> _sendCodeToPhoneNumber(String phone) async {
//    final PhoneVerificationCompleted phoneVerificationCompleted =
//        (AuthCredential credential) {
//      setState(() {
//        print(
//            'Inside _sendCodeToPhoneNumber: signInWithPhoneNumber auto succeeded: $credential');
//      });
//    };
//
//    final PhoneVerificationFailed verificationFailed =
//        (AuthException exception) {
//      setState(() {
//        print(
//            'Phone number verification failed. Code: ${exception.code}. Message: ${exception.message}');
//      });
//    };
//
//    final PhoneCodeSent codeSent =
//        (String verificationId, [int forceSendingToken]) {
//      this.verificationId = verificationId;
//      print("Code is sent to ${phone}");
//    };
//
//    final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
//        (String verificationId) {
//      this.verificationId = verificationId;
//      print("Time out exception occured");
//    };
//
//    await FirebaseAuth.instance.verifyPhoneNumber(
//        phoneNumber: phone,
//        timeout: Duration(seconds: 5),
//        verificationCompleted: phoneVerificationCompleted,
//        verificationFailed: verificationFailed,
//        codeSent: codeSent,
//        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
//  }

  void _signInWithPhoneNumber(String smsCode, BuildContext context) async {
    try {
      AuthCredential _authCredentials = PhoneAuthProvider.getCredential(
          verificationId: widget.verificationId, smsCode: smsCode);
      AuthResult authResult =
          await FirebaseAuth.instance.signInWithCredential(_authCredentials);
      FirebaseUser user = authResult.user;
      FirebaseUser _currentUser = await FirebaseAuth.instance.currentUser();
      if (_currentUser.uid == user.uid) {
        this.setState(() {
          userVerified = USER_VERIFICATION.AUTHORIZED;
        });
        navigateToInfoSection(context);
      } else {
        this.setState(() {
          userVerified = USER_VERIFICATION.UNAUTHORIZED;
        });
        _buildCodeErrorSection(context);
        //todo navigate to the other screen after the user has been verified

        Fluttertoast.showToast(
            msg: "Could not verify with the given code sent to you");
      }
//      assert(user.uid == _currentUser.uid);
    } on Exception catch (e) {
      this.setState(() {
        userVerified = USER_VERIFICATION.UNAUTHORIZED;
        ;
      });
      Fluttertoast.showToast(msg: "Incorrect code entered");
      //todo implement the logic to handle the mismatched sms code
    }
  }

  void _countDownResendCodeSection() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (resendCodeIn < 1) {
          timer.cancel();
        } else {
          this.setState(() {
            resendCodeIn--;
          });
        }
      },
    );
  }

  Future<void> _sendCodeToPhoneNumber(BuildContext context) async {
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
        print("Code is sent to ${widget.phoneNumber}");
      };

      final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
          (String verificationId) {
        this.verificationId = verificationId;
        print("Time out exception occured");
      };

      await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: widget.phoneNumber,
          timeout: Duration(seconds: 5),
          verificationCompleted: phoneVerificationCompleted,
          verificationFailed: verificationFailed,
          codeSent: codeSent,
          codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);

      Future.delayed(Duration(seconds: 2), () {
        _arcKey.currentState.toggleAnimation(false);
        navigateWithAnimationWithBackStack(
            SmsCodeValidationSection(
                verificationId: verificationId,
                phoneNumber: widget.phoneNumber),
            context);
      });
    } on Exception catch (e) {
      _arcKey.currentState.toggleAnimation(false);

      Fluttertoast.showToast(
          msg: "There was some error on sending the message ${e}");
    }
  }

  void _confirmMobileNumber(BuildContext context) {
    showModalBottomSheet<void>(
        context: context,
        builder: (BuildContext ctx) {
          return Container(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Resend to ${widget.phoneNumber}",
                    style: TextStyle(
                      fontSize: 20.0,
                    ),
                    textAlign: TextAlign.start,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                  ),
                  Text("How would you like to receive the code? "),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                  ),
                  Container(
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: Colors.grey[200],
                            style: BorderStyle.solid,
                            width: 2.0)),
                    width: double.infinity,
                    child: RaisedButton(
                      color: Color.fromRGBO(255, 255, 255, 0.9),
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                      child: Text(
                        "RESEND CODE",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20.0,
                        ),
                      ),
                      onPressed: () {
                        _sendCodeToPhoneNumber(context);
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                  ),
                  Container(
                    width: double.infinity,
                    child: RaisedButton(
                      color: Colors.black,
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                      child: Text(
                        "CANCEL",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 20.0, color: Colors.white),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  _buildCodeErrorSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: userVerified == USER_VERIFICATION.AUTHORIZED
          ? Container()
          : Text(
              userVerified == USER_VERIFICATION.UNAUTHORIZED
                  ? "The SMS passcode you have entered in incorrect"
                  : "Please enter the sms code to proceed",
              style: TextStyle(color: Colors.red[400]),
            ),
    );
  }
}
