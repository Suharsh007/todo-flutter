// ignore_for_file: prefer_final_fields, curly_braces_in_flow_control_structures

import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthClass {
  GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>[
      'email',
      'https://www.googleapis.com/auth/contacts.readonly',
    ],
  );
  FirebaseAuth auth = FirebaseAuth.instance;
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');
  Future<void> googleSignIn(BuildContext context) async {
    try {
      GoogleSignInAccount? googleSignInAccount = await _googleSignIn.signIn();
      if (googleSignInAccount != null) {
        GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;

        AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken,
        );

        UserCredential userCredential =
            await auth.signInWithCredential(credential);

        // userSetup();
        final User? currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null)
          await userCollection.doc(currentUser.uid).set({
            'email': currentUser.email,
            'name': currentUser.displayName,
            'uid': currentUser.uid,
          });
        toastMessages("User added succesfully");
      }
    } catch (e) {
      toastMessages("Error Occured");
    }
  }

  void toastMessages(String messsage) {
    Fluttertoast.showToast(
        msg: messsage.toString(),
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.SNACKBAR,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.white,
        textColor: Colors.black,
        fontSize: 16.0);
  }

/*  Future<void> userSetup() async {
    final User? user = auth.currentUser;
    Map userData = {
      "uid": user!.uid,
      "name": user.displayName,
      "email": user.email,
    };
    DocumentReference documentReferencer = userCollection.doc(user.uid);

    await documentReferencer.set(userData).whenComplete(() {
      toastMessages("User created succesfully");
    }).catchError((e) => toastMessages("Error Occured " + e.toString()));

    //return;
  }*/
}
