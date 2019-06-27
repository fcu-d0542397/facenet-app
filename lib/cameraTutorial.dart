import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'camera.dart' as camera;

class CameraTutorialPage extends StatelessWidget {
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
                      child: Text('臉部擷取使用教學',
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
                    child: Stack(alignment: Alignment.bottomRight, children: <
                        Widget>[
                      _tutorialBody(context),
                      Padding(
                        padding: EdgeInsets.all(20),
                        child: FlatButton(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          child: Text('Next',
                              style:
                                  TextStyle(fontSize: 17, color: Colors.white)),
                          color: Colors.indigoAccent,
                          shape: new RoundedRectangleBorder(
                              side: BorderSide(color: Colors.indigoAccent),
                              borderRadius: new BorderRadius.circular(30.0)),
                          onPressed: () async {
                            print("next step pressed");
                            await camera.init();
                            Navigator.pushNamed(context, '/register/camera');
                          },
                        ),
                      ),
                    ]),
                  ),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tutorialBody(BuildContext context) {
    return Container(
        alignment: Alignment.topCenter,
        padding: EdgeInsets.all(40),
        child: new RichText(
          text: new TextSpan(
            style: new TextStyle(
              fontSize: 18,
              height: 1.3,
              color: Colors.grey[700],
            ),
            children: <TextSpan>[
              new TextSpan(text: '將開始進行臉部照片擷取\n請將臉部對齊標線後\n連續拍攝30張臉部照片\n'),
              new TextSpan(
                  text: '注意事項：\n',
                  style: TextStyle(fontWeight: FontWeight.bold, height: 2)),
              new TextSpan(
                  text: '1. 請在光源充足的地方進行拍攝\n2. 拍攝時請稍微移動臉部讓相機拍到左右側臉以提升辨識能力\n'),
              new TextSpan(text: '3. 拍攝結束後照片將會上傳至系統'),
            ],
          ),
        ));
  }
}
