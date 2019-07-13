import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'home.dart';
import 'register.dart';
import 'cameraTutorial.dart';
import 'camera.dart';
import 'profilepage.dart';
import 'buttons/buttons.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:path/path.dart';
// import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';

final databaseReference = FirebaseDatabase.instance.reference();

void main() => runApp(MaterialApp(initialRoute: '/', routes: {
      '/': (context) {
        return LoginPage();
      },
      '/home': (context) {
        return HomePage();
      },
      /*'/register': (context) {
        return RegisterPage();
      },*/
      '/register/cameraTutorial': (context) {
        return CameraTutorialPage();
      },
      '/register/camera': (context) {
        return CameraApp();
      },
      '/register/camera2': (context) {
        return ProfilePage();
      },
    }));

class LoginPage extends StatefulWidget {
  LoginPage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _LoginPageState createState() => _LoginPageState();
}

class Auth extends StatelessWidget {
  static FirebaseUser test;
  static String stunumber = "";

  static String getemail() {
    return test.email;
    //print("sign out");
  }

  static String getdisplayname() {
    return test.displayName;
    //print("sign out");
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return null;
  }
}

class _LoginPageState extends State<LoginPage> {
///////////////Add google login////////////////

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = new GoogleSignIn();
  int count = 1;

  //GoogleSignInAccount googleSignInAccount;

  int flag = 0;

  Future<FirebaseUser> _signIn() async {
    GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();

    print("123");

    GoogleSignInAuthentication gSA = await googleSignInAccount.authentication;
    FirebaseUser user = await _auth.signInWithGoogle(
        idToken: gSA.idToken, accessToken: gSA.accessToken);

    if (user.email.substring(8) == "@mail.fcu.edu.tw")
      flag = 1;
    else
      flag = 0;

    Auth.test = user;

    print("User Name : ${user.email.substring(8)}");
    print("User Name : ${user.displayName}");
    print("Email : ${user.email}");

    createRecord();

    return user;
  }

  void _signOut() {
    googleSignIn.signOut();
    flag = 0;

    print("sign out");
  }

  void getnumber() {
    databaseReference.child('number').once().then((DataSnapshot snapshot) {
      Auth.stunumber='';
      Auth.stunumber = snapshot.value.toString();
      print(Auth.stunumber);
    });
  }

  void updatenumber(int num) {
    databaseReference.update({'number': num});
  }

  void createRecord() {
    int same = 0;

    
    try {
      getnumber();
      var current = int.parse(Auth.stunumber, radix: 10);
      for (int i = 0; i < current; i++) {
        
        var temp = i.toString(); 
        databaseReference.child('stu').child(temp).child('email').once().then((DataSnapshot snapshot) {
          String check = snapshot.toString();
          print('qweqeqweqw: '+current.toString());
          if (Auth.getemail() == check) same = 1;
        });
      }

      if (same == 0) {
      //var current = int.parse(Auth.stunumber, radix: 10);
      current++;
      String update = current.toString();

      databaseReference
          .child("stu")
          .child(update)
          .set({'email': Auth.getemail(), 'name': Auth.getdisplayname()});
      updatenumber(current);
    }
    } on FormatException catch (e) {
      print(e);
    }

    
  }

  ///

  int loginType = 0;
  List<String> loginTypeArray = ['學生登入', '教師登入'];
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    debugPaintSizeEnabled = false;
    return Scaffold(
      resizeToAvoidBottomPadding: false, // prevent overflow while input
      body: Container(
        color: Color(0xFF373C7E),
        child: SafeArea(
          child: Column(
            // padding: EdgeInsets.only(left: 30.0, right: 30.0),
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  child: Center(
                      child: Text('臉部點名系統',
                          style: TextStyle(color: Colors.white, fontSize: 36))),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: Stack(
                    alignment: Alignment.topCenter,
                    overflow: Overflow.visible,
                    children: [
                      Card(
                        margin: EdgeInsets.only(top: 25.0),
                        elevation: 2.0,
                        shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(20.0)),
                        child: Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: Column(
                            children: [
                              SimpleRoundButton(
                                buttonText: Text('LOGIN',
                                    style: TextStyle(
                                        fontSize: 17, color: Colors.white)),
                                backgroundColor: Color(0xFF4B4BD8),
                                onPressed: () {
                                  _signIn()
                                      .then((FirebaseUser user) => print(user))
                                      .catchError((e) => print(e));
                                  //createRecord();
                                  print("login pressed");
                                },
                              ),
                              SimpleRoundButton(
                                buttonText: Text('LOGOUT',
                                    style: TextStyle(
                                        fontSize: 17, color: Colors.white)),
                                backgroundColor: Color(0xFF4B4BD8),
                                onPressed: () {
                                  _signOut();
                                  print("logout pressed");
                                },
                              ),
                              SimpleRoundButton(
                                buttonText: Text('點名',
                                    style: TextStyle(
                                        fontSize: 17, color: Colors.white)),
                                backgroundColor: Color(0xFF4B4BD8),
                                onPressed: () {
                                  Navigator.pushNamed(context, '/home');
                                },
                              ),
                              Container(
                                padding: EdgeInsets.only(bottom: 30.0),
                                child: SimpleRoundButton(
                                  buttonText: Text('SETFACEINFO',
                                      style: TextStyle(
                                          fontSize: 17, color: Colors.white)),
                                  backgroundColor: Color(0xFF4B4BD8),
                                  onPressed: () {
                                    print("register pressed");

                                    if (flag == 1) {
                                      Navigator.pushNamed(
                                          context, '/register/cameraTutorial');
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        child: FlatButton(
                            padding: EdgeInsets.symmetric(
                                horizontal: 40, vertical: 10),
                            onPressed: () {
                              setState(() {
                                loginType += 1;
                                loginType %= 2;
                              });
                            },
                            shape: new RoundedRectangleBorder(
                                side: BorderSide(
                                    color: (loginType == 0)
                                        ? Colors.indigoAccent[400]
                                        : Colors.pink[400],
                                    width: 2,
                                    style: BorderStyle.solid),
                                borderRadius: new BorderRadius.circular(30.0)),
                            color: Colors.white,
                            child: Text(loginTypeArray[loginType],
                                style: TextStyle(
                                    fontSize: 22,
                                    color: (loginType == 0)
                                        ? Colors.indigoAccent[400]
                                        : Colors.pink[400]))),
                      ),
                    ]),
              ),
              Expanded(
                child: Container(
                  alignment: Alignment.center,
                  // padding: EdgeInsets.only(top: 30.0),
                  child: Center(
                      child: Text('Power by Google Facenet',
                          style: TextStyle(color: Colors.white, fontSize: 16))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
