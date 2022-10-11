// ignore_for_file: prefer_const_constructors, void_checks

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:circular_menu/circular_menu.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tasker/models/task.dart';
import 'package:tasker/screens/add_task.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

final User? user = FirebaseAuth.instance.currentUser;

class _HomeScreenState extends State<HomeScreen> {
  final User? user = FirebaseAuth.instance.currentUser;

  List<Task> taskList = [];
  @override
  void initState() {
    super.initState();
    getTasks(user?.uid);
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    DateTime today = new DateTime.now();

    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0xff38b6ff),
        floatingActionButton: FloatingActionButton(
          elevation: 20,
          tooltip: "Add a Task",
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => AddTaskScreen()));
          },
          child: Icon(
            Icons.add,
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        body: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: height),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, top: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        text("Welcome, ", .05),
                        SizedBox(
                          height: height * 0.02,
                        ),
                        text("To Tasker!", 0.05),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: height * 0.02,
                  ),
                  Divider(
                    height: 1,
                    color: Colors.white,
                  ),
                  SizedBox(
                    height: height * 0.02,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: text(DateFormat.yMMMMd().format(today), 0.045),
                  ),
                  /*   Expanded(
                      child: ListView.builder(
                          shrinkWrap: true,
                          physics: AlwaysScrollableScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          itemCount: taskList.length,
                          itemBuilder: (context, index) {
                            return circularMenu(index);
                          }),
                    ),*/
                  StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: FirebaseFirestore.instance
                          .collection(user!.uid)
                          .orderBy('dateTime', descending: false)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Center(
                              child: CircularProgressIndicator(
                            color: Colors.white,
                          ));
                        } else {
                          return Expanded(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(maxHeight: height),
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: AlwaysScrollableScrollPhysics(),
                                  scrollDirection: Axis.vertical,
                                  itemCount: snapshot.data!.docs.length,
                                  itemBuilder: (context, index) {
                                    DocumentSnapshot data =
                                        snapshot.data?.docs[index]
                                            as DocumentSnapshot<Object?>;
                                    return circularMenu(data);
                                  }),
                            ),
                          );
                        }
                      }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget text(String text, double scale) {
    double height = MediaQuery.of(context).size.height;
    return Text(text,
        style: GoogleFonts.openSans(
            fontWeight: FontWeight.bold,
            fontSize: height * scale,
            color: Colors.white));
  }

  Widget circularMenu(DocumentSnapshot data) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: CircularMenu(
          toggleButtonColor: Color(0xff2A7CDD),
          radius: 50,
          alignment: Alignment.centerRight,
          toggleButtonSize: 20,
          startingAngleInRadian: 1.0 * pi,
          endingAngleInRadian: 1.5 * pi,
          backgroundWidget: Card(
            elevation: 8,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Container(
                      height: 20,
                      width: 20,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Color(0xff2A7CDD),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 12,
                  ),
                  Container(
                    width: width * 0.6,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 8.0, left: 6.0, bottom: 8.0),
                          child: !data['isDone']
                              ? Text(
                                  data['task'],
                                  style: GoogleFonts.lato(
                                    fontSize: 19,
                                  ),
                                )
                              : Text(
                                  data['task'],
                                  style: GoogleFonts.lato(
                                    fontSize: 19,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 6.0, left: 6.0, bottom: 1.0),
                          child: !data['isDone']
                              ? Text(
                                  data['date'],
                                  style: GoogleFonts.lato(
                                    fontSize: 16,
                                  ),
                                )
                              : Text(
                                  data['date'],
                                  style: GoogleFonts.lato(
                                    fontSize: 16,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                        ),
                        Padding(
                            padding: const EdgeInsets.only(
                                top: 1.0, left: 6.0, bottom: 8.0),
                            child: !data['isDone']
                                ? Text(
                                    data['time'],
                                    style: GoogleFonts.lato(
                                      fontSize: 14,
                                    ),
                                  )
                                : Text(
                                    data['time'],
                                    style: GoogleFonts.lato(
                                      fontSize: 14,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  )),
                      ],
                    ),
                  ),
                ]),
              ],
            ),
          ),
          items: [
            CircularMenuItem(
                icon: Icons.delete,
                iconColor: Colors.white,
                iconSize: 20,
                color: Color(0xff2A7CDD),
                onTap: () => delete(data)),
            !data['isDone']
                ? CircularMenuItem(
                    icon: Icons.done,
                    iconColor: Colors.white,
                    iconSize: 20,
                    color: Color(0xff2A7CDD),
                    onTap: () => update(data))
                : CircularMenuItem(
                    icon: Icons.cancel_sharp,
                    iconColor: Colors.white,
                    iconSize: 20,
                    color: Color(0xff2A7CDD),
                    onTap: () => update(data)),
          ]),
    );
  }

  void delete(DocumentSnapshot doc) async {
    print(doc.id);
    await FirebaseFirestore.instance
        .collection(user!.uid)
        .doc(doc.id)
        .delete()
        .then((_) => {
              toastMessages("Task Deleted"),
              setState(() {}),
            });
  }

  void update(DocumentSnapshot doc) async {
    await FirebaseFirestore.instance
        .collection(user!.uid)
        .doc(doc.id)
        .update({"isDone": !doc['isDone']}).then((_) => {});
  }

  void getTasks(String? uid) async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection(uid!).get();
    taskList = snapshot.docs
        .map((d) => Task.fromJSON(d.data() as Map<String, dynamic>))
        .toList();

    print(taskList.length);
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
