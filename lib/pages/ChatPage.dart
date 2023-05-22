import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:friendly_chat/pages/Message_tile.dart';
import 'package:friendly_chat/pages/ProfilePage.dart';
import 'package:friendly_chat/services/database_service.dart';

import '../Components/my_textfield.dart';

class ChatPage extends StatefulWidget {
  final String currentUserName;
  final String chatId;
  final String friendName;
  const ChatPage(
      {Key? key,
      required this.currentUserName,
      required this.chatId,
      required this.friendName});
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  Stream? messages;
  final currentMessage = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    getStream();
    super.initState();
  }

  getStream() async {
    await DatabaseService().getChatMessages(widget.chatId).then((value) {
      setState(() {
        messages = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(milliseconds: 1200), () {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.linear_scale_outlined),
            onPressed: () {},
          ),
        ],
        title: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [Text("${widget.friendName}")],
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: getMessages(),
          ),
          Container(
            alignment: Alignment.bottomCenter,
            child: TextField(
              onSubmitted: (value) {
                _focusNode.requestFocus();
                sendMessages();
                Future.delayed(const Duration(milliseconds: 500), () {
                  _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 5),
                      curve: Curves.linear);
                });
              },
              focusNode: _focusNode,
              controller: currentMessage,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey.shade300,
                hintText: 'Type your message',
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16.0),
                suffixIcon: IconButton(
                  color: Theme.of(context).primaryColor,
                  onPressed: () {
                    sendMessages();
                    Future.delayed(const Duration(milliseconds: 500), () {
                      _scrollController.animateTo(
                          _scrollController.position.maxScrollExtent,
                          duration: const Duration(milliseconds: 5),
                          curve: Curves.linear);
                    });
                  },
                  icon: const Icon(Icons.send),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget getMessages() {
    return StreamBuilder(
      stream: messages,
      builder: ((context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
              scrollDirection: Axis.vertical,
              controller: _scrollController,
              itemCount: snapshot.data.docs.length,
              itemBuilder: ((context, index) {
                return MessageTile(
                    message: snapshot.data.docs[index]['message'],
                    sender: snapshot.data.docs[index]['messageSender'],
                    sentByMe: widget.currentUserName ==
                        snapshot.data.docs[index]['messageSender']);
              }));
        } else {
          return Container();
        }
      }),
    );
  }

  void sendMessages() {
    if (currentMessage.text.isNotEmpty) {
      Map<String, dynamic> messageMap = {
        "message": currentMessage.text,
        "messageSender": widget.currentUserName,
        "messageTime": DateTime.now().millisecondsSinceEpoch
      };
      DatabaseService().sendMessage(widget.chatId, messageMap);
      setState(() {
        currentMessage.clear();
      });
    }
  }
}
