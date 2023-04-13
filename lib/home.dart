// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sort_child_properties_last

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:icx2/adds.dart';
import 'package:icx2/msg.dart';
import 'package:icx2/post.dart';
import 'package:icx2/search.dart';
import 'package:icx2/views.dart';
import 'package:search_page/search_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

import 'acc.dart';
import 'feed.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  static String username = '';
  static String profilepic = '';

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var followingposts = [],
      followingstatus = [
        {'following': '', 'status': ''}
      ];

  DatabaseReference ref = FirebaseDatabase.instance.ref().child('users');

  Future<void> home() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    Home.username = prefs.getString('username').toString();
    ref.onValue.listen((event) {
      setState(() {
        Home.profilepic =
            (event.snapshot.child(Home.username).child('profile').exists)
                ? event.snapshot
                    .child(Home.username)
                    .child('profile')
                    .value
                    .toString()
                : '';

        followingstatus[0]['status'] =
            (event.snapshot.child(Home.username).child('status').exists)
                ? event.snapshot
                    .child(Home.username)
                    .child('status')
                    .value
                    .toString()
                : '';
      });

      for (final child
          in event.snapshot.child(Home.username).child('following').children) {
        ref
            .child(child.value.toString())
            .child('posts')
            .onValue
            .listen((event1) {
          for (final child in event1.snapshot.children) {
            setState(() {
              followingposts.add(child.value.toString());
            });
          }
        });

        ref
            .child(child.value.toString())
            .child('status')
            .onValue
            .listen((event) {
          if (event.snapshot.exists) {
            setState(() {
              followingstatus.add({
                'following': child.value.toString(),
                'status': event.snapshot.value.toString(),
              });
            });
          }
        });
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    home();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverAppBar(
              backgroundColor: Colors.white,
              systemOverlayStyle: SystemUiOverlayStyle(
                statusBarColor: Colors.white,
                statusBarIconBrightness: Brightness.dark,
              ),
              title: Padding(
                padding: const EdgeInsets.only(left: 0, top: 10),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => Account(
                            username: Home.username,
                          ),
                        ));
                  },
                  child: Wrap(
                    children: [
                      Hero(
                        tag: Home.username,
                        child: CircleAvatar(
                          backgroundColor: Colors.pinkAccent,
                          backgroundImage: (Home.profilepic.isEmpty)
                              ? NetworkImage(
                                  'https://i.postimg.cc/NGNJmhnP/undraw-Male-avatar-g98d.png')
                              : NetworkImage(Home.profilepic),
                          radius: 15,
                        ),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        Home.username,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 25,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: IconButton(
                    onPressed: () {
                      var people = [];

                      ref.onValue.listen((event) {
                        for (final child in event.snapshot.children) {
                          setState(() {
                            people.add(child.key.toString());
                          });
                        }
                      });

                      showSearch(
                        context: context,
                        delegate: SearchPage<dynamic>(
                          barTheme: ThemeData(
                              primarySwatch: Colors.pink,
                              appBarTheme: AppBarTheme(
                                backgroundColor: Colors.white,
                                elevation: 0,
                              )),
                          searchStyle: TextStyle(
                            fontFamily: 'Montserrat',
                          ),
                          items: people,
                          searchLabel: 'Search',
                          suggestion: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ShaderMask(
                                  shaderCallback: (Rect bounds) {
                                    return SweepGradient(
                                      colors: [
                                        Colors.pinkAccent,
                                        Colors.deepPurpleAccent,
                                        Colors.red
                                      ],
                                    ).createShader(bounds);
                                  },
                                  child: Icon(
                                    CupertinoIcons.search_circle,
                                    color: Colors.purpleAccent,
                                    size: 70,
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Text(
                                  "Search for people",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20.0,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          failure: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ShaderMask(
                                  shaderCallback: (Rect bounds) {
                                    return SweepGradient(
                                      colors: [
                                        Colors.pinkAccent,
                                        Colors.deepPurpleAccent,
                                        Colors.red
                                      ],
                                    ).createShader(bounds);
                                  },
                                  child: Icon(
                                    CupertinoIcons.exclamationmark_circle,
                                    color: Colors.purpleAccent,
                                    size: 70,
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Text(
                                  "Not found!",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20.0,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Text(
                                  "Try correcting the name.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 14,
                                  ),
                                )
                              ],
                            ),
                          ),
                          filter: (person) => [
                            person.toString(),
                          ],
                          builder: (person) => InkWell(
                            onTap: () {
                              Navigator.pushReplacement(
                                  context,
                                  CupertinoPageRoute(
                                    builder: (context) =>
                                        Account(username: person.toString()),
                                  ));
                            },
                            child: ListTile(
                              title: Text(
                                person.toString(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Montserrat',
                                  fontSize: 15,
                                ),
                              ),
                              trailing: Icon(
                                Icons.search,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    icon: Icon(
                      CupertinoIcons.search,
                      color: Colors.black,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: IconButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => Message(),
                          ));
                    },
                    icon: Icon(
                      CupertinoIcons.paperplane,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
              elevation: 0,
              automaticallyImplyLeading: false,
              floating: true,
              snap: true,
            )
          ];
        },
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 130,
                  child: ListView.builder(
                    itemCount: followingstatus.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          InkWell(
                            onTap: () {
                              if (index == 0) {
                                Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                      builder: (context) => AddStatus(
                                        mystatus: followingstatus[0]['status']
                                            .toString(),
                                      ),
                                    ));
                              } else {
                                Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                      builder: (context) => ViewStatus(
                                        mystatus: followingstatus[index]
                                                ['status']
                                            .toString(),
                                      ),
                                    ));
                              }
                            },
                            onLongPress: () {
                              if (index == 0 &&
                                  followingstatus[0]['status']
                                      .toString()
                                      .isNotEmpty) {
                                showModalBottomSheet(
                                  context: context,
                                  builder: (context) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 25, horizontal: 15),
                                    child: OutlinedButton(
                                        onPressed: () {
                                          FirebaseDatabase.instance
                                              .ref()
                                              .child('users')
                                              .child(Home.username)
                                              .child('status')
                                              .set(null);

                                          Fluttertoast.showToast(
                                              msg: 'Status deleted');
                                          Navigator.pop(context);
                                        },
                                        style: OutlinedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20)),
                                            side: BorderSide(
                                              color: Colors.redAccent,
                                              width: 3,
                                            )),
                                        child: Text(
                                          'Delete status',
                                        )),
                                  ),
                                );
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                border: const GradientBoxBorder(
                                  gradient: SweepGradient(colors: [
                                    Colors.pinkAccent,
                                    Colors.deepPurpleAccent,
                                    Colors.red
                                  ]),
                                  width: 3,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(3.0),
                                child: Stack(
                                  children: [
                                    CircleAvatar(
                                      radius: 35,
                                      backgroundImage: (followingstatus[index]
                                                  ['status']!
                                              .isEmpty)
                                          ? (Home.profilepic.isEmpty)
                                              ? NetworkImage(
                                                  'https://i.postimg.cc/NGNJmhnP/undraw-Male-avatar-g98d.png')
                                              : NetworkImage(Home.profilepic)
                                          : NetworkImage(followingstatus[index]
                                                  ['status']
                                              .toString()),
                                    ),
                                    Visibility(
                                      visible: (index == 0) ? true : false,
                                      child: Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: Container(
                                          decoration: BoxDecoration(
                                              color: Colors.pinkAccent,
                                              borderRadius:
                                                  BorderRadius.circular(20)),
                                          child: Padding(
                                            padding: const EdgeInsets.all(3.0),
                                            child: Icon(
                                              CupertinoIcons.add,
                                              // color: Colors.purpleAccent[700],
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 6,
                          ),
                          Text(
                            (index == 0)
                                ? 'Your story'
                                : followingstatus[index]['following']
                                    .toString(),
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 13,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: followingposts.length,
                  itemBuilder: (context, index) => Feeditem(
                    value: followingposts[index],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(50.0),
                  child: Column(
                    children: [
                      ShaderMask(
                        shaderCallback: (Rect bounds) {
                          return SweepGradient(
                            colors: [
                              Colors.pinkAccent,
                              Colors.deepPurpleAccent,
                              Colors.red
                            ],
                          ).createShader(bounds);
                        },
                        child: Icon(
                          CupertinoIcons.check_mark_circled,
                          color: Colors.purpleAccent,
                          size: 70,
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      GradientText(
                        "You're all caught up",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0,
                        ),
                        colors: [
                          Colors.pinkAccent,
                          Colors.deepPurpleAccent,
                          Colors.red
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        "You can follow more people to view their posts.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 14,
                        ),
                      )
                    ],
                  ),
                ),
                // Padding(
                //   padding: const EdgeInsets.all(15.0),
                //   child: Row(
                //     children: [
                //       Text(
                //         'Trending Posts',
                //         style: TextStyle(
                //           color: Colors.black,
                //           fontSize: 23,
                //           fontWeight: FontWeight.bold,
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
                // ListView.builder(
                //   shrinkWrap: true,
                //   physics: NeverScrollableScrollPhysics(),
                //   itemCount: 0,
                //   itemBuilder: (context, index) => Feeditem(),
                // )
              ],
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => Post(),
              ));
        },
        child: Container(
          width: 60,
          height: 60,
          child: Icon(
            CupertinoIcons.add,
          ),
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: SweepGradient(
                colors: <Color>[
                  Colors.pinkAccent,
                  Colors.deepPurpleAccent,
                  Colors.red
                ],
              )),
        ),
      ),
    );
  }
}
