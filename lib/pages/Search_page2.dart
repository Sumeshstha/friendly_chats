

import 'package:flutter/material.dart';
import 'package:friendly_chat/Widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:friendly_chat/pages/Homepage.dart';
import 'package:friendly_chat/pages/ProfilePage.dart';
import 'package:friendly_chat/services/database_service.dart';

class SearchPage2 extends StatefulWidget {
  final String currentUserName;
  final String currentUserEmail;
  const SearchPage2({super.key, required this.currentUserEmail, required this.currentUserName});

  @override
  State<SearchPage2> createState(){
    return _SearchPage2State();
  }
}

class _SearchPage2State extends State<SearchPage2> {
  final formkey = GlobalKey<FormState>();
  String? searched;
  bool _isLoading = false;
  String? username;
  String? uidSearched;
  QuerySnapshot? snapshot;
  bool _friendAdded = true;
  List<DocumentSnapshot>? list ;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.orange,
          actions: [
            Form(
              key: formkey,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                child: Container(
                    width: 300,
                    child: TextFormField(
                      decoration: InputDecoration(
                        suffixIcon:IconButton(
                            onPressed: () {
                              search();
                            },
                            icon: const Icon(Icons.search)),
                        hintText: "Username",
                        hintStyle: TextStyle(color: Colors.grey.shade700),
                        filled: true,
                        fillColor: Colors.grey.shade200,
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(
                                color: Colors.white, width: 1)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(
                                color: Colors.grey.shade400, width: 1)),
                        errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide:
                                const BorderSide(color: Colors.red, width: 1)),
                      ),
                      onChanged: (value) {
                        searched = value;
                      },
                      validator: (searched) {
                        return searched!.isNotEmpty? null
                            : "User name cannot be empty";
                      },
                    )),
              ),
            )
          ],
        ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor))
            : searchPage());
  }

  search() async {
    if(formkey.currentState!.validate()){
      setState(() {
        _isLoading = true;
      });
      await DatabaseService().searchByUsername(searched!).then((value) {
        snapshot = value;
        if(snapshot!.docs.isNotEmpty){
          setState(() {
            _isLoading = false;
            username = snapshot!.docs[0]['userName'];
          });
        }
        else {
          setState(() {
            _isLoading = false;
          });
          showSnackBar(context, "User doesn't exists", Colors.red);
        }
      },);
    }
  }

  searchPage() {
    if(username != null){
      return StatefulBuilder(builder: ((context, setState){
        return ListView.builder(
          itemCount: snapshot!.docs.length,
          itemBuilder: (context, index){
          return ListTile(
            leading: Icon(Icons.account_circle, size: 40,),
            title: Text('${snapshot!.docs[index]['userName']}'),
            subtitle: Text("${snapshot!.docs[index]["email"]}"),
            trailing: Container( 
              height:30, 
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor:  Colors.green),
                onPressed: () {
                  createChat(snapshot!.docs[index]['userName'], snapshot!.docs[index]['uid']);
                },
                child: const Text("Add Friend", style: TextStyle(color: Color.fromARGB(255, 249, 248, 248), ))
                ),
            )
          );
        });
      }));
          
    }
    else {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          Icon(Icons.search, size: 100, color: Colors.grey.shade500), 
          Text("Search Page", style: TextStyle(color: Colors.grey.shade400,fontWeight: FontWeight.bold, fontSize:30))
        ],),
      );
    

    }
  }
  createChat(String userName2, String uid2) async {
    setState(() {
      _isLoading = true;
    });
    await DatabaseService().check(FirebaseAuth.instance.currentUser!.uid, uid2).then((value)async{
      QuerySnapshot snap = value;
      if(snap.size ==0){
        await DatabaseService().createChatWithFriend(FirebaseAuth.instance.currentUser!.uid, widget.currentUserName, uid2, userName2).then((value) {
          showSnackBar(context, "Chat created successfully", Colors.green);
          goto(context, HomePage());
        });
      }
      else{
        showSnackBar(context, "Chat already exists",Colors.red );
        setState(() {
          _isLoading = false;
        });
      }
    });
  }
}