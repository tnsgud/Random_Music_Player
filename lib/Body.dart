import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:random_music_player/widget/categories.dart';
import 'package:random_music_player/widget/audio_player.dart';
import 'package:random_music_player/widget/music_play_bar.dart';

class Body extends StatefulWidget {
  Body({Key key, this.theme}) : super(key: key);

  final ThemeData theme;

  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  int selectedIndex;
  bool isEmpty;
  Map<String, dynamic> songsMap;
  Random random;
  CustomAudioPlayer audioPlayer;
  CollectionReference cloudStore;

  @override
  void initState() {
    super.initState();
    getData();
    selectedIndex = 0;
    isEmpty = true;
    songsMap = <String, dynamic>{};
    random = Random();
    audioPlayer = CustomAudioPlayer();
    cloudStore = FirebaseFirestore.instance.collection('songs');
  }

  Future<String> get _externalPath async {
    final directory = await getExternalStorageDirectory();
    return directory.path;
  }

  Future<void> getData() async {
    var file = File('../scripts/music.txt');
    var len = await file.readAsLines();
    for (var i = 0; i < len.length; i++) {
      var songMap = <String, dynamic>{};
      await cloudStore.doc('song$i').get().then((doc) {
        songMap = doc.data();
        songsMap['$i'] = songMap;
      }).catchError((error) => print(error));
    }
    setState(() {
      isEmpty = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = widget.theme;
    var media = MediaQuery.of(context);
    var maxWidth = media.size.width;
    var maxHeight = media.size.height;

    return Scaffold(
      backgroundColor: theme.primaryColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: maxWidth,
            padding: EdgeInsets.all(5.0),
            child: Text(
              '내 취향인 가수의 노래',
              style: theme.textTheme.headline3,
              textAlign: TextAlign.start,
            ),
          ),
          Categories(categoriesMap: songsMap, theme: theme),
          TextButton(
            onPressed: () {
              if (audioPlayer.playing == true) {
                audioPlayer.pause();
              } else {
                audioPlayer.play();
              }
            },
            child: Text('youtube url 재생'),
          ),
          TextButton(
            onPressed: () => getData(),
            child: Text('cloud store test'),
          ),
          TextButton(
            onPressed: () async {
              var path = '$_externalPath/${songsMap['9']['title']}.wav';
              await audioPlayer.startPlay('${songsMap['9']['url']}', path);
            },
            child: Text('downlaod music'),
          ),
          Container(
            width: maxWidth - 20,
            child: Card(
              child: Text('SDfdsfsdfds'),
            ),
          )
        ],
      ),
      bottomNavigationBar: // buildBottomNavigationBar(theme),
          Container(
        color: Colors.white,
        width: maxWidth,
        height: maxHeight * 0.18,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            MusicPlayerBar(
              themeData: theme,
              songsMap: songsMap,
              maxWidth: maxWidth,
              maxHeight: maxHeight,
            ),
            buildBottomNavigationBar(theme)
          ],
        ),
      ),
    );
  }

  BottomNavigationBar buildBottomNavigationBar(ThemeData theme) {
    return BottomNavigationBar(
        backgroundColor: theme.primaryColor,
        onTap: (value) {
          setState(() {
            selectedIndex = value;
          });
        },
        selectedItemColor: theme.accentColor,
        unselectedItemColor: Colors.grey,
        currentIndex: selectedIndex,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: '둘러보기'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: '검색'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: '검색'),
        ]);
  }
}
