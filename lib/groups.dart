import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:supercharged/supercharged.dart';
import 'chatting_screen.dart';

class MyGroups extends StatelessWidget {
  final user;
  final User currentUser;

  MyGroups({required this.user, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Outdated Chats',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: Groups(
        user: user,
        currentUser: currentUser,
        title: 'GROUPS',
      ),
    );
  }
}

class Groups extends StatefulWidget {
  final title;
  final user;
  final User currentUser;

  Groups({
    Key? key,
    required this.title,
    required this.currentUser,
    required this.user,
  }) : super(key: key);

  @override
  _GroupsState createState() => _GroupsState(
        title: title,
        currentUser: currentUser,
        user: user,
      );
}

class _GroupsState extends State<Groups> {
  var title;
  var user;
  User currentUser;
  List chatLists = [];

  _GroupsState({
    required this.title,
    required this.currentUser,
    required this.user,
  });

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  getgroups() async {
    List groupList = [];
    user["userGroups"].forEach((group) async {
      groupList.add(await group.get());
      setState(() {
        chatLists = groupList;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getgroups();
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
            color: Colors.white,
          ),
        ),
        actions: [
          // adding a signout button on right side
          FloatingActionButton(
            onPressed: () {
              _signOut().then((value) => {
                    Navigator.pop(
                      context,
                    ),
                    Phoenix.rebirth(context),
                  });
            },
            child: Icon(
              Icons.exit_to_app,
            ),
            tooltip: 'Sign Out',
            backgroundColor: Colors.redAccent[400],
            // disable shadow
            elevation: 0.0,
          ),
        ],
        backgroundColor: Colors.redAccent[400],
        centerTitle: true,
      ),
      body: Container(
        color: Colors.black87,
        height: MediaQuery.of(context).size.height,
        child: ListView.builder(
          padding: EdgeInsets.only(top: 15, bottom: 15),
          itemCount: chatLists.length,
          itemBuilder: (context, index) {
            if (chatLists[index]["bannedMembers"].contains(user["userRef"]))
              return Container();
            return Container(
              margin: EdgeInsets.only(bottom: 15),
              decoration: BoxDecoration(
                color: chatLists[index]["groupTheme"]["bgColor"]
                    .toString()
                    .toColor(),
                borderRadius: BorderRadius.circular(25),
              ),
              child: ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                title: Text(
                  chatLists[index]['groupName'],
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: chatLists[index]["groupTheme"]["textColor"]
                        .toString()
                        .toColor(),
                  ),
                ),
                contentPadding: EdgeInsets.all(10),
                subtitle: Text(
                  chatLists[index]['description'],
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: chatLists[index]["groupTheme"]["textColor"]
                        .toString()
                        .toColor(),
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        group: chatLists[index]['groupId'],
                        title: chatLists[index]['groupName'],
                        groupTheme: chatLists[index]['groupTheme'],
                        user: user,
                      ),
                    ),
                  );
                },
                enableFeedback: true,
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    chatLists.clear();
  }
}
