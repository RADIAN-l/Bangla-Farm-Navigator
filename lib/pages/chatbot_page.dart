import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatbotPage extends StatefulWidget {
  @override
  _ChatbotPageState createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _c = TextEditingController();
  String reply = "";

  // Demo GET echo API (placeholder). You can switch to real AI later.
  Future<void> getReply(String q) async {
    setState(() {
      reply = "Loading...";
    });

    try {
      final url = Uri.parse("https://jsonplaceholder.typicode.com/posts/1");
      final resp = await http.get(url);
      if (resp.statusCode == 200) {
        final obj = json.decode(resp.body);
        setState(() {
          reply = "Demo reply: ${obj['title']}";
        });
      } else {
        setState(() => reply = "No reply (status ${resp.statusCode})");
      }
    } catch (e) {
      setState(() => reply = "Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chatbot (demo)"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              controller: _c,
              decoration: InputDecoration(
                hintText: "Ask your question...",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 8),
            ElevatedButton(onPressed: () => getReply(_c.text), child: Text("Send")),
            SizedBox(height: 12),
            Text(reply),
          ],
        ),
      ),
    );
  }
}
