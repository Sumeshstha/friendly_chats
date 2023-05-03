import 'package:cloud_firestore/cloud_firestore.dart';
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
    "chats": []
  });
}

Future getUserData(String email)async {
  QuerySnapshot snapshot = await userCollection.where('email', isEqualTo: email).get();
  return snapshot;
}


Future getUserChats() async {
  return await userCollection.doc(uid).snapshots();
}

Future createChatWithFriend(String uid,String userName ) async {
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
    "chatId": chatDocumentReference .id,
    "members": FieldValue.arrayUnion(["${uid}_$userName"])
  }); 

  DocumentReference userDocumentReference = await userCollection.doc(uid);
  return await userDocumentReference.update({"chats": FieldValue.arrayUnion([chatDocumentReference.id])  }
);
}

  Future getChat(String chatId) async {
    return chatCollection.doc(chatId).collection("Messages").orderBy("time").snapshots();
  }


}