import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:random_music_player/widget/categories.dart';
import 'package:random_music_player/widget/music_play_bar.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

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
  AudioPlayer audioPlayer;
  Map<String, dynamic> songsMap;
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
    audioPlayer = AudioPlayer();
    songsMap = <String, dynamic>{};
    cloudStore = FirebaseFirestore.instance.collection('songs');

    getData();
  }

  void createPlayList() async {
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

    createPlayList();

    setState(() {
      isEmpty = false;
    });
  }

  Future<void> play(String option, {String deletePath}) async {
    if (option == 'backword') {
    } else if (option == 'forword') {}

    var url = '${songsMap['${idList[index]}']['url']}';
    path =
        '${await _externalPath}/${songsMap['${idList[index]}']['title']}.wav';
    await downloadMP3(url, path);
    var result = await audioPlayer.play(path, isLocal: true);
    print(result);
  }

  String _cleanURL(String fullURL) {
    String res;
    if (fullURL.contains('https://www.youtube.com/watch?v=')) {
      res = fullURL.replaceAll('https://www.youtube.com/watch?v=', '');
    } else if (fullURL.contains('https://m.youtube.com/watch?v=')) {
      res = fullURL.replaceAll('https://m.youtube.com/watch?v=', '');
    } else if (fullURL.contains('https://youtu.be/')) {
      res = fullURL.replaceAll('https://youtu.be/', '');
    } else if (fullURL.length == 11) {
      res = fullURL;
    } else {
      res = 'Unable URL';
    }
    return res;
  }

  Future<void> downloadMP3(String url, String path) async {
    var yt = YoutubeExplode();
    var vid = _cleanURL(url);
    var manifest = await yt.videos.streamsClient.getManifest('$vid');
    var streamInfo = manifest.audioOnly.withHighestBitrate();
    // var size = streamInfo.size;
    await writeStream(streamInfo, '$path');
    print('다운로드 완료');
  }

  Future<void> writeStream(var streamInfo, String path) async {
    if (streamInfo != null) {
      var yt = YoutubeExplode();
      var stream = yt.videos.streamsClient.get(streamInfo);
      var file = File('$path');
      var fileStream = file.openWrite();
      await stream.pipe(fileStream);
      await fileStream.flush();
      await fileStream.close();
    }
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
            padding: EdgeInsets.fromLTRB(20, 5, 5, 5),
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
              print(audioPlayer.state);
              if (audioPlayer.state == PlayerState.PLAYING) {
                audioPlayer.pause();
              } else if (audioPlayer.state == PlayerState.PAUSED) {
                audioPlayer.resume();
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
            child: Text('test audio player music'),
          ),
          // TextButton(
          //   onPressed: () async {
          //     var url = '${songsMap['${idList[index]}']['url']}';
          //     path =
          //         '${await _externalPath}/${songsMap['${idList[index]}']['title']}.wav';
          //     print(url + '\n');
          //     var item = ProgressiveAudioSource(Uri.parse(path));
          //     await audioPlayer.startPlay(url, path);
          //     await playList.add(item);
          //     await audioPlayer.setAudioSource(playList);
          //     await audioPlayer.seekToNext();
          //     await audioPlayer.play();
          //   },
          //   child: Text('play list test button'),
          // ),
          // TextButton(
          //   onPressed: () {
          //     audioPlayer.seekToNext();
          //     audioPlayer.play();
          //   },
          //   child: Text('seek to next'),
          // ),
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
