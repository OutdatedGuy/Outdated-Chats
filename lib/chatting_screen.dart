import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_demo/chat-msg.dart';
import 'package:supercharged/supercharged.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  ChatScreen(
      {required this.group,
      required this.groupTheme,
      required this.title,
      required this.user});

  final String group;
  final String title;
  final groupTheme;
  final user;

  @override
  _ChatScreenState createState() => _ChatScreenState(
        group: group,
        title: title,
        groupTheme: groupTheme,
        user: user,
      );
}

class _ChatScreenState extends State<ChatScreen> {
  String group;
  String title;
  final groupTheme;
  var user;

  _ChatScreenState({
    required this.group,
    required this.groupTheme,
    required this.title,
    required this.user,
  });

  dynamic counter;
  dynamic value;
  bool firstScroll = true;
  var documentReference;

  TextEditingController msgController = TextEditingController();
  ScrollController _scrollController = ScrollController();
  var _subscription;

  void addData(String msg) async {
    msg = msg.trim();
    if (msg.isEmpty) return;

    var newMsg = {
      'senderId': user["userId"],
      'senderName': user["displayName"],
      'senderRef': user["userRef"],
      'text': msg,
      'timeStamp': DateTime.now().toLocal(),
    };
    documentReference.update({
      "messages": FieldValue.arrayUnion([newMsg]),
    });

    msgController.clear();
  }

  void fetchData() async {
    CollectionReference collectionReference =
        FirebaseFirestore.instance.collection("chats");
    documentReference = collectionReference.doc(group);
    _subscription =
        collectionReference.snapshots().listen((querySnapshot) async {
      value = await documentReference.get();
      dynamic allMsg = value.data();
      // print(allMsg);
      setState(() {
        counter = allMsg["messages"];
      });
      if (!firstScroll && counter.length > 0) {
        Future.delayed(Duration(milliseconds: 300), () {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            curve: Curves.easeOut,
            duration: const Duration(milliseconds: 300),
          );
        });
      }
    }, cancelOnError: true);
  }

  isloading() {
    if (value == null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CircularProgressIndicator(),
        ],
      );
    } else {
      if (firstScroll) {
        // set timeout to scroll to bottom
        Future.delayed(Duration(milliseconds: 10), () {
          _scrollController.jumpTo(
            _scrollController.position.maxScrollExtent,
          );
          firstScroll = false;
        });
      }
      return ListView.builder(
        controller: _scrollController,
        itemCount: counter.length,
        padding: EdgeInsets.only(top: 20),
        itemBuilder: (context, index) {
          // print(counter[index]);
          return Message(
            message: counter[index],
            user: user,
          );
        },
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: groupTheme["textColor"].toString().toColor(),
          ),
        ),
        iconTheme: IconThemeData(
          color: groupTheme["textColor"].toString().toColor(),
        ),
        backgroundColor: groupTheme["bgColor"].toString().toColor(),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black87,
        child: Column(
          children: <Widget>[
            Expanded(
              child: Container(
                height: MediaQuery.of(context).size.height * 0.35,
                child: isloading(),
              ),
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.only(
                    left: 10,
                    top: 4,
                    bottom: 4,
                  ),
                  width: MediaQuery.of(context).size.width * 0.80,
                  child: TextField(
                    maxLines: null,
                    controller: msgController,
                    decoration: InputDecoration(
                      labelText: 'Enter your message',
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      // set text color to white
                      labelStyle: TextStyle(color: Colors.white),
                    ),
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(4.0),
                  width: MediaQuery.of(context).size.width * 0.2,
                  child: SizedBox(
                    child: FloatingActionButton(
                      onPressed: () {
                        addData(msgController.text);
                        fetchData();
                      },
                      tooltip: 'Send',
                      child: Icon(Icons.send),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
    msgController.dispose();
    _subscription.cancel();
  }
}
