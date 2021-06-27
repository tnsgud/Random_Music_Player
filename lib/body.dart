import 'dart:io';
import 'dart:math';
import 'package:rxdart/rxdart.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:random_music_player/main.dart';
import 'package:path_provider/path_provider.dart';
import 'package:random_music_player/widget/categories.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';

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
  double currentLocation;
  ConcatenatingAudioSource playList;
  Stream<DurationState> _durationState;

  @override
  void initState() {
    super.initState();
    currentSongIndex = 0;
    currentSongPath = null;
    idList = <int>[];
    random = Random();
    isDone = false;
    selectedIndex = 0;
    playList = ConcatenatingAudioSource(children: []);
    currentLocation = 0;

    createPlayList();

    _durationState = Rx.combineLatest2<Duration, PlaybackEvent, DurationState>(
        MyApp.audioPlayer.positionStream,
        MyApp.audioPlayer.playbackEventStream,
        (position, playbackEvent) => DurationState(
            progress: position,
            buffered: playbackEvent.bufferedPosition,
            total: playbackEvent.duration));
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
        ],
      ),
      bottomNavigationBar: musicPlayBar(
        theme: theme,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
      ),
    );
  }

  Widget musicPlayBar({ThemeData theme, double maxWidth, double maxHeight}) {
    var slider = Slider(
      value: isDone ? MyApp.audioPlayer.position.inMilliseconds.toDouble() : 0,
      onChanged: isDone
          ? (newPosition) {
              setState(() {
                MyApp.audioPlayer
                    .seek(Duration(milliseconds: newPosition.round()));
              });
            }
          : null,
      min: 0,
      max: isDone ? MyApp.audioPlayer.duration.inMilliseconds.toDouble() : 1,
      autofocus: true,
    );

    return Container(
      color: Colors.amber,
      padding: EdgeInsets.all(5),
      width: maxWidth,
      height: maxHeight * 0.11,
      child: Row(
        children: [
          Image.network(
            'https://cdnimg.melon.co.kr/cm2/album/images/105/54/246/10554246_20210325161233_500.jpg?304eb9ed9c07a16ec6d6e000dc0e7d91/melon/resize/282/quality/80/optimize',
          ),
          Container(
            padding: EdgeInsets.only(left: 10.0),
            width: maxWidth * 0.45,
            child: Column(
              children: [
                Text(
                  "${MyApp.songsMap['${idList[currentSongIndex]}']['title']} - ${MyApp.songsMap['${idList[currentSongIndex]}']['singer']}",
                  style: theme.textTheme.bodyText1,
                  overflow: TextOverflow.ellipsis,
                ),
                music_progress_bar()
              ],
            ),
          ),
          SizedBox(
            width: maxWidth * 0.1,
            height: maxHeight * 0.1,
            child: IconButton(
              onPressed: isDone
                  ? () async {
                      if (currentSongIndex == 0) {
                        currentSongIndex = idList.length;
                      }
                      currentSongIndex--;
                      await musicControl(
                          option: 'backward', deletePath: currentSongPath);
                    }
                  : null,
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 50,
              ),
            ),
          ),
          SizedBox(
            width: maxWidth * 0.1,
            height: maxHeight * 0.1,
            child: IconButton(
              onPressed: isDone
                  ? () {
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
              icon: MyApp.audioPlayer.playing
                  ? Icon(
                      Icons.pause_rounded,
                      size: 50,
                    )
                  : Icon(
                      Icons.play_arrow_rounded,
                      size: 50,
                    ),
            ),
          ),
          SizedBox(
            width: maxWidth * 0.1,
            height: maxHeight * 0.1,
            child: IconButton(
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
              icon: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 50,
              ),
            ),
          )
        ],
      ),
    );
  }

  StreamBuilder<DurationState> music_progress_bar() {
    return StreamBuilder(
        stream: _durationState,
        builder: (context, snapshot) {
          final durationState = snapshot.data;
          final progress = durationState?.progress ?? Duration.zero;
          final buffered = durationState?.buffered ?? Duration.zero;
          final total = durationState?.total ?? Duration.zero;
          return ProgressBar(
            progress: progress,
            buffered: buffered,
            total: total,
            onSeek: (duration) {
              MyApp.audioPlayer.seek(duration);
            },
            timeLabelLocation: TimeLabelLocation.none,
          );
        });
  }
}

class DurationState {
  const DurationState({
    this.progress,
    this.buffered,
    this.total,
  });
  final Duration progress;
  final Duration buffered;
  final Duration total;
}
