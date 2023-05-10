import 'package:flutter/material.dart';
import 'package:friendly_chat/pages/Message_tile.dart';
import 'package:friendly_chat/pages/ProfilePage.dart';
import 'package:friendly_chat/services/database_service.dart';

import '../Components/my_textfield.dart';


class ChatPage extends StatefulWidget {
  final String currentUserName;
  final String chatId;
  final String friendName;
  
  const ChatPage({super.key, required this.currentUserName, required this.chatId, required this.friendName});



  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  Stream? messages;
  final currentMessage = TextEditingController();
  @override
  void initState() {
    getStream();
    super.initState();
  }
  getStream()async {
    await DatabaseService().getChatMessages(widget.chatId).then((value){
      setState(() {
        messages= value;
      });
    });
  }
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
              children:  [Icon(Icons.person), Text("${widget.friendName}")],
            ),
          )),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: currentMessage,
                decoration: InputDecoration(
                  hintText: 'Type your message',
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16.0),
                  suffixIcon: IconButton(
                    color: Theme.of(context).primaryColor,
                    onPressed: () {
                      sendMessages();
                    },
                    icon: const Icon(Icons.send),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: getMessages() ,
    );
  }
  getMessages()  {
    return StreamBuilder(
      stream: messages,
      builder: ((context, AsyncSnapshot snapshot) {
        if(snapshot.hasData){
          return ListView.builder(
            itemCount: snapshot.data.docs.length,
            itemBuilder:((context, index){
              return MessageTile(
                message: snapshot.data.docs[index]['message'],
                sender: snapshot.data.docs[index]['messageSender'], 
                sentByMe: widget.currentUserName ==snapshot.data.docs[index]['messageSender']);
            })
          );
        }
        else {
          return Container();
        }
      })
    ); 
  }
  sendMessages() {
    if(currentMessage.text.isNotEmpty){
      Map<String , dynamic> messageMap = {
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
