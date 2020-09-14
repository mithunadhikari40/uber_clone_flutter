import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uber_clone/screens/reusable/simple_auto_complete_text_view.dart';

class AuthSmsIntegration extends StatefulWidget {
  @override
  _AuthSmsIntegrationState createState() => _AuthSmsIntegrationState();
}

class _AuthSmsIntegrationState extends State<AuthSmsIntegration> {
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
      appBar: AppBar(
        title: Text("Sms verification mechanism"),
      ),
      body: Column(
        children: <Widget>[
          Container(
            child: SimpleAutoCompleteTextView(
              textInputType: TextInputType.numberWithOptions(),
              hintText: "1234567890",
              controller: _phoneController,
              onSubmitted: (String text) {
//                _phoneController.text = text;
              },
            ),
          ),
          Divider(),
          Container(
            child: SimpleAutoCompleteTextView(
              textInputType: TextInputType.number,
              hintText: "134",
              controller: _smsController,
              onSubmitted: (String text) {
//                _smsController.text = text;
              },
            ),
          ),
          Divider(),
          FlatButton(
            onPressed: () {
              _sendCodeToPhoneNumber(_phoneController.text);
            },
            child: Text("Send sms"),
          ),
          Divider(),
          FlatButton(
            onPressed: () {
              _signInWithPhoneNumber(_smsController.text);
            },
            child: Text("Confirm sms"),
          ),
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
}
