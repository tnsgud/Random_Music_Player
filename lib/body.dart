import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:random_music_player/widget/categories.dart';
import 'package:random_music_player/widget/custom_audio_player.dart';
import 'package:random_music_player/widget/music_play_bar.dart';

class Body extends StatefulWidget {
  Body({Key key, this.theme}) : super(key: key);

  final ThemeData theme;

  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  int index;
  String path;
  bool isEmpty;
  Random random;
  int selectedIndex;
  List<int> idList;
  ConcatenatingAudioSource playList;
  Map<String, dynamic> songsMap;
  CustomAudioPlayer audioPlayer;
  CollectionReference cloudStore;

  @override
  void initState() {
    super.initState();
    index = 0;
    path = null;
    idList = <int>[];
    isEmpty = true;
    random = Random();
    selectedIndex = 0;
    songsMap = <String, dynamic>{};
    audioPlayer = CustomAudioPlayer();
    playList = ConcatenatingAudioSource(children: []);
    cloudStore = FirebaseFirestore.instance.collection('songs');

    audioPlayer.setAudioSource(playList, initialIndex: 0);

    getData();
  }

  void createMusciIdList() {
    while (idList.length < songsMap.length) {
      var id = random.nextInt(songsMap.length);
      while (idList.contains(id)) {
        id = random.nextInt(songsMap.length);
      }
      idList.add(id);
    }

    print(idList);
  }

  Future<String> get _externalPath async {
    final directory = await getExternalStorageDirectory();
    return directory.path;
  }

  Future<void> getData() async {
    var docs;
    var index = 0;
    await cloudStore.get().then((value) => docs = value.docs);

    for (var doc in docs) {
      var songMap = doc.data();
      songsMap['$index'] = songMap;
      index++;
    }

    // await audioPlayer.setAudioSource(
    //     ConcatenatingAudioSource(children: [
    //       AudioSource.uri(Uri.parse(
    //           'https://firebasestorage.googleapis.com/v0/b/music-c5930.appspot.com/o/3.wav?alt=media&token=af960ab3-df45-4ee1-933d-e3b29b846766')),
    //       AudioSource.uri(Uri.parse(
    //           'https://firebasestorage.googleapis.com/v0/b/music-c5930.appspot.com/o/2.wav?alt=media&token=bd1d187f-f3ff-4dc8-9418-c9b56a0dd34f')),
    //       AudioSource.uri(Uri.parse(
    //           'https://firebasestorage.googleapis.com/v0/b/music-c5930.appspot.com/o/1.wav?alt=media&token=1fa8bd5f-e08e-444a-8792-5c4f5eb71ed8'))
    //     ]),
    //     initialIndex: 0);

    createMusciIdList();

    setState(() {
      isEmpty = false;
    });
  }

  Future<void> play(String option, {String deletePath}) async {
    if (audioPlayer.playing) {
      await audioPlayer.stop();
    }
    if (deletePath != null) {
      var file = File(deletePath);
      try {
        await file.delete();
      } catch (e) {
        print(e);
      }
    }

    if (option == 'backward') {
      if (index == 0) {
        index = playList.length;
      }
      index--;
      print(playList[index]);
    } else if (option == 'forward') {
      if (index == playList.length - 1) {
        index = -1;
      }
      index++;
    }

    path =
        '${await _externalPath}/${songsMap['${idList[index]}']['title']}.wav';
    await audioPlayer.startPlay('${songsMap['${idList[index]}']['url']}', path);
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
          isEmpty
              ? Text('데이터가 없습니다.')
              : Categories(categoriesMap: songsMap, theme: theme),
          TextButton(
            onPressed: () {
              print('audioPlayer => ${audioPlayer.playing}');
              if (audioPlayer.playing) {
                audioPlayer.pause();
              } else {
                audioPlayer.play();
              }
            },
            child: Text('play or pause'),
          ),
          TextButton(
            onPressed: () => play('backward', deletePath: path),
            child: Text('backward'),
          ),
          TextButton(
            onPressed: () => play('forward', deletePath: path),
            child: Text('forward'),
          ),
          TextButton(
            onPressed: () => play(''),
            child: Text('play music'),
          ),
          TextButton(
            onPressed: () async {
              var url = '${songsMap['${idList[index]}']['url']}';
              path =
                  '${await _externalPath}/${songsMap['${idList[index]}']['title']}.wav';
              print(url + '\n');
              var item = ProgressiveAudioSource(Uri.parse(path));
              await audioPlayer.startPlay(url, path);
              await playList.add(item);
              await audioPlayer.setAudioSource(playList);
              await audioPlayer.seekToNext();
              await audioPlayer.play();
            },
            child: Text('play list test button'),
          ),
          TextButton(
            onPressed: () {
              audioPlayer.seekToNext();
              audioPlayer.play();
            },
            child: Text('seek to next'),
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
            //buildBottomNavigationBar(theme)
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
