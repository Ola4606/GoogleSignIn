import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebasefirebaseAuth/firebasefirebaseAuth.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() => runApp(
    MaterialApp(debugShowCheckedModeBanner: false, home: LoginPageWidget()));

class LoginPageWidget extends StatefulWidget {
  @override
  LoginPageWidgetState createState() => LoginPageWidgetState();
}

class LoginPageWidgetState extends State<LoginPageWidget> {
  GoogleSignIn googleSignIn = GoogleSignIn();
  FirebaseAuth firebaseAuth;

  bool userSignedIn = false;

  isUserSignedInWithGoogle() async {
    var userSignedIn = await googleSignIn.isSignedIn();

    setState(() {
      userSignedIn = userSignedIn;
    });
  }

  void loadApp() async {
    FirebaseApp defaultApp = await Firebase.initializeApp();
    firebaseAuth = FirebaseAuth.instanceFor(app: defaultApp);
    isUserSignedInWithGoogle();
  }

  @override
  void initState() {
    super.initState();
     loadApp();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            padding: EdgeInsets.all(50),
            child: Align(
                alignment: Alignment.center,
                child: 
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child:
                FlatButton(
                    onPressed: () {
                      onGoogleSignIn(context);
                    },
                    color: userSignedIn ? Colors.green : Colors.blueAccent,
                    child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Icon(Icons.account_circle, color: Colors.white),
                            SizedBox(width: 10),
                            Text(
                                userSignedIn
                                    ? 'Logged In'
                                    : 'Login with Google',
                                style: TextStyle(color: Colors.white))
                          ],
                        ))))
                        )));
  }

  Future<User> _handleSignIn() async {
    User user;
    bool userSignedIn = await googleSignIn.isSignedIn();

    setState(() {
      userSignedIn = userSignedIn;
    });

    if (userSignedIn) {
      user = firebaseAuth.currentUser;
    } else {
      final GoogleSignInAccount googleUser = await googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      user = (await firebaseAuth.signInWithCredential(credential)).user;
      userSignedIn = await googleSignIn.isSignedIn();
      setState(() {
        userSignedIn = userSignedIn;
      });
    }

    return user;
  }

  void onGoogleSignIn(BuildContext context) async {
    User user = await _handleSignIn();
    var userSignedIn = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => UserWidget(user, googleSignIn)),
    );

    setState(() {
      userSignedIn = userSignedIn == null ? true : false;
    });
  }
}

class UserWidget extends StatelessWidget {
  GoogleSignIn googleSignIn;
  User currentUser;

  UserWidget(User user, GoogleSignIn signIn) {
    currentUser = user;
    googleSignIn = signIn;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 2,
        ),
        body: Container(
            color: Colors.white,
            padding: EdgeInsets.all(50),
            child: Align(
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    CircleAvatar(
                      backgroundColor: Colors.redAccent,
                        child: Image.network(currentUser.photoURL,
                            width: 100, height: 100, fit: BoxFit.cover)),
                    SizedBox(height: 20),
                    Text('Hi,', textAlign: TextAlign.center),
                    Text(currentUser.displayName + 'you just logged in with Google',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 25)),
                    SizedBox(height: 20),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                                          child: FlatButton(
                          
                          onPressed: () {
                            googleSignIn.signOut();
                            Navigator.pop(context, false);
                          },
                          color: Colors.pink,
                          child: Padding(
                              padding: EdgeInsets.all(10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Text('Log out with Google',
                                      style: TextStyle(color: Colors.white))
                                ],
                              ))),
                    )
                  ],
                ))));
  }
}

