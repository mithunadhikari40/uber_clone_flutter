import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uber_clone/screens/reusable/simple_auto_complete_text_view.dart';

class SecondMobileNumberSection extends StatefulWidget {
  @override
  _SecondMobileNumberSectionState createState() =>
      _SecondMobileNumberSectionState();
}

class _SecondMobileNumberSectionState extends State<SecondMobileNumberSection> {
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _smsController = TextEditingController();
  String verificationId;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: <Widget>[
//          _buildUpperSection(context),
          _buildLowerSection(context)
        ],
      ),
    );
  }

  //sends the code to the specified number
  Future<void> _sendCodeToPhoneNumber(String phone) async {
    _phoneController.text = "+977$phone";

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
      print("Code is sent to ${_phoneController.text}");
    };

    final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {
      this.verificationId = verificationId;
      print("Time out exception occured");
    };

    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: _phoneController.text,
        timeout: Duration(seconds: 5),
        verificationCompleted: phoneVerificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
  }

  void _signInWithPhoneNumber(String smsCode) async {
    AuthCredential _authCredentials = PhoneAuthProvider.getCredential(
        verificationId: verificationId, smsCode: smsCode);
    AuthResult authResult =
    await FirebaseAuth.instance.signInWithCredential(_authCredentials);
    FirebaseUser user = authResult.user;
    FirebaseUser _currentUser = await FirebaseAuth.instance.currentUser();
    assert(user.uid == _currentUser.uid);

    print("sign in with the phone numeber is successful and the user is $user");
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _smsController.dispose();
    super.dispose();
  }

  Widget _buildUpperSection(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Container(
          height: size.height * .6,
          width: size.width,
          color: Colors.lightBlue,
        ),
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
    );
  }

  Widget _buildLowerSection(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Container(
          padding:
          EdgeInsets.only(top: 32.0, left: 12.0, right: 12.0, bottom: 8.0),
          child: Text(
            "Getting moving with garib ko uber",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(12.0),
              ),
              border: Border.all(color: Colors.grey[400])),
          padding: EdgeInsets.only(bottom: 20.0, top: 8.0),
          child: SimpleAutoCompleteTextView(
            textInputType: TextInputType.numberWithOptions(),
            maxLength: 10,
            hintText: "9810010000",
            controller: _smsController,
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 32.0),
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
        ),
      ],
    );
  }
}
