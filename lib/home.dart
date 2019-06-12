import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'camera.dart' as camera;

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<StatefulWidget> {
  int _cIndex = 0;
  final List namelist = [
    {'nid': 'D0542367', 'name': '蔡凱勛'},
    {'nid': 'D0542397', 'name': '時昱安'},
    {'nid': 'D0542592', 'name': '郭政儒'},
    {'nid': 'D0542367', 'name': '陳逸銘'},
    {'nid': 'D0542367', 'name': '白石麻衣'},
    {'nid': 'D0542367', 'name': '西野七瀬'},
  ];

  void _incrementTab(index) {
    setState(() {
      _cIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
          alignment: Alignment.center,
          color: Color(0xFF373C7E),
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: SafeArea(
            child: Column(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Row(children: <Widget>[
                    Expanded(
                      child: Card(
                        shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(10.0)),
                        child: Container(
                            padding: EdgeInsets.all(20),
                            child: Text('計算機結構學\n123')),
                      ),
                    ),
                  ]),
                ),
                Expanded(
                  flex: 4,
                  child: Stack(alignment: Alignment.bottomCenter, children: [
                    ListView.builder(
                      itemCount: namelist.length,
                      itemBuilder: (context, idx) {
                        return Card(
                          color: Colors.white,
                          margin: (idx == namelist.length - 1)
                              ? EdgeInsets.only(bottom: 65)
                              : null,
                          shape: new RoundedRectangleBorder(
                              side: BorderSide(
                                  color: Color(0xFF4B4BD8),
                                  width: 2,
                                  style: BorderStyle.solid),
                              borderRadius: new BorderRadius.circular(10.0)),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Container(
                              height: 80,
                              alignment: Alignment.centerLeft,
                              child: Row(children: <Widget>[
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    child: ClipOval(
                                      child: Image.asset(
                                        'assets/image.jpg',
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: ListTile(
                                    title: Text(namelist[idx]['name']),
                                    subtitle: Text(namelist[idx]['nid']),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: ClipOval(
                                    child: FlatButton(
                                      child: Icon(Icons.person,
                                          color: Colors.black26),
                                      onPressed: () {
                                        print('profile pressed');
                                      },
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: FlatButton(
                                    color: Colors.redAccent,
                                    child: Icon(Icons.directions_run,
                                        size: 20, color: Colors.white),
                                    shape: new RoundedRectangleBorder(
                                        side: BorderSide(
                                            color: Colors.redAccent,
                                            style: BorderStyle.solid),
                                        borderRadius:
                                            new BorderRadius.circular(30.0)),
                                    onPressed: () {
                                      String name = namelist[idx]['name'];
                                      print('absent pressed - $name');
                                    },
                                  ),
                                )
                              ]),
                            ),
                          ),
                        );
                      },
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: FlatButton(
                        shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(30.0)),
                        padding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 50),
                        color: Colors.pinkAccent,
                        child: Text('開始點名',
                            style:
                                TextStyle(fontSize: 20, color: Colors.white)),
                        onPressed: () {
                          print('start pressed');
                          // Navigator.pushNamed(context, '/camera');
                          camera.main();
                        },
                      ),
                    ),
                  ]),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          selectedItemColor: Color(0xFF4B4BD8),
          unselectedItemColor: Colors.black,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          currentIndex: _cIndex,
          type: BottomNavigationBarType.shifting,
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.list), title: new Text('')),
            BottomNavigationBarItem(
                icon: Icon(Icons.person), title: new Text(''))
          ],
          onTap: (index) {
            _incrementTab(index);
          },
        ));
  }
}
