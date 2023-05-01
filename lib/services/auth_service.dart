import 'package:firebase_auth/firebase_auth.dart';
import 'package:friendly_chat/helper/helper_function.dart';
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

  Future login (String email, String password)async {         // signin
    try {
      User user = (await firebaseAuth.signInWithEmailAndPassword(email: email, password: password)).user!;
      if(user != null){
        return true;
      }
    }
    catch(e){
      return null;
    }
  }


  Future logout () async {            // signout
    try  {
      await HelperFunction.saveLoggedInStatus(false);
      await HelperFunction.saveUserEmail("");
      await HelperFunction.saveUserName("");
      await firebaseAuth.signOut();
    }
    catch (e){
      return null; 
    }

  }

}