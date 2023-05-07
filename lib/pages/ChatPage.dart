import 'package:flutter/material.dart';
import 'package:friendly_chat/pages/ProfilePage.dart';

import '../Components/my_textfield.dart';

class ChatPage extends StatefulWidget {
  /*final String chatName;
  final String chatId;
  /*const ChatPage({super.key, required this.chatName, required this.chatId});*/*/

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.orange,
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.linear_scale_outlined),
              onPressed:
                  () {}, //() => ProfilePage(userEmail: userEmail, userName: userName), milau hai//
            ),
          ],
          title: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: const [Icon(Icons.person), Text("USER_NAME")],
            ),
          )),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Type your message',
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16.0),
                  suffixIcon: IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.send),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
