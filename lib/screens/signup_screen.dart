// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:tasker/screens/home_screen.dart';
import 'package:tasker/screens/login_screen.dart';
import 'package:tasker/services/auth_services.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');
  bool showSpinner = false;
  FirebaseAuth _auth = FirebaseAuth.instance;
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String name = "";
  String email = "";
  String password = "";

  final _formKey = GlobalKey<FormState>();
  bool _showPassword = false;
  void _togglevisibility() {
    setState(() {
      _showPassword = !_showPassword;
    });
  }

  AuthClass authClass = AuthClass();

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: showSpinner,
      dismissible: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                      child: Image.asset(
                    "assets/images/login_img.png",
                    fit: BoxFit.cover,
                  )),
                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 20),
                    child: Column(
                      children: [
                        TextFormField(
                          style: GoogleFonts.lato(
                              textStyle: TextStyle(color: Colors.black)),
                          cursorColor: Colors.black,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            prefixIcon: Icon(
                              Icons.perm_identity_rounded,
                              color: Colors.black,
                            ),
                            hintText: "Enter Name",
                            enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(10.0)),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide.none,
                            ),
                            labelText: "Name",
                            fillColor: Colors.grey[450],
                            filled: true,
                            labelStyle: TextStyle(color: Colors.black),
                          ),
                          onChanged: (String value) {
                            name = value;
                          },
                          validator: (value) {
                            return value!.isEmpty ? "Enter Name" : null;
                          },
                        ),
                        SizedBox(
                          height: 12,
                        ),
                        TextFormField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: GoogleFonts.lato(
                              textStyle: TextStyle(color: Colors.black)),
                          cursorColor: Colors.black,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            prefixIcon: Icon(
                              Icons.email,
                              color: Colors.black,
                            ),
                            hintText: "Enter Email",
                            enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(10.0)),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide.none,
                            ),
                            labelText: "Email",
                            fillColor: Colors.grey[450],
                            filled: true,
                            labelStyle: TextStyle(color: Colors.black),
                          ),
                          onChanged: (String value) {
                            email = value;
                          },
                          validator: (value) {
                            return value!.isEmpty ? "Enter Email" : null;
                          },
                        ),
                        SizedBox(
                          height: 12,
                        ),
                        TextFormField(
                          style: GoogleFonts.lato(
                              textStyle: TextStyle(color: Colors.black)),
                          cursorColor: Colors.black,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            /*prefixIcon: Icon(
                              Icons.email,
                              color: Colors.black,
                            ),*/
                            prefixIcon: Transform.rotate(
                                angle: 135 * 3.14 / 180,
                                child: Icon(
                                  Icons.vpn_key,
                                  color: Colors.black,
                                )),
                            hintText: "Enter Password",
                            enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(10.0)),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide.none,
                            ),
                            labelText: "Password",
                            fillColor: Colors.grey[450],
                            filled: true,
                            labelStyle: TextStyle(color: Colors.black),
                            suffixIcon: GestureDetector(
                              onTap: () {
                                _togglevisibility();
                              },
                              child: Icon(
                                _showPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          obscureText: _showPassword,
                          onChanged: (String value) {
                            password = value;
                          },
                          validator: (value) {
                            return value!.isEmpty ? "Enter Password" : null;
                          },
                        ),
                        SizedBox(
                          height: 18,
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            "Forgot Password?",
                            style: GoogleFonts.lato(
                                textStyle: TextStyle(color: Color(0xff2A7CDD)),
                                fontSize: 15),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Material(
                          borderRadius: BorderRadius.circular(10.0),
                          color: Color(0xff2A7CDD),
                          child: InkWell(
                            onTap: () async {
                              if (_formKey.currentState!.validate()) {
                                setState(() {
                                  showSpinner = true;
                                });
                                try {
                                  final user = await _auth
                                      .createUserWithEmailAndPassword(
                                          email: email.toString().trim(),
                                          password: password.toString().trim());
                                  if (user != null) {
                                    final User? user = _auth.currentUser;

                                    await FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(user?.uid)
                                        .set({
                                      "uid": user!.uid,
                                      "name": name,
                                      "email": email,
                                    });
                                    toastMessages("User created successfuly");
                                    setState(() {
                                      showSpinner = false;
                                    });
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                HomeScreen()));
                                  }
                                } catch (e) {
                                  print(e.toString());
                                  toastMessages(e.toString());
                                  setState(() {
                                    showSpinner = false;
                                  });
                                }
                              }
                            },
                            child: AnimatedContainer(
                              duration: Duration(seconds: 1),
                              width: MediaQuery.of(context).size.width,
                              height: 50,
                              alignment: Alignment.center,
                              child: Text(
                                "Sign Up",
                                style: GoogleFonts.lato(
                                  textStyle: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Divider(
                                height: 20,
                                thickness: 1,
                                indent: 10,
                                endIndent: 2,
                                color: Colors.black,
                              ),
                            ),
                            Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(8.0, 0, 0, 0),
                                child: Text(
                                  "Or Login With",
                                  style: GoogleFonts.lato(
                                      textStyle: TextStyle(
                                          color: Colors.black, fontSize: 15)),
                                )),
                            Expanded(
                              child: Divider(
                                height: 20,
                                thickness: 1,
                                indent: 10,
                                endIndent: 2,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        SizedBox(
                          height: 50,
                          child: SignInButton(
                            Buttons.Google,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 2,
                            text: "Sign up with Google",
                            onPressed: () async {
                              setState(() {
                                showSpinner = true;
                              });
                              await authClass.googleSignIn(context);
                              setState(() {
                                showSpinner = false;
                              });
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => HomeScreen()));
                            },
                          ),
                        ),
                        SizedBox(
                          height: 25,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Have an account?",
                              style: GoogleFonts.lato(
                                  textStyle: TextStyle(color: Colors.black),
                                  fontSize: 15),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => LoginScreen()));
                              },
                              child: Text(
                                "Login",
                                style: GoogleFonts.lato(
                                    textStyle:
                                        TextStyle(color: Color(0xff2A7CDD)),
                                    fontSize: 15),
                              ),
                            ),
                            SizedBox(
                              height: 30,
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
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
}
