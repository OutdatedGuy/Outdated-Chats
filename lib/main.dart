import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:flutter/material.dart';
import 'groups.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    Phoenix(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Outdated Chats',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  User? user;

  var _subscription;

  Future<bool> logUserToFirestore(user) async {
    CollectionReference collectionReference =
        FirebaseFirestore.instance.collection("users");

    // check if user exists in database
    DocumentSnapshot documentSnapshot =
        await collectionReference.doc(user.uid).get();

    bool userExists = true;
    // if user doesn't exist, add user to database
    if (!documentSnapshot.exists) {
      dynamic userref = collectionReference.doc(user.uid).set({
        "email": user.email,
        "emailVerified": user.emailVerified,
        "phoneNumber": user.phoneNumber,
        "photoURL": user.photoURL,
        "displayName": user.displayName,
        "userId": user.uid,
        "userRef": collectionReference.doc(user.uid),
        "userGroups": [
          FirebaseFirestore.instance
              .collection("chats")
              .doc("3k06jMjjlTrn8X2aA2NX"),
        ],
      });

      if (userref == null) {
        userExists = false;
      }
    }

    return userExists;
  }

  Future _signIn() async {
    _subscription.cancel();
    GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
    GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount!.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    final UserCredential authResult =
        await firebaseAuth.signInWithCredential(credential);

    user = authResult.user;

    assert(!user!.isAnonymous);

    final User currentUser = firebaseAuth.currentUser!;
    assert(user!.uid == currentUser.uid);

    setState(() {
      user = user;
    });

    if (await logUserToFirestore(user)) {
      gotoGroupsPage(user);
    }
  }

  gotoGroupsPage(User? user) async {
    if (user != null) {
      dynamic userInfo = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      userInfo = await userInfo.data();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MyGroups(
            user: userInfo,
            currentUser: user,
          ),
        ),
      );
    }
  }

  @override
  // check if user is already signed in
  void initState() {
    super.initState();
    _subscription = firebaseAuth.authStateChanges().listen((User? myUser) {
      setState(() {
        user = myUser;
      });
      gotoGroupsPage(myUser);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('LOGIN'),
        centerTitle: true,
        backgroundColor: Colors.purple[400],
      ),
      body: user != null
          ? Container(
              // display loading screen
              color: Colors.black87,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : Container(
              width: double.infinity,
              color: Colors.black87,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SignInButton(
                    Buttons.Google,
                    text: "SignIn with Google",
                    onPressed: () {
                      _signIn();
                    },
                  ),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _subscription.cancel();
  }
}
