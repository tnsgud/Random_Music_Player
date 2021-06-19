import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:random_music_player/main.dart';
import 'package:path_provider/path_provider.dart';
import 'package:random_music_player/widget/categories.dart';
import 'package:random_music_player/widget/music_play_bar.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

enum OPTIONS { backword, forword }

class Body extends StatefulWidget {
  Body({Key key, this.theme}) : super(key: key);

  final ThemeData theme;

  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  int currentSongIndex;
  bool isDone;
  String currentSongPath;
  Random random;
  int selectedIndex;
  List<int> idList;
  AudioPlayer audioPlayer;
  ConcatenatingAudioSource playList;

  @override
  void initState() {
    super.initState();
    currentSongIndex = 0;
    currentSongPath = null;
    idList = <int>[];
    random = Random();
    isDone = false;
    selectedIndex = 0;
    audioPlayer = AudioPlayer();
    playList = ConcatenatingAudioSource(children: []);

    createPlayList();
  }

  void createPlayList() async {
    while (idList.length < MyApp.songsMap.length) {
      var id = random.nextInt(MyApp.songsMap.length);
      while (idList.contains(id)) {
        id = random.nextInt(MyApp.songsMap.length);
      }
      idList.add(id);
    }

    for (var key in idList) {
      currentSongPath =
          '${await _externalPath}/${MyApp.songsMap['$key']['title']}.wav';
      await playList.add(AudioSource.uri(Uri.parse(currentSongPath)));
    }

    currentSongPath =
        '${await _externalPath}/${MyApp.songsMap['${idList[0]}']['title']}.wav';
    await downloadMP3(
        '${MyApp.songsMap['${idList[0]}']['url']}', currentSongPath);

    await audioPlayer.setAudioSource(playList, initialIndex: 0);

    await audioPlayer.setLoopMode(LoopMode.all);

    setState(() {
      isDone = true;
    });
  }

  Future<String> get _externalPath async {
    final directory = await getExternalStorageDirectory();
    return directory.path;
  }

  Future<void> musicControl({String option, String deletePath}) async {
    await audioPlayer.pause();

    if (deletePath != null) {
      var file = File(deletePath);
      try {
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        print(e);
      }
    }

    setState(() {
      isDone = false;
    });

    currentSongPath =
        '${await _externalPath}/${MyApp.songsMap['${idList[currentSongIndex]}']['title']}.wav';
    await downloadMP3('${MyApp.songsMap['${idList[currentSongIndex]}']['url']}',
        currentSongPath);

    setState(() {
      print('Done!');
      isDone = true;
    });

    if (option == 'backward') {
      await audioPlayer.seekToPrevious();
    } else if (option == 'forword') {
      await audioPlayer.seekToNext();
    }
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
          MyApp.songsMap.isEmpty
              ? Text('데이터가 없습니다.')
              : Categories(theme: theme),
          TextButton(
            onPressed: isDone
                ? () async {
                    print('audioPlayer => ${audioPlayer.playing}');
                    if (audioPlayer.playing) {
                      await audioPlayer.pause();
                    } else {
                      await audioPlayer.play();
                    }
                  }
                : null,
            child: Text('play or pause'),
          ),
          TextButton(
            onPressed: isDone
                ? () async {
                    if (currentSongIndex == 0) currentSongIndex = idList.length;
                    currentSongIndex--;
                    await musicControl(
                        option: 'backward', deletePath: currentSongPath);
                  }
                : null,
            child: Text('backward'),
          ),
          TextButton(
            onPressed: isDone
                ? () async {
                    if (currentSongIndex == idList.length - 1) {
                      currentSongIndex = -1;
                    }
                    currentSongIndex++;
                    await musicControl(
                        option: 'forword', deletePath: currentSongPath);
                  }
                : null,
            child: Text('forward'),
          ),
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
              songsMap: MyApp.songsMap,
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
