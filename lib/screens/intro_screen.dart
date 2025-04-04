import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({Key? key}) : super(key: key);

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final TextEditingController _nameController = TextEditingController();
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  void _submitName() async {
    final user = _auth.currentUser;
    if (user != null && _nameController.text.trim().isNotEmpty) {
      await _firestore.collection('users').doc(user.uid).update({
        'fullName': _nameController.text.trim(),
      });
      // Navigate to chatbot/home screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const Scaffold(
          body: Center(child: Text('Chatbot/Home Screen Placeholder')),
        )),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Enter Your Name")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: "Your full name",
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitName,
              child: const Text("Continue"),
            ),
          ],
        ),
      ),
    );
  }
}
