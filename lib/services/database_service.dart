import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DatabaseService {
  final String? uid;
  DatabaseService({this.uid});
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection("User");
  final CollectionReference chatCollection =
      FirebaseFirestore.instance.collection("Friends");

  Future createUserData(String userName, String email, String password) async {
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

  Future<void> uploadImageandProfilePicture(String imageurl, String bio) async {
    try {
      print('=== Updating Firestore ===');
      print('UID: $uid');
      print('Profile Picture URL: $imageurl');
      print('Bio: $bio');
      
      DocumentReference userDocumentReference = userCollection.doc(uid);
      
      // First verify document exists
      DocumentSnapshot docSnapshot = await userDocumentReference.get();
      if (!docSnapshot.exists) {
        print('❌ ERROR: User document does not exist!');
        throw Exception('User document not found for UID: $uid');
      }
      
      print('✓ User document exists, updating...');
      
      await userDocumentReference.update({
        "bio": bio,
        "profilePictureUrl": imageurl,
      });
      
      print('✓ Firestore update completed');
      
      // Verify the update was successful
      DocumentSnapshot verifySnapshot = await userDocumentReference.get();
      if (verifySnapshot.exists) {
        final data = verifySnapshot.data() as Map<String, dynamic>?;
        final savedUrl = data?['profilePictureUrl'] ?? '';
        final savedBio = data?['bio'] ?? '';
        
        print('=== Verification ===');
        print('Saved Profile Picture URL: $savedUrl');
        print('Saved Bio: $savedBio');
        print('URLs match: ${savedUrl == imageurl}');
        print('Bios match: ${savedBio == bio}');
        
        if (savedUrl != imageurl) {
          print('❌ WARNING: Profile picture URL mismatch!');
          print('Expected: $imageurl');
          print('Got: $savedUrl');
        } else {
          print('✅ Profile picture URL saved successfully to Firestore!');
        }
      }
    } catch (e) {
      print('❌ Error saving profile picture URL to Firestore: $e');
      rethrow;
    }
  }

  Future getUserData(String email) async {
    try {
      QuerySnapshot snapshot =
          await userCollection.where('email', isEqualTo: email).get();
      return snapshot;
    } on FirebaseException catch (e) {
      return e;
    }
  }

  Future getUserChats() async {
    return await userCollection.doc(uid).snapshots();
  }

  Future createChatWithFriend(
      String uid, String userName, String uid2, String userName2) async {
    DocumentReference chatDocumentReference = await chatCollection.add({
      "chatName": '',
      "recentMessageSender": '',
      "recentMessage": '',
      "members": [],
      "chatIcon": '',
      "chatId": ''
    });
    await chatDocumentReference.update({
      "chatName": "${uid}_${uid2}",
      "chatId": chatDocumentReference.id,
      "members":
          FieldValue.arrayUnion(["${uid}_$userName", "${uid2}_$userName2"])
    });

    DocumentReference userDocumentReference = await userCollection.doc(uid);
    DocumentReference user2DocumentReference = await userCollection.doc(uid2);
    await user2DocumentReference.update({
      "chats": FieldValue.arrayUnion(["${chatDocumentReference.id}_$userName"])
    });
    return await userDocumentReference.update({
      "chats": FieldValue.arrayUnion(["${chatDocumentReference.id}_$userName2"])
    });
  }

  Future searchByUsername(String userName) async {
    try {
      QuerySnapshot snapshot = await userCollection
          .where("userNameLowerCase", isEqualTo: userName.toLowerCase())
          .get();
      return snapshot;
    } on FirebaseException catch (e) {
      return e.message;
    }
  }

  Future check(String uid, String uid2) async {
    QuerySnapshot snapshot = await chatCollection
        .where("chatName", whereIn: ["${uid}_${uid2}", "${uid2}_${uid}"]).get();
    return snapshot;
  }

  Future changePassword(String uid, String newPassword) async {
    DocumentReference userDocumentReference = userCollection.doc(uid);
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
    return chatCollection
        .doc(chatId)
        .collection("Messages")
        .orderBy("messageTime")
        .snapshots();
  }

  Future sendMessage(String chatId, Map<String, dynamic> messageMap) async {
    await DatabaseService()
        .chatCollection
        .doc(chatId)
        .collection("Messages")
        .add(messageMap);
    await DatabaseService().chatCollection.doc(chatId).update({
      "recentMessage": messageMap['message'],
      "recentMessageSender": messageMap['messageSender']
    });
  }

  Future getChatData(String chatId) async {
    return chatCollection.doc(chatId).get();
  }

  Future<String> getUserProfilePicture(String userName) async {
    try {
      QuerySnapshot snapshot = await userCollection
          .where("userNameLowerCase", isEqualTo: userName.toLowerCase())
          .get();
      if (snapshot.docs.isNotEmpty) {
        final profileUrl = snapshot.docs[0]['profilePictureUrl'] ?? '';
        print('Retrieved profile picture for $userName: $profileUrl');
        return profileUrl;
      }
      print('No user found with userName: $userName');
      return '';
    } catch (e) {
      print('Error fetching profile picture for $userName: $e');
      return '';
    }
  }
}
