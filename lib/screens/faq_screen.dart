import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
// import 'package:webview_flutter/webview_flutter.dart';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

class FAQScreen extends StatefulWidget {
  const FAQScreen({Key? key}) : super(key: key);

  @override
  State<FAQScreen> createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  List<String> notionLinks = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchNotionPages();
  }

  Future<void> fetchNotionPages() async {
    try {
      final token = await FirebaseAuth.instance.currentUser?.getIdToken();
      final url = Uri.parse(
        'https://us-central1-tofu-bot-7de67.cloudfunctions.net/getNotionPageList',
      );

      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          notionLinks = List<String>.from(data);
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed: ${response.statusCode} - ${response.body}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  void openUrl(String url) async {
    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not launch $url')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FAQs')),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : ListView.builder(
                itemCount: notionLinks.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('Page ${index + 1}'),
                    subtitle: Text(notionLinks[index]),
                    onTap: () => openUrl(notionLinks[index]),
                  );
                },
              ),
    );
  }
}
