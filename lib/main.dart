import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'home.dart';
import 'register.dart';
import 'buttons/buttons.dart';
// import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';

void main() => runApp(MaterialApp(initialRoute: '/', routes: {
      '/': (context) {
        return LoginPage();
      },
      '/home': (context) {
        return HomePage();
      },
      '/register': (context) {
        return RegisterPage();
      }
    }));

class LoginPage extends StatefulWidget {
  LoginPage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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
                flex: 3,
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
                              Container(
                                  padding: EdgeInsets.only(
                                      top: 20.0, left: 30.0, right: 30.0),
                                  child: TextField(
                                      decoration:
                                          InputDecoration(labelText: 'NID'))),
                              Container(
                                  padding:
                                      EdgeInsets.only(left: 30.0, right: 30.0),
                                  child: TextField(
                                      obscureText: true,
                                      decoration: InputDecoration(
                                          labelText: 'Password'))),
                              SimpleRoundButton(
                                buttonText: Text('LOGIN',
                                    style: TextStyle(
                                        fontSize: 17, color: Colors.white)),
                                backgroundColor: Color(0xFF4B4BD8),
                                onPressed: () {
                                  print("login pressed");
                                  Navigator.pushNamed(context, '/home');
                                },
                              ),
                              Container(
                                padding: EdgeInsets.only(bottom: 30.0),
                                child: SimpleRoundButton(
                                  buttonText: Text('REGISTER',
                                      style: TextStyle(
                                          fontSize: 17, color: Colors.white)),
                                  backgroundColor: Color(0xFF4B4BD8),
                                  onPressed: () {
                                    print("register pressed");
                                    Navigator.pushNamed(context, '/register');
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
                                    color: Colors.indigoAccent[400],
                                    width: 2,
                                    style: BorderStyle.solid),
                                borderRadius: new BorderRadius.circular(30.0)),
                            color: Colors.white,
                            child: Text(loginTypeArray[loginType],
                                style: TextStyle(
                                    fontSize: 22, color: Color(0xFF4B4BD8)))),
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
