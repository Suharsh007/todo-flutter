// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

final User? user = FirebaseAuth.instance.currentUser;

TextEditingController taskController = TextEditingController();
TextEditingController dateController = TextEditingController();
TextEditingController timeController = TextEditingController();
String task = "";
String date = "";
String time = "";
final _formKey = GlobalKey<FormState>();
bool showSpinner = false;

class _AddTaskScreenState extends State<AddTaskScreen> {
  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(myInterceptor);
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    Navigator.pop(context, true);
    return true;
  }

  String formattedTime = "";
  @override
  Widget build(BuildContext context) {
    DateTime dateTime = DateTime.now();
    _selectDate() async {
      final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: dateTime,
          initialDatePickerMode: DatePickerMode.day,
          firstDate: DateTime.now(),
          lastDate: DateTime(2101));
      if (picked != null) {
        dateTime = picked;
        //assign the chosen date to the controller
        dateController.text = DateFormat.yMd().format(dateTime);
      }
    }

    return ModalProgressHUD(
        inAsyncCall: showSpinner,
        dismissible: false,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: appBar(),
          body: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Center(
                      child: Image.asset(
                    "assets/images/add_task.png",
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
                          style: GoogleFonts.openSans(
                              textStyle: TextStyle(color: Colors.black)),
                          cursorColor: Colors.black,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            prefixIcon: Icon(
                              Icons.task,
                              color: Colors.black,
                            ),
                            hintText: "Enter Task",
                            enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(10.0)),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide.none,
                            ),
                            labelText: "Task",
                            fillColor: Colors.grey[450],
                            filled: true,
                            labelStyle: TextStyle(color: Colors.black),
                          ),
                          onChanged: (String value) {
                            task = value;
                          },
                          validator: (value) {
                            return value!.isEmpty ? "Enter Task" : null;
                          },
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          readOnly: true,
                          onTap: _selectDate,
                          style: GoogleFonts.openSans(
                              textStyle: TextStyle(color: Colors.black)),
                          cursorColor: Colors.black,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            prefixIcon: Icon(
                              Icons.calendar_month,
                              color: Colors.black,
                            ),
                            hintText: "Choose Date",
                            enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(10.0)),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide.none,
                            ),
                            labelText: "Date",
                            fillColor: Colors.grey[450],
                            filled: true,
                            labelStyle: TextStyle(color: Colors.black),
                          ),
                          controller: dateController,
                          validator: (value) {
                            return value!.isEmpty ? "Choose Date" : null;
                          },
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          readOnly: true,
                          controller: timeController,
                          onTap: () async {
                            TimeOfDay? pickedTime = await showTimePicker(
                              initialTime: TimeOfDay.now(),
                              context: context,
                            );

                            if (pickedTime != null) {
                              DateTime parsedTime = DateFormat.jm()
                                  .parse(pickedTime.format(context).toString());

                              formattedTime =
                                  DateFormat('HH:mm:ss').format(parsedTime);

                              setState(() {
                                timeController.text =
                                    formattedTime; //set the value of text field.
                              });
                            }
                          },
                          style: GoogleFonts.openSans(
                              textStyle: TextStyle(color: Colors.black)),
                          cursorColor: Colors.black,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            prefixIcon: Icon(
                              Icons.timer,
                              color: Colors.black,
                            ),
                            hintText: "Choose Time",
                            enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(10.0)),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide.none,
                            ),
                            labelText: "Time",
                            fillColor: Colors.grey[450],
                            filled: true,
                            labelStyle: TextStyle(color: Colors.black),
                          ),
                          validator: (value) {
                            return value!.isEmpty ? "ChooseTime" : null;
                          },
                        ),
                        SizedBox(
                          height: 40,
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
                                  String? uid = user?.uid;
                                  await FirebaseFirestore.instance
                                      .collection(uid!)
                                      .doc(DateTime.now().toString())
                                      .set({
                                    "task": task,
                                    "dateTime": dateController.text +
                                        timeController.text,
                                    "date": dateController.text,
                                    "time": timeController.text,
                                    "isDone": false,
                                  });
                                  toastMessages("Task Added Succesfully");
                                  setState(() {
                                    showSpinner = false;

                                    Navigator.pop(context, true);
                                  });
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
                                "Save Task",
                                style: GoogleFonts.openSans(
                                  textStyle: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ));
  }

  PreferredSizeWidget appBar() {
    return AppBar(
      leading: Icon(Icons.arrow_back_ios),
      automaticallyImplyLeading: true,
      title: Text(
        "Add Task",
        style: GoogleFonts.openSans(
          fontSize: 22,
          fontWeight: FontWeight.bold,
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
