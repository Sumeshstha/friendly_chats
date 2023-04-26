import 'package:firebase_auth/firebase_auth.dart';
import 'package:friendly_chat/services/database_service.dart';

class AuthService{
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;


  Future registerWithEmail(String userName, String email, String password) async{

    try{
      User  user = (await firebaseAuth.createUserWithEmailAndPassword(email: email, password: password)).user!;
      if(user!= null){
        await DatabaseService(user.uid).updateUserData(userName, email, password);
      }

    }

  on FirebaseAuthException catch(e){

  }
  }
}