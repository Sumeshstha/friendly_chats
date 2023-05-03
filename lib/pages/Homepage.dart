// ignore: depend_on_referenced_packages
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:friendly_chat/Widgets/widgets.dart';
import 'package:friendly_chat/helper/helper_function.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:friendly_chat/services/database_service.dart';
import '../services/auth_service.dart';
import 'login.dart';
import 'Search_page.dart';
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
  Stream? chat;
  AuthService authService = AuthService();
  get centerTitle => null;
  @override
  void initState() {
    getUserData();
    super.initState();
  }

  getUserData() async {
    await HelperFunction.getUserEmail().then((value) {
      setState(() {
        userEmail = value;
      });
    });
    await HelperFunction.getUsername().then((val) {
      setState(() {
        userName = val;
      });
  });
    await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid).getUserChats().then((value) {
      setState(() {
        chat = value;
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
                goto(context, SearchPage());
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
                ), Text(
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
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ProfilePage())),
                  selected: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  leading: const Icon(Icons.person),
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
                  leading: const Icon(Icons.logout),
                  title: const Text(
                    "Logout",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ]),
        ),
      body:chatList()
      );
  }
  chatList(){
    return StreamBuilder(
      stream: chat,
      builder:(context,AsyncSnapshot snapshot){
        if(snapshot.hasData){
          if(snapshot.data['chats'] != null){
            if(snapshot.data['chats'].length != 0){
              return ListView.builder(
                itemCount: snapshot.data['chats'].length,
                itemBuilder: (context, index){
                return ListTile(
                  title: Text("Hello")
                );
              });
            }
            else {
              return const Center(child: Text("Failed Not equal to zero check   "));
            }
          }
          else {
            return const Center(child: Text("Failed Null check"));
          }
        }
        else {
          return  Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).primaryColor, 
              
          ),);
        }
            
          });
      
  }
  logout(){
    setState(() {
      showDialog(context: context, builder: (context){
        return  AlertDialog(
          title:  Text("Are you sure?"),
          actions: [
            TextButton(
              onPressed: (){
                 authService.logout().whenComplete(() => goto(context, LoginPage()));
            }, child: const Text("Yes")),
            TextButton(onPressed: (){
              Navigator.of(context).pop();
            }, child: const Text("No"))
          ],
        );
      }
    );
  });
  }
}