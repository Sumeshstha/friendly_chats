import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  final String chatName;
  final String chatId; 
  const ChatPage({super.key, required this.chatName, required this.chatId});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("")),
    );
  }
}