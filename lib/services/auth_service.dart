

import 'package:firebase_auth/firebase_auth.dart';
import 'package:friendly_chat/helper/helper_function.dart';
import 'package:friendly_chat/services/database_service.dart';

class AuthService{
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;


  Future registerWithEmail(String userName, String email, String password) async{

    try{
      User  user = (await firebaseAuth.createUserWithEmailAndPassword(email: email, password: password)).user!;
        await DatabaseService(uid: user.uid).createUserData(userName, email, password);
        return true;
      

    }

  on FirebaseAuthException catch(e){
    return e.message;
  }
  }

  Future login(String email, String password) async {
    try { 
      User user = (await firebaseAuth.signInWithEmailAndPassword(email: email, password: password)).user!;
      if(user != null){
        return true;
      }
    }
    catch (e){
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


  Future changePassword(String oldPassword, String newPassword) async {
    try {
      final  credential = EmailAuthProvider.credential(
        email: FirebaseAuth.instance.currentUser!.email!,
        password: oldPassword);
      await firebaseAuth.currentUser!.reauthenticateWithCredential(credential).then((value)async {
        await firebaseAuth.currentUser!.updatePassword(newPassword);
        await DatabaseService(uid:FirebaseAuth.instance.currentUser!.uid).changePassword(FirebaseAuth.instance.currentUser!.uid, newPassword);
      });
      
    }
    on FirebaseAuthException  catch (e){
      return e.message;
    }
  }

}