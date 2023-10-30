import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobile_otp_firebase/home_page.dart';


class LoginPage extends StatefulWidget {
  LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController userController = TextEditingController();

  TextEditingController codeController = TextEditingController();
  String verifId = '';
  bool isSent = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My App'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: userController,
                decoration: const InputDecoration(
                  labelText: 'Enter mobile number',
                ),
              ),
            ),
            if (isSent)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: codeController,
                  decoration: const InputDecoration(
                    labelText: 'Enter code ',
                  ),
                ),
              ),
            ElevatedButton(
              onPressed: () {
                isSent
                    ? verifyUser()
                    : registerUser(userController.text, context);
              },
              child: Text(isSent ? 'Verify' : 'Send OTP'),
            ),
          ],
        ),
      ),
    );
  }

  Future registerUser(String mobile, BuildContext context) async {
    FirebaseAuth _auth = FirebaseAuth.instance;
    _auth.verifyPhoneNumber(
        phoneNumber: mobile,
        timeout: Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential authCredential) {
          log('from verificationCompleted');
          _auth
              .signInWithCredential(authCredential)
              .then((UserCredential result) {
            log('from verificationCompleted done');
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        HomeScreen(result.user as UserCredential)));
          }).catchError((e) {
            log('from verificationCompleted error');
            print(e);
          });
        },
        verificationFailed: (FirebaseAuthException e) {
          log('from verificationFailed');
          if (e.code == 'invalid-phone-number') {
            print('The provided phone number is not valid.');
          }
        },
        codeSent: (String verificationId, int? resendToken) async {
          log('from codeSent $verificationId');
          isSent = true;
          verifId = verificationId;
          setState(() {});
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          log('from codeAutoRetrievalTimeout $verificationId');
          // Auto-resolution timed out...
        });
  }

  verifyUser() async {
    FirebaseAuth _auth = FirebaseAuth.instance;
    // Update the UI - wait for the user to enter the SMS code
    String smsCode = codeController.text.trim();

    // Create a PhoneAuthCredential with the code
    PhoneAuthCredential credential =
    PhoneAuthProvider.credential(verificationId: verifId, smsCode: smsCode);

    // Sign the user in (or link) with the credential
    await _auth.signInWithCredential(credential).then((UserCredential result) {
      log('from verificationCompleted done');
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => HomeScreen(result.user as UserCredential)));
    }).catchError((e) {
      log('from verifyUser error');
      print(e);
    });
    ;
  }
}
