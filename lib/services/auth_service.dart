import 'package:firebase_auth/firebase_auth.dart';
import 'package:friendly_chat/services/database_service.dart';

class AuthService{
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;


  Future registerWithEmail(String userName, String email, String password) async{

    try{
      User  user = (await firebaseAuth.createUserWithEmailAndPassword(email: email, password: password)).user!;
        await DatabaseService(uid: user.uid).updateUserData(userName, email, password);
        return true;
      

    }

  on FirebaseAuthException catch(e){
    return e.message;
  }
  }
}