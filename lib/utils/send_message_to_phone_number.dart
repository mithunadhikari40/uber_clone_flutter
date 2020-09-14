import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

class SendMessageToPhoneNumber {
  //sends the code to the specified number
  Future<String> sendCodeToPhoneNumber(String phone) async {
    print("The phone number is $phone");
    String _verificationId;
    try {
      final PhoneVerificationCompleted phoneVerificationCompleted =
          (AuthCredential credential) {
        print(
            'Inside _sendCodeToPhoneNumber: signInWithPhoneNumber auto succeeded: $credential');
      };

      final PhoneVerificationFailed verificationFailed =
          (AuthException exception) {
        print(
            'Phone number verification failed. Code: ${exception.code}. Message: ${exception.message}');
      };

      final PhoneCodeSent codeSent =
          (String verificationIdentity, [int forceSendingToken]) {
        _verificationId = verificationIdentity;
        print("Code is sent to $phone");
      };

      final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
          (String verificationIdentity) {
        _verificationId = verificationIdentity;
        print("Time out exception occured");
      };

      await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: phone,
          timeout: Duration(seconds: 10),
          verificationCompleted: phoneVerificationCompleted,
          verificationFailed: verificationFailed,
          codeSent: codeSent,
          codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);

      return _verificationId;
    } on Exception catch (e) {
      print("The exception occured is $e");
      return null;
    }
  }
}
