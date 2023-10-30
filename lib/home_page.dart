import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  UserCredential user;
  HomeScreen(this.user, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(user.user!.phoneNumber.toString()),
    );
  }
}
