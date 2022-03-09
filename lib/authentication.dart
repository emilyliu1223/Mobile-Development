import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';




abstract class BaseAuth {



  Future<String> signIn(String email, String password);

  Future<String> signUp(String email, String password);

  Future<User> getCurrentUser();

  Future<void> sendEmailVerification();

  Future<void> signOut();

  Future<String> signInWithGoogle();

  Future<void> signOutGoogle();

//
//   Future<bool> isEmailVerified();
}
//
class Auth implements BaseAuth {
  FirebaseAuth auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  String name;
  String email;
  String imageUrl;

  Future<String> signInWithGoogle() async {
    await Firebase.initializeApp();

    final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication =
    await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    final UserCredential authResult =
    await auth.signInWithCredential(credential);
    final User user = authResult.user;

    if (user != null) {
      // Checking if email and name is null
      assert(user.email != null);
      assert(user.displayName != null);
      assert(user.photoURL != null);

      name = user.displayName;
      email = user.email;
      imageUrl = user.photoURL;

      // Only taking the first part of the name, i.e., First Name
      if (name.contains(" ")) {
        name = name.substring(0, name.indexOf(" "));
      }

      assert(!user.isAnonymous);
      assert(await user.getIdToken() != null);

      final User currentUser = auth.currentUser;
      assert(user.uid == currentUser.uid);

      print('signInWithGoogle succeeded: $user');

      return user.uid;
    }

    return null;
  }

  Future<void> signOutGoogle() async {
    await googleSignIn.signOut();

    print("User Signed Out");
  }





 Future start() async{
   FirebaseAuth.instance
       .authStateChanges()
       .listen((User user) {
     if (user == null) {
       print('User is currently signed out!');
     } else {
       print('User is signed in!');
     }
   });
 }
 Future<String> signUp(String email, String password) async{
   try {
     UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
         email: email,
         password: password
     );
     return userCredential.user.uid;
   } on FirebaseAuthException catch (e) {
     if (e.code == 'weak-password') {
       print('The password provided is too weak.');
     } else if (e.code == 'email-already-in-use') {
       print('The account already exists for that email.');
     }
   } catch (e) {
     print(e);
   }
   return null;
 }

 Future<String> signIn(String email,String password) async{
   try {
     UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
         email: email,
         password: password
     );
    return userCredential.user.uid;
   } on FirebaseAuthException catch (e) {
     if (e.code == 'user-not-found') {
       print('No user found for that email.');
     } else if (e.code == 'wrong-password') {
       print('Wrong password provided for that user.');
     }
   }
   return null;
 }


//   final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
//
//   Future<String> signIn(String email, String password) async {
//     AuthResult result = await _firebaseAuth.signInWithEmailAndPassword(
//         email: email, password: password);
//     FirebaseUser user = result.user;
//     return user.uid;
//   }
//
//   Future<String> signUp(String email, String password) async {
//     AuthResult result = await _firebaseAuth.createUserWithEmailAndPassword(
//         email: email, password: password);
//     FirebaseUser user = result.user;
//     return user.uid;
//   }
//
  Future<User> getCurrentUser() async {
    FirebaseAuth auth = FirebaseAuth.instance;

    if (auth.currentUser != null) {
      return auth.currentUser;
    }
    return null;
  }
//
  Future<void> signOut() async {
    return FirebaseAuth.instance.signOut();
  }
//
  Future<void> sendEmailVerification() async {
    User user = FirebaseAuth.instance.currentUser;

    if (!user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

}