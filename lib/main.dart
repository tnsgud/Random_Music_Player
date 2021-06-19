import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'screens/loding.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:random_music_player/screens/home.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  static Map<String, dynamic> songsMap;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryIconTheme: IconThemeData(color: Colors.purple[800]),
        primaryColor: Colors.white,
        accentColor: Colors.purple[800],
        textTheme: TextTheme(
          headline1: TextStyle(
            color: Colors.black,
            fontSize: 40.0,
            fontWeight: FontWeight.bold,
          ),
          headline2: TextStyle(
            color: Colors.black,
            fontSize: 35.0,
            fontWeight: FontWeight.bold,
          ),
          headline3: TextStyle(
            color: Colors.black,
            fontSize: 30.0,
            fontWeight: FontWeight.bold,
          ),
          headline4: TextStyle(
            color: Colors.black,
            fontSize: 25.0,
            fontWeight: FontWeight.bold,
          ),
          bodyText1: TextStyle(
            color: Colors.black,
            fontSize: 15.0,
            fontWeight: FontWeight.bold,
          ),
          bodyText2: TextStyle(
            color: Colors.black,
            fontSize: 10.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      darkTheme: ThemeData(
        primaryIconTheme: IconThemeData(color: Colors.purple[800]),
        primaryColor: Colors.black,
        accentColor: Colors.purple[800],
        textTheme: TextTheme(
          headline1: TextStyle(
            color: Colors.white,
            fontSize: 40.0,
            fontWeight: FontWeight.bold,
          ),
          headline2: TextStyle(
            color: Colors.white,
            fontSize: 35.0,
            fontWeight: FontWeight.bold,
          ),
          headline3: TextStyle(
            color: Colors.white,
            fontSize: 30.0,
            fontWeight: FontWeight.bold,
          ),
          headline4: TextStyle(
            color: Colors.white,
            fontSize: 25.0,
            fontWeight: FontWeight.bold,
          ),
          bodyText1: TextStyle(
            color: Colors.white,
            fontSize: 15.0,
            fontWeight: FontWeight.bold,
          ),
          bodyText2: TextStyle(
            color: Colors.white,
            fontSize: 10.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottomNavigationBarTheme:
            BottomNavigationBarThemeData(backgroundColor: Colors.black),
      ),
      routes: {
        '/loading': (context) => Loading(),
        '/home': (context) => Home()
      },
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _initialized = false;
  bool _error = false;
  CollectionReference cloudStore;

  Future<void> initializeFlutterFire() async {
    try {
      await Firebase.initializeApp();
      setState(() {
        _initialized = true;
      });
      cloudStore = FirebaseFirestore.instance.collection('songs');
      await createData();
    } catch (e) {
      setState(() {
        _error = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    initializeFlutterFire();
    storagePermission();

    MyApp.songsMap = <String, dynamic>{};
  }

  Future<void> createData() async {
    var docs;
    var index = 0;
    await cloudStore.get().then((value) => docs = value.docs);

    for (var doc in docs) {
      var tmpMap = doc.data();
      MyApp.songsMap['$index'] = tmpMap;
      index++;
    }
  }

  void storagePermission() async {
    var status = await Permission.storage.status;
    if (status.isPermanentlyDenied) {
      await openAppSettings();
    }
    await Permission.storage.request();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    void _showError() {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: theme.primaryColor,
            title: Text(
              'Error',
              style: TextStyle(color: theme.accentColor),
            ),
            content: Text(
              '에러가 발생했습니다.\n인터넷이 켜져있는지 확인해주세요.\n그래도 문제가 있다면 앱을\n재실행 해주시거나\n개발자에게 문의해주세요!',
              style: theme.textTheme.bodyText1,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  '닫기',
                  style: TextStyle(color: theme.accentColor),
                ),
              )
            ],
          );
        },
      );
    }

    if (_error) {
      _showError();
    } else if (!_initialized) {
      return Loading();
    } else {
      Timer(Duration(seconds: 5), () async {
        await Navigator.popAndPushNamed(context, '/home');
      });
    }

    return Loading();
  }
}
