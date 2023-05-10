// ignore: depend_on_referenced_packages
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:friendly_chat/Widgets/widgets.dart';
import 'package:friendly_chat/helper/helper_function.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:friendly_chat/pages/ChatPage.dart';
import 'package:friendly_chat/pages/Search_page2.dart';
import 'package:friendly_chat/pages/StartPage.dart';
import 'package:friendly_chat/pages/picprofile.dart';
import 'package:friendly_chat/services/database_service.dart';
import '../services/auth_service.dart';
import 'login.dart';
// ignore: duplicate_import
import 'ProfilePage.dart';
import 'dart:io';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(brightness: Brightness.light),
      darkTheme: ThemeData(brightness: Brightness.dark),
      themeMode: ThemeMode.system,
    );
  }

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? userEmail;
  String? userName;
  Stream? streamSnapshot;
  var chats = [];
  String? chatName;
  String? chatId;
  AuthService authService = AuthService();
  get centerTitle => null;
  @override
  void initState() {
    getUserData();
    super.initState();
  }

  getUserData() async {
    await HelperFunction.getUserEmail().then((value) {
      userEmail = value;
    });
    await DatabaseService(uid:FirebaseAuth.instance.currentUser!.uid).getUserData(userEmail!).then((value){
      QuerySnapshot snap = value;
      setState(() {
        userName  = snap.docs[0]['userName'];
      });
    });
    await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .getUserChats()
        .then((value) {
      setState(() {
        streamSnapshot = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              onPressed: () {
                goto(
                    context,
                    SearchPage2(
                      currentUserEmail: userEmail!,
                      currentUserName: userName!,
                    ));
              },
              icon: const Icon(
                Icons.search,
              ),
            )
          ],
          centerTitle: false,
          backgroundColor: Colors.orange,
          title: const Text("Messages",
              style: TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              )),
        ),
        drawer: Drawer(
          child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 50),
              children: <Widget>[
                const Icon(
                  Icons.account_circle,
                  size: 150,
                  color: Color.fromARGB(255, 208, 123, 223),
                ),
                const SizedBox(
                  height: 15,
                ),
                Text(
                  "$userName",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 35,
                ),
                const Divider(
                  height: 2,
                ),
                ListTile(
                  onTap:(){
                    goto(context, CompleteProfile(uid: FirebaseAuth.instance.currentUser!.uid));
                  },
                  // onTap: () => Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //         builder: (context) => ProfilePage(
                  //               userEmail: userEmail!,
                  //               userName: userName!,
                  //               userId: FirebaseAuth.instance.currentUser!.uid,
                  //             ))),
                  selected: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  leading: const Icon(
                    Icons.person,
                    color: Colors.blue,
                  ),
                  title: const Text(
                    "Profile and Settings",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                ListTile(
                  onTap: () {
                    logout();
                  },
                  selected: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  leading: const Icon(
                    Icons.logout,
                    color: Colors.red,
                  ),
                  title: const Text(
                    "Logout",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ]),
        ),
        body: chatList());
  }

  chatList() {
    return StreamBuilder(
        stream: streamSnapshot,
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data['chats'] != null) {
              if (snapshot.data['chats'].length != 0) {
                chats = snapshot.data["chats"];
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: ListView.builder(
                      itemCount: chats.length,
                      itemBuilder: (context, index) {
                        chatName =
                            getChatName(chats[chats.length - (index + 1)]);
                        chatId = getChatId(chats[chats.length - (index + 1)]);
                        if (chatName != null) {
                          return ListTile(
                              leading: Icon(Icons.account_circle, size: 40),
                              title: Text(chatName!),
                              onTap:() {
                                goto(context,ChatPage(currentUserName: userName!, chatId: getChatId(chats[chats.length - (index + 1)]), friendName:getChatName(chats[chats.length - (index + 1)])));
                              },);
                        } else {
                          return Center(child: Text("Currenty empty"));
                        }
                      }),
                );
              } else {
                return  Center(
                    child: Text(" You have no conversations", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color:Colors.grey.shade400)));
              }
            } else {
              return const Center(child: Text("Failed Null check"));
            }
          } else {
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            );
          }
        });
  }

  getChatName(String chatIdAndName) {
    String chatname = chatIdAndName.substring(chatIdAndName.indexOf("_") + 1);
    return chatname;
  }

  getChatId(String chatIdAndName) {
    return chatIdAndName.substring(0, chatIdAndName.indexOf("_"));
  }

  logout() {
    setState(() {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Are you sure?"),
              actions: [
                TextButton(
                    onPressed: () {
                      authService
                          .logout()
                          .whenComplete(() => goto(context, LoginPage()));
                    },
                    child: const Text("Yes")),
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("No"))
              ],
            );
          });
    });
  }
}
