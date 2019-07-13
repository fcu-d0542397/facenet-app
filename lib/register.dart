import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/profilepage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path/path.dart';
import 'profilepage.dart';



class RegisterPage extends StatefulWidget {
  @override
  RegisterPageState createState() {
    return RegisterPageState();
  }
}

class RegisterPageState extends State<RegisterPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = new GoogleSignIn();
  static FirebaseUser test;
  static String useremail;
  //GoogleSignInAccount googleSignInAccount;

  int flag = 0;

  Future<FirebaseUser> _signIn() async {
    GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();

    print("123");

    GoogleSignInAuthentication gSA = await googleSignInAccount.authentication;
    FirebaseUser user = await _auth.signInWithGoogle(
        idToken: gSA.idToken, accessToken: gSA.accessToken);
    flag = 1;

    test = user;
   

    print("User Name : ${user.displayName}");
    print("Email : ${user.email}");

    return user;
  }

  static void email(){

    useremail =test.email;
  }

  static String getemail() {
    
    return test.email;
    //print("sign out");
  }

  void _signOut() {
    googleSignIn.signOut();
    flag = 0;

    print("sign out");
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    String rule = "只限用gomail帳戶登入";
    return Scaffold(
      appBar: new AppBar(
        title: Text("auth test"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Center(
              child: Text(rule),
            ),
            new RaisedButton(
              onPressed: () {
                _signIn()
                    .then((FirebaseUser user) => print(user))
                    .catchError((e) => print(e));
              },
              child: Text('登入'),
              color: Colors.blue,
            ),
            new RaisedButton(
              onPressed: _signOut,
              child: Text('登出'),
              color: Colors.red,
            ),
            new RaisedButton(child: Text('設定臉部資料'), onPressed: () {})
          ],
        ),
      ),
    );
    ;
  }
}
