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
  String? _currentSessionId;
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _sessions = [];
  int _lastSavedMessageCount = 0;

  @override
  void initState() {
    super.initState();
    _provider.addListener(_saveHistory);
    _startNewSession(); // Always start a fresh session on app load
    _loadSessions();
  }

  @override
  void dispose() {
    _provider.removeListener(_saveHistory);
    super.dispose();
  }

  Future<void> _loadSessions() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final snapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('sessions')
        .orderBy('createdAt', descending: true)
        .get();

    setState(() {
      _sessions = snapshot.docs;
    });
  }

  Future<void> _startNewSession() async {
    final user = _auth.currentUser;
    if (user == null) return;

    // Before starting a new session, check if the current one is empty
    if (_currentSessionId != null) {
      final messagesSnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('sessions')
          .doc(_currentSessionId)
          .collection('messages')
          .limit(1)
          .get();

      if (messagesSnapshot.docs.isEmpty) {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('sessions')
            .doc(_currentSessionId)
            .delete();
      }
    }

    final newSessionRef = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('sessions')
        .add({
      'createdAt': Timestamp.now(),
      'title': 'New Chat ${DateTime.now().toLocal().toIso8601String()}'
    });

    _currentSessionId = newSessionRef.id;
    _lastSavedMessageCount = 0;

    setState(() {
      _provider.history = [];
      _loadSessions();
    });
  }

  Future<void> _loadSession(String sessionId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final snapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('sessions')
        .doc(sessionId)
        .collection('messages')
        .orderBy('timestamp')
        .get();

    final history = snapshot.docs.map((doc) {
      final data = doc.data();
      return ChatMessage.fromJson(Map<String, dynamic>.from(data['json']));
    }).toList();

    setState(() {
      _provider.history = history;
      _currentSessionId = sessionId;
      _lastSavedMessageCount = history.length;
    });
  }

  Future<void> _saveHistory() async {
    final user = _auth.currentUser;
    if (user == null || _currentSessionId == null) {
      print('No user or session ID.');
      return;
    }

    final messagesRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('sessions')
        .doc(_currentSessionId)
        .collection('messages');

    final historyList = _provider.history.toList();

    if (_lastSavedMessageCount >= historyList.length) return;

    final newMessages = historyList.sublist(_lastSavedMessageCount);

    for (final msg in newMessages) {
      await messagesRef.add({
        'json': msg.toJson(),
        'timestamp': Timestamp.now(),
      });
    }

    _lastSavedMessageCount = historyList.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tofu Chatbot"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _startNewSession,
            tooltip: 'Start New Chat Session',
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(child: Text("Chat Sessions")),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text("Start New Session"),
              onTap: () {
                Navigator.of(context).pop();
                _startNewSession();
              },
            ),
            const Divider(),
            ..._sessions.map((doc) => ListTile(
                  title: Text(doc.data()['title'] ?? 'Untitled Session'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _loadSession(doc.id);
                  },
                )),
          ],
        ),
      ),
      body: LlmChatView(
        suggestions: const [
          'How do I sign up for a GMail account?',
          'What is phishing?',
          'What is the difference between Wi-Fi and Ethernet?',
        ],
        provider: _provider,
      ),
    );
  }
} 