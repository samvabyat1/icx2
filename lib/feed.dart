// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:icx2/acc.dart';
import 'package:intl/intl.dart';
import 'package:palette_generator/palette_generator.dart';

import 'home.dart';

class Feeditem extends StatefulWidget {
  final String value;
  const Feeditem({super.key, required this.value});

  @override
  State<Feeditem> createState() => _FeeditemState();
}

class _FeeditemState extends State<Feeditem> {
  var postby = '', img = '', profilepic = '', likes = [], comments = [];
  var isliked = false;

  var dcolor = Colors.white;

  void feed() {
    DatabaseReference refp =
        FirebaseDatabase.instance.ref().child('posts').child(widget.value);
    refp.onValue.listen((event) {
      if (mounted) {
        setState(() {
          likes = [];
          comments = [];

          postby = event.snapshot.child('by').value.toString();
          img = event.snapshot.child('img').value.toString();
          if (img.isNotEmpty) {
            getImagePalette(NetworkImage(img));
          }

          for (final child in event.snapshot.child('likes').children) {
            likes.add(child.value.toString());
          }

          if (likes.contains(Home.username)) {
            setState(() {
              isliked = true;
            });
          } else {
            setState(() {
              isliked = false;
            });
          }
          for (final child in event.snapshot.child('comments').children) {
            comments.add(
                {'by': child.key.toString(), 'msg': child.value.toString()});
          }
        });
      }
    });

    DatabaseReference ref =
        FirebaseDatabase.instance.ref().child('users').child(postby);

    ref.onValue.listen((event) {
      if (mounted) {
        setState(() {
          profilepic = (event.snapshot.child('profile').exists)
              ? event.snapshot.child('profile').value.toString()
              : '';
        });
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    feed();
  }

  Future<void> getImagePalette(ImageProvider imageProvider) async {
    final PaletteGenerator paletteGenerator =
        await PaletteGenerator.fromImageProvider(imageProvider);
    if (mounted && paletteGenerator.dominantColor != null) {
      setState(() {
        dcolor = paletteGenerator.dominantColor!.color;
      });
    }
  }

  void liked() {
    if (isliked == false) {
      FirebaseDatabase.instance
          .ref()
          .child('posts')
          .child(widget.value)
          .child('likes')
          .child(Home.username)
          .set(Home.username);
    } else {
      FirebaseDatabase.instance
          .ref()
          .child('posts')
          .child(widget.value)
          .child('likes')
          .child(Home.username)
          .set(null);
    }
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
                onLongPress: () {
                  if (postby == Home.username) {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 25, horizontal: 15),
                        child: OutlinedButton(
                            onPressed: () async {
                              try {
                                FirebaseDatabase.instance
                                    .ref()
                                    .child('users')
                                    .child(Home.username)
                                    .child('posts')
                                    .child(widget.value)
                                    .set(null);

                                FirebaseDatabase.instance
                                    .ref()
                                    .child('posts')
                                    .child(widget.value)
                                    .set(null);

                                await FirebaseStorage.instance
                                    .ref()
                                    .child('posts')
                                    .child(widget.value)
                                    .delete();

                                Fluttertoast.showToast(msg: 'Post deleted');
                                Navigator.pop(context);
                                Navigator.pop(context);
                              } on Exception catch (e) {
                                Fluttertoast.showToast(
                                    msg: 'Something went wrong!');
                              }
                            },
                            style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                side: BorderSide(
                                  color: Colors.redAccent,
                                  width: 3,
                                )),
                            child: Text(
                              'Delete post',
                            )),
                      ),
                    );
                  }
                },
                child: Container(
                  color: dcolor,
                  child: (img.isEmpty || img == 'null')
                      ? Image.asset('assets/feedmage.jpg')
                      : Image.network(img),
                ),
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
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) => Comment(
                            Comments: comments,
                            value: widget.value,
                          ),
                        );
                      },
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

class Comment extends StatefulWidget {
  final List<dynamic> Comments;
  final String value;
  const Comment({super.key, required this.Comments, required this.value});

  @override
  State<Comment> createState() => _CommentState();
}

class _CommentState extends State<Comment> {
  var mycomment = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: (widget.Comments.isEmpty)
          ? Center(
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
                      CupertinoIcons.chat_bubble,
                      color: Colors.purpleAccent,
                      size: 70,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    "No comments",
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
                    "Be the first to comment.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 14,
                    ),
                  )
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: ListView.builder(
                itemCount: widget.Comments.length,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.pink[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: RichText(
                          text: TextSpan(
                              text: '${widget.Comments[index]['by']}: ',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              children: [
                            TextSpan(
                                text: '${widget.Comments[index]['msg']}',
                                style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                ))
                          ])),
                    ),
                  ),
                ),
              ),
            ),
      bottomSheet: Padding(
        padding: const EdgeInsets.only(bottom: 10, right: 10, left: 10),
        child: TextField(
          controller: mycomment,
          style: TextStyle(
            color: Colors.black,
          ),
          decoration: InputDecoration(
            suffixIcon: IconButton(
              onPressed: () {
                FirebaseDatabase.instance
                    .ref()
                    .child('posts')
                    .child(widget.value)
                    .child('comments')
                    .child(Home.username)
                    .set(mycomment.text);

                setState(() {
                  mycomment.text = '';
                });
                Navigator.pop(context);
              },
              icon: ShaderMask(
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
                  CupertinoIcons.paperplane_fill,
                  color: Colors.purpleAccent,
                  size: 30,
                ),
              ),
            ),
            hintText: 'Write a comment',
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
      ),
    );
  }
}
