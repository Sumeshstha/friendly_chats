import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DatabaseService{
final String? uid;
DatabaseService({this.uid});
final CollectionReference userCollection= FirebaseFirestore.instance.collection("User");
final CollectionReference chatCollection = FirebaseFirestore.instance.collection("Friends");

Future createUserData(String userName, String email, String password) async{
  return await userCollection.doc(uid).set({
    "userName": userName,
    'userNameLowerCase': userName.toLowerCase(),
    "email": email,
    "password": password,
    "chats": [],
    "uid": uid, 
    "bio": '', 
    "profilePictureUrl": ''
  });
}
Future uploadImageandProfilePicture(String imageurl, String bio) async {
  DocumentReference userDocumentReference = userCollection.doc(uid);
  userDocumentReference.update({
    "bio": bio, 
    "profilePictureUrl": imageurl,
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
    "chatName": "${uid}_${uid2}",
    "chatId": chatDocumentReference .id,
    "members": FieldValue.arrayUnion(["${uid}_$userName" , "${uid2}_$userName2"])
  }); 

  DocumentReference userDocumentReference = await userCollection.doc(uid);
  DocumentReference user2DocumentReference = await userCollection.doc(uid2);
  await user2DocumentReference.update({"chats": FieldValue.arrayUnion(["${chatDocumentReference.id}_$userName"])});
  return await userDocumentReference.update({"chats": FieldValue.arrayUnion(["${chatDocumentReference.id}_$userName2"])  }
  
);
}
  Future searchByUsername (String userName) async {
    try{
      QuerySnapshot snapshot = await userCollection.where("userNameLowerCase", isEqualTo: userName.toLowerCase()).get();
      return snapshot;
    }
    on FirebaseException catch(e) {
      return e.message;
    }
  }

  Future check(String uid, String uid2)async {
    QuerySnapshot snapshot = await chatCollection.where("chatName", whereIn: ["${uid}_${uid2}", "${uid2}_${uid}"]).get();
    return snapshot;
  }

  Future changePassword (String uid, String newPassword) async {
    DocumentReference userDocumentReference =  userCollection.doc(uid);
    await userDocumentReference.update({"password": newPassword});
  }
  
  // Future changeUserName(String uid, String userName)async {
  //   try{
  //     DocumentReference userDocumentReference = userCollection.doc(uid);
  //     await userDocumentReference.update({'userName': userName});
  //     return null;
  //   }
  //   on FirebaseException catch(e){
  //     return e.message;
  //   }
    
  // }


  Future getChatMessages(String chatId) async {
    return chatCollection.doc(chatId).collection("Messages").orderBy("messageTime").snapshots();
  }

  Future sendMessage(String chatId, Map<String , dynamic>messageMap)async {
    await DatabaseService().chatCollection.doc(chatId).collection("Messages").add(messageMap); 
    await DatabaseService().chatCollection.doc(chatId).update({
      "recentMessage": messageMap['message'],
      "recentMessageSender": messageMap['messageSender']
    });

  }


}