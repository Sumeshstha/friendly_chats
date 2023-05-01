import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService{
final String? uid;
DatabaseService({this.uid});
final CollectionReference userCollection= FirebaseFirestore.instance.collection("User");
final CollectionReference friendCollection = FirebaseFirestore.instance.collection("Friends");

Future updateUserData(String userName, String email, String password) async{
  return await userCollection.doc(uid).set({
    "userName": userName,
    "email": email,
    "password": password,
    "friends": []
  });
}

Future getUserData(String email)async {
  QuerySnapshot snapshot = await userCollection.where("email" , isEqualTo: email).get();
  return snapshot;
}

}