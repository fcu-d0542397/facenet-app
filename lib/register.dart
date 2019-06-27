import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'camera.dart' as camera;

class RegisterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo[700],
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(children: [
              Expanded(
                child: Container(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: Text('註冊帳號',
                          style: TextStyle(fontSize: 30, color: Colors.white))),
                  height: 100,
                ),
              ),
            ]),
            Expanded(
              child: Row(children: [
                Expanded(
                  child: Container(
                    decoration: new BoxDecoration(
                      color: Colors.white,
                      borderRadius: new BorderRadius.only(
                        topLeft: const Radius.circular(30.0),
                        topRight: const Radius.circular(30.0),
                      ),
                    ),
                    child: _formBody(context),
                  ),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _formBody(BuildContext context) {
    return Theme(
        data: ThemeData(
          hintColor: Colors.indigoAccent,
        ),
        child: Stack(alignment: Alignment.bottomRight, children: [
          ListView(children: <Widget>[
            Container(
                padding: EdgeInsets.only(
                    top: 30.0, left: 30.0, right: 30.0, bottom: 10.0),
                child: Text('基本資料', style: TextStyle(color: Colors.grey))),
            Container(
                padding: EdgeInsets.only(top: 20.0, left: 30.0, right: 30.0),
                child: TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: '姓名',
                  ),
                )),
            Container(
                padding: EdgeInsets.only(top: 20.0, left: 30.0, right: 30.0),
                child: TextField(
                  decoration: InputDecoration(
                      border: OutlineInputBorder(), labelText: 'NID'),
                )),
            Container(
                padding: EdgeInsets.only(top: 20.0, left: 30.0, right: 30.0),
                child: TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(), labelText: 'Password'),
                )),
          ]),
          Padding(
            padding: EdgeInsets.all(20),
            child: FlatButton(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text('Next',
                  style: TextStyle(fontSize: 17, color: Colors.indigoAccent)),
              shape: new RoundedRectangleBorder(
                  side: BorderSide(color: Colors.indigoAccent),
                  borderRadius: new BorderRadius.circular(30.0)),
              onPressed: () async {
                print("next step pressed");
                await camera.init();
                Navigator.pushNamed(context, '/camera');
              },
            ),
          )
        ]));
  }
}
