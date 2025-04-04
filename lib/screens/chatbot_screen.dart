import 'package:flutter/material.dart';
import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:flutter_ai_toolkit/flutter_ai_toolkit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  late final _provider = VertexProvider(
    model: FirebaseVertexAI.instance.generativeModel(
      model: 'gemini-2.0-flash',
      systemInstruction: Content.system(
        'You are a friendly and patient tech assistant. Your job is to help users who are unfamiliar with technology. Always explain things clearly, step by step, using simple and non-technical language. Avoid jargon, and offer examples where helpful. Be supportive and ensure the user feels confident after each interaction.',
      ),
    ),
  );

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _provider.addListener(_saveHistory);
    _loadHistory();
  }

  @override
  void dispose() {
    _provider.removeListener(_saveHistory);
    super.dispose();
  }

  Future<void> _loadHistory() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('chats')
            .orderBy('timestamp')
            .get();

    final history = <ChatMessage>[];

    for (final doc in snapshot.docs) {
      final data = doc.data();
      if (data.containsKey('json')) {
        history.add(
          ChatMessage.fromJson(Map<String, dynamic>.from(data['json'])),
        );
      }
    }

    _provider.history = history;
  }

  Future<void> _saveHistory() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final collection = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('chats');

    final history = _provider.history.toList();

    for (var i = 0; i < history.length; ++i) {
      final msg = history[i];
      final json = msg.toJson();

      await collection.add({'json': json, 'timestamp': Timestamp.now()});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tofu Chatbot")),
      body: LlmChatView(
        suggestions: [
          'How do I sign up for a GMail account?',
          'What is phishing?',
          'What is the difference between Wi-Fi and Ethernet?',
        ],
        provider: _provider,
      ),
    );
  }
}
