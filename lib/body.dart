import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:random_music_player/main.dart';
import 'package:path_provider/path_provider.dart';
import 'package:random_music_player/widget/categories.dart';
<<<<<<< HEAD
=======
// import 'package:random_music_player/widget/music_play_bar.dart';
>>>>>>> a5be0b85b5733fa831a0a009a5ba67cf2df385b0
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

enum OPTIONS { backword, forword }

class Body extends StatefulWidget {
  Body({Key key, this.theme}) : super(key: key);

  final ThemeData theme;

  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  bool isDone;
  Random random;
  List<int> idList;
  int selectedIndex;
  int currentSongIndex;
  String currentSongPath;
<<<<<<< HEAD
  double currentLocation;
  AudioPlayer audioPlayer;
=======
>>>>>>> a5be0b85b5733fa831a0a009a5ba67cf2df385b0
  ConcatenatingAudioSource playList;

  @override
  void initState() {
    super.initState();
    isDone = false;
    idList = <int>[];
    random = Random();
    selectedIndex = 0;
    currentSongIndex = 0;
    currentSongPath = null;
    playList = ConcatenatingAudioSource(children: []);
    currentLocation = 0;

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

    await MyApp.audioPlayer.setAudioSource(playList, initialIndex: 0);

    await MyApp.audioPlayer.setLoopMode(LoopMode.all);

    setState(() {
      isDone = true;
    });
  }

  Future<String> get _externalPath async {
    final directory = await getExternalStorageDirectory();
    return directory.path;
  }

  Future<void> musicControl({String option, String deletePath}) async {
    await MyApp.audioPlayer.pause();

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

    if (option == 'backward') {
      await MyApp.audioPlayer.seekToPrevious();
    } else if (option == 'forword') {
      await MyApp.audioPlayer.seekToNext();
    }

    setState(() {
      print('Done!');
      isDone = true;
    });
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


          // buildProgressBar(),
        ],
      ),
      bottomNavigationBar: // buildBottomNavigationBar(theme),
          Container(
        color: Colors.white,
        width: maxWidth,
        height: maxHeight * 0.1,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
          ],),)
    );
  }

  Widget musicPlayBar({ThemeData theme, double maxWidth, double maxHeight}) {
    return Container(
        color: Colors.amber,
        padding: EdgeInsets.all(5),
        width: maxWidth,
        height: maxHeight * 0.1,
        child: Row(
          children: [
            Image.network(
              'https://cdnimg.melon.co.kr/cm2/album/images/105/54/246/10554246_20210325161233_500.jpg?304eb9ed9c07a16ec6d6e000dc0e7d91/melon/resize/282/quality/80/optimize',
            ),
            Column(
              children: [
                Text(
                  MyApp.songsMap['${idList[currentSongIndex]}']['title'],
                  style: theme.textTheme.bodyText1,
                ),
                Slider(
                  value: audioPlayer.position.inMilliseconds.toDouble(),

                  onChanged: (newPosition) {
                    setState(() {
                      audioPlayer
                          .seek(Duration(milliseconds: newPosition.round()));
                    });
                  },
                  min: 0,
                  max: audioPlayer.duration.inMilliseconds.toDouble(),
                ),
              ],
            ),
          ],
=======
  Widget MusicPlayerBar(
      {ThemeData themeData, double maxWidth, double maxHeight}) {
    return Container(
        color: Colors.blue,
        width: maxWidth,
        height: maxHeight * 0.1,
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Row(
            children: [
              Container(
                  width: maxWidth * 0.15,
                  child: Image.network(
                      'https://cdnimg.melon.co.kr/cm2/album/images/105/54/246/10554246_20210325161233_500.jpg?304eb9ed9c07a16ec6d6e000dc0e7d91/melon/resize/282/quality/80/optimize')),
              Container(
                  color: Colors.black,
                  width: maxWidth * 0.58,
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Column(
                      children: [Text('hello world')],
                    ),
                  )),
              Container(
                  width: maxWidth * 0.08,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back_ios_rounded),
                    onPressed: isDone
                        ? () async {
                            if (currentSongIndex == 0) {
                              currentSongIndex = idList.length;
                            }
                            currentSongIndex--;
                            await musicControl(
                                option: 'backward',
                                deletePath: currentSongPath);
                          }
                        : null,
                  )),
              Container(
                  width: maxWidth * 0.08,
                  child: IconButton(
                    icon: MyApp.audioPlayer.playing
                        ? Icon(Icons.pause)
                        : Icon(Icons.play_arrow_rounded),
                    onPressed: isDone
                        ? () async {
                            if (MyApp.audioPlayer.playing) {
                              setState(() {
                                MyApp.audioPlayer.pause();
                              });
                            } else {
                              setState(() {
                                MyApp.audioPlayer.play();
                              });
                            }
                          }
                        : null,
                  )),
              Container(
                  width: maxWidth * 0.08,
                  child: IconButton(
                    icon: Icon(Icons.arrow_forward_ios_rounded),
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
                  )),
            ],
          ),
>>>>>>> a5be0b85b5733fa831a0a009a5ba67cf2df385b0
        ));
  }
}
