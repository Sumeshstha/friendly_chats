// ignore: file_names
import 'package:flutter/material.dart';
import 'package:friendly_chat/Widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:friendly_chat/services/database_service.dart';

class SearchPage extends StatefulWidget {
  final String currentUserName;
  final String currentUserEmail;
  const SearchPage({super.key, required this.currentUserEmail, required this.currentUserName});

  @override
  State<SearchPage> createState(){
    return _SearchPageState();
  }
}

class _SearchPageState extends State<SearchPage> {
  final formkey = GlobalKey<FormState>();
  String? searched;
  bool _isLoading = false;
  String? username;
  String? uidSearched;
  QuerySnapshot? snapshot;
  bool _friendAdded = true;
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
                    width: 400,
                    child: TextFormField(
                      decoration: InputDecoration(
                        suffixIcon:IconButton(
                            onPressed: () {
                              search();
                            },
                            icon: const Icon(Icons.search)),
                        hintText: "Email",
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
                        return RegExp(
                                    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                .hasMatch(searched!)
                            ? null
                            : "Please enter valid email";
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
    if (formkey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      await DatabaseService().getUserData(searched!).then((value) {
           snapshot = value;
        if(snapshot!.docs.isNotEmpty){
          setState(() {
          username = snapshot!.docs[0]["userName"];
          uidSearched = snapshot!.docs[0]["uid"];
          _isLoading = false;
        });
        }
        else {
          showSnackBar(context, "User doesn't exit", Colors.red);
          setState(() {
            _isLoading = false;
          });
        }
        
      });
    }
  }

  searchPage() {
    if (username != null) {
      return StatefulBuilder(builder: ((context, setState) {
        return ListTile(
          leading: Icon(Icons.account_circle),
          title: Text("$username"),
          trailing: IconButton(
            onPressed: () async{
              setState(() {
                _friendAdded = true;
              });
              await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid).createChatWithFriend(FirebaseAuth.instance.currentUser!.uid, widget.currentUserName , uidSearched!, username!);
              

            },
            icon: Icon(Icons.add),)
        );
      }));
    } else {
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
}
