import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DatabaseService{
final String? uid;
DatabaseService({this.uid});
final CollectionReference userCollection= FirebaseFirestore.instance.collection("User");
final CollectionReference chatCollection = FirebaseFirestore.instance.collection("Friends");

Future updateUserData(String userName, String email, String password) async{
  return await userCollection.doc(uid).set({
    "userName": userName,
    "email": email,
    "password": password,
    "chats": [],
    "uid": uid
  });
}

Future getUserData(String email)async {
 try {
  QuerySnapshot snapshot  = await userCollection.where('email' , isEqualTo: email).get();
  return snapshot;
 }
 on FirebaseException catch(e){
  return e;
 }
}
Future getUserChats() async {
  return await userCollection.doc(uid).snapshots();
}

Future createChatWithFriend(String uid,String userName, String uid2, String userName2 ) async {
  DocumentReference chatDocumentReference = await chatCollection.add(
    {
      "chatName": '',
      "recentMessageSender": '',
      "recentMessage": '',
      "members": [],
      "chatIcon": '',
      "chatId": ''

    }
  );
  await chatDocumentReference .update({
    "chatName": "${userName}_${userName2}",
    "chatId": chatDocumentReference .id,
    "members": FieldValue.arrayUnion(["${uid}_$userName" , "${uid2}_$userName2"])
  }); 

  DocumentReference userDocumentReference = await userCollection.doc(uid);
  DocumentReference user2DocumentReference = await userCollection.doc(uid2);
  await user2DocumentReference.update({"chats": FieldValue.arrayUnion(["${chatDocumentReference.id}_$userName"])});
  return await userDocumentReference.update({"chats": FieldValue.arrayUnion(["${chatDocumentReference.id}_$userName2"])  }
  
);
}
  Future check(String username1, String username2)async {
    QuerySnapshot snapshot = await chatCollection.where("chatName", whereIn: ["${username1}_${username2}", "${username2}_${username1}"]).get();
    return snapshot;
  }

  Future changePassword (String uid, String newPassword) async {
    DocumentReference userDocumentReference =  userCollection.doc(uid);
    await userDocumentReference.update({"password": newPassword});
  }


  Future getChatMessages(String chatId) async {
    return chatCollection.doc(chatId).collection("Messages").orderBy("time").snapshots();
  }


}