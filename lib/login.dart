// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sort_child_properties_last, use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:icx2/home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  int fadestate = 1;
  var email = '', password = '', username = '';
  var userslist = [];

  DatabaseReference ref = FirebaseDatabase.instance.ref().child('users');

  void fetchUsernames() {
    ref.onValue.listen((event) {
      for (final child in event.snapshot.children) {
        userslist.add(child.child('username').value.toString());
      }
    });
  }

  Future<void> isLoggedIn() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('username') != null) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Home(),
          ));
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isLoggedIn();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(25),
          child: Center(
            child: AnimatedCrossFade(
              duration: Duration(seconds: 1),
              crossFadeState: (fadestate == 1)
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              firstChild: Container(
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: 'Welcome to\na new \n',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Montserrat',
                    ),
                    children: [
                      TextSpan(
                        text: 'Redesigned ',
                        style: TextStyle(
                          fontSize: 45,
                          fontWeight: FontWeight.bold,
                          foreground: Paint()
                            ..shader = LinearGradient(
                              colors: <Color>[
                                Colors.pinkAccent,
                                Colors.deepPurpleAccent,
                                Colors.red
                                //add more color here.
                              ],
                            ).createShader(
                              Rect.fromLTWH(0.0, 0.0, 200.0, 100.0),
                            ),
                        ),
                      ),
                      TextSpan(
                        text: 'version of ',
                      ),
                      TextSpan(
                          text: 'Instagram',
                          style: TextStyle(
                            color: Colors.pinkAccent[400],
                            fontSize: 35,
                          ))
                    ],
                  ),
                ),
              ),
              secondChild: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: const GradientBoxBorder(
                    gradient: SweepGradient(colors: [
                      Colors.pinkAccent,
                      Colors.deepPurpleAccent,
                      Colors.red
                    ]),
                    width: 4,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: AnimatedCrossFade(
                    duration: Duration(seconds: 1),
                    crossFadeState: (fadestate == 2)
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,
                    firstChild: Wrap(
                      runSpacing: 20,
                      children: [
                        Text(
                          'Login',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextField(
                          onChanged: (value) {
                            email = value.trim().toLowerCase();
                          },
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(
                            color: Colors.black,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Email',
                            hintStyle: TextStyle(
                              color: Colors.black54,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Colors.black45,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Colors.black,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                        TextField(
                          onChanged: (value) {
                            password = value.trim();
                          },
                          keyboardType: TextInputType.visiblePassword,
                          style: TextStyle(
                            color: Colors.black,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Password',
                            hintStyle: TextStyle(
                              color: Colors.black54,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Colors.black45,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Colors.black,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () async {
                                    if (email.isEmpty ||
                                        password.isEmpty ||
                                        email.contains(' ') ||
                                        password.contains(' ')) {
                                      Fluttertoast.showToast(
                                        msg: 'Invalid required field!',
                                        textColor: Colors.redAccent,
                                      );
                                    } else {
                                      bool error = false;
                                      try {
                                        final credential = await FirebaseAuth
                                            .instance
                                            .signInWithEmailAndPassword(
                                                email: email,
                                                password: password);
                                      } on FirebaseAuthException catch (e) {
                                        error = true;
                                        Fluttertoast.showToast(
                                          msg: '$e',
                                          textColor: Colors.redAccent,
                                          toastLength: Toast.LENGTH_LONG,
                                        );
                                      }

                                      if (!error) {
                                        ref.onValue.listen((event) async {
                                          for (final child
                                              in event.snapshot.children) {
                                            if (child
                                                    .child('email')
                                                    .value
                                                    .toString() ==
                                                email) {
                                              final SharedPreferences prefs =
                                                  await SharedPreferences
                                                      .getInstance();
                                              await prefs.setString('username',
                                                  child.key.toString());
                                              Navigator.pushReplacement(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        Home(),
                                                  ));
                                            }
                                          }
                                        });
                                      }
                                    }
                                  },
                                  child: GradientText(
                                    'Submit',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15.0,
                                    ),
                                    colors: [
                                      Colors.pinkAccent,
                                      Colors.deepPurpleAccent,
                                      Colors.red
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                TextButton(
                                    onPressed: () async {
                                      if (email.isEmpty ||
                                          password.isEmpty ||
                                          email.contains(' ') ||
                                          password.contains(' ')) {
                                        Fluttertoast.showToast(
                                          msg: 'Invalid required field!',
                                          textColor: Colors.redAccent,
                                        );
                                      } else {
                                        setState(() {
                                          fadestate = 3;
                                        });
                                      }
                                    },
                                    child: Text(
                                      'Create account',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    )),
                              ],
                            )
                          ],
                        ),
                      ],
                    ),
                    secondChild: Wrap(
                      runSpacing: 20,
                      children: [
                        Text(
                          'Create username',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextField(
                          onChanged: (value) {
                            username = value.trim().toLowerCase();
                          },
                          style: TextStyle(
                            color: Colors.black,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Username',
                            hintStyle: TextStyle(
                              color: Colors.black54,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Colors.black45,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Colors.black,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () async {
                                    // Navigator.pushReplacement(
                                    //     context,
                                    //     CupertinoPageRoute(
                                    //       builder: (context) => Home(),
                                    //     ));

                                    if (username.isEmpty ||
                                        username.contains(' ') ||
                                        username.contains('/') ||
                                        username.contains('@') ||
                                        username.contains('.')) {
                                      Fluttertoast.showToast(
                                        msg: 'Invalid required field!',
                                        textColor: Colors.redAccent,
                                      );
                                    } else if (userslist.contains(username)) {
                                      Fluttertoast.showToast(
                                          msg: 'Username already taken!');
                                    } else {
                                      bool error = false;
                                      try {
                                        final credential = await FirebaseAuth
                                            .instance
                                            .createUserWithEmailAndPassword(
                                                email: email,
                                                password: password);
                                      } on FirebaseAuthException catch (e) {
                                        error = true;
                                        Fluttertoast.showToast(
                                          msg: '$e',
                                          textColor: Colors.redAccent,
                                          toastLength: Toast.LENGTH_LONG,
                                        );
                                      }

                                      if (!error) {
                                        ref
                                            .child(username)
                                            .child('email')
                                            .set(email);

                                        final SharedPreferences prefs =
                                            await SharedPreferences
                                                .getInstance();
                                        await prefs.setString(
                                            'username', username);

                                        Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => Home(),
                                            ));
                                      }
                                    }
                                  },
                                  child: GradientText(
                                    'Submit',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15.0,
                                    ),
                                    colors: [
                                      Colors.pinkAccent,
                                      Colors.deepPurpleAccent,
                                      Colors.red
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Visibility(
        visible: (fadestate == 1),
        child: FloatingActionButton(
          onPressed: () {
            setState(() {
              fadestate = 2;
            });
          },
          child: Container(
            width: 60,
            height: 60,
            child: Icon(
              CupertinoIcons.arrow_right,
            ),
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: SweepGradient(
                  colors: <Color>[
                    Colors.pinkAccent,
                    Colors.deepPurpleAccent,
                    Colors.red
                    //add more color here.
                  ],
                )),
          ),
        ),
      ),
    );
  }
}
