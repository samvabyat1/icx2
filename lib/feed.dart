// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:icx2/acc.dart';
import 'package:intl/intl.dart';

class Feeditem extends StatefulWidget {
  final String value;
  const Feeditem({super.key, required this.value});

  @override
  State<Feeditem> createState() => _FeeditemState();
}

class _FeeditemState extends State<Feeditem> {
  var postby = '', img = '', profilepic = '', likes = [], comments = [];
  var isliked = false;

  void feed() {
    DatabaseReference refp =
        FirebaseDatabase.instance.ref().child('posts').child(widget.value);
    refp.onValue.listen((event) {
      setState(() {
        postby = event.snapshot.child('by').value.toString();
        img = event.snapshot.child('img').value.toString();

        for (final child in event.snapshot.child('likes').children) {
          likes.add(child.value.toString());
        }
        for (final child in event.snapshot.child('comments').children) {
          comments.add(child.value.toString());
        }
      });
    });

    DatabaseReference ref =
        FirebaseDatabase.instance.ref().child('users').child(postby);

    ref.onValue.listen((event) {
      setState(() {
        profilepic = (event.snapshot.child('profile').exists)
            ? event.snapshot.child('profile').value.toString()
            : '';
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    feed();
  }

  void liked() {
    setState(() {
      isliked = !isliked;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: InkWell(
                onDoubleTap: () {
                  Fluttertoast.showToast(
                    msg: '❤️',
                    backgroundColor: Colors.transparent,
                    gravity: ToastGravity.CENTER,
                    fontSize: 50,
                    toastLength: Toast.LENGTH_SHORT,
                  );
                  liked();
                },
                child: (img.isEmpty || img == 'null')
                    ? Image.asset('assets/feedmage.jpg')
                    : Image.network(img),
              ),
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => Account(username: postby),
                  ));
            },
            child: Padding(
              padding: const EdgeInsets.only(left: 10, top: 10),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.pinkAccent,
                    backgroundImage: (profilepic.isEmpty)
                        ? AssetImage('assets/defaultpic.png')
                        : AssetImage('assets/feedmage.jpg'),
                    radius: 15,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        postby,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        '${DateFormat('MMM').format(DateTime(0, int.parse(widget.value.substring(4, 6))))} ${widget.value.substring(6, 8)}',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 15),
                  child: Text(
                    '${likes.length} likes • ${comments.length} comments',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        liked();
                      },
                      icon: Icon(
                        (isliked)
                            ? CupertinoIcons.heart_fill
                            : CupertinoIcons.heart,
                        color: (isliked) ? Colors.redAccent : Colors.white,
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(
                        CupertinoIcons.chat_bubble,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(
                        CupertinoIcons.bookmark,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
