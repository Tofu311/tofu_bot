import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/intro_screen.dart';

Future<void> navigatePostLogin(BuildContext context) async {
  final user = FirebaseAuth.instance.currentUser;
  final doc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();

  if (doc.exists && (doc.data()?['fullName'] ?? '').toString().isNotEmpty) {
    // Go to chatbot/home screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const Scaffold(
        body: Center(child: Text('Chatbot/Home Screen Placeholder')),
      )),
    );
  } else {
    // Go to name form screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const IntroScreen()),
    );
  }
}
