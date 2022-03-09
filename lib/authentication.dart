import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
// import 'package:google_sign_in/google_sign_in.dart';
import 'dart:io';
import 'dart:convert' show json;
import "package:http/http.dart" as http;



abstract class BaseAuth {


  Future<String> signIn(String email, String password);

  Future<String> signUp(String email, String password);

  Future<FirebaseUser> getCurrentUser();

  //
  // Future<void> sendEmailVerification();
  //
  Future<void> signOut();
//
// Future<String> signInWithGoogle();
//
// Future<void> signOutGoogle();

//
//   Future<bool> isEmailVerified();


}

class Auth implements BaseAuth {
  FirebaseAuth auth = FirebaseAuth.instance;



  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<String> signIn(String email, String password) async {
    AuthResult result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
    FirebaseUser user = result.user;
    return user.uid;
  }

  Future<String> signUp(String email, String password) async {
    AuthResult result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
    FirebaseUser user = result.user;
    return user.uid;
  }
//
  Future<FirebaseUser> getCurrentUser() async {


    if (_firebaseAuth.currentUser() != null) {
      return _firebaseAuth.currentUser();
    }
    return null;
  }
//
  Future<void> signOut() async {
    return FirebaseAuth.instance.signOut();
  }
//


//   Future<void> sendEmailVerification() async {
//     User user = FirebaseAuth.instance.currentUser;
//
//     if (!user.emailVerified) {
//       await user.sendEmailVerification();
//     }
//   }

}

