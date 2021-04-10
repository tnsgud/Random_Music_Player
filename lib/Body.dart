import 'dart:io';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class Body extends StatefulWidget {
  Body({Key key, this.theme}) : super(key: key);

  final ThemeData theme;

  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  int selectedIndex = 0;
  bool isEmpty = false;
  var songsMap = Map<String, dynamic>();
  AudioPlayer audioPlayer = AudioPlayer();
  var cloudStore = FirebaseFirestore.instance.collection("songs");

  void play(String path) async {
    var durataion = audioPlayer.setFilePath("$path");
    audioPlayer.play();
  }

  Future<String> get _externalPath async {
    final directory = await getExternalStorageDirectory();
    return directory.path;
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
    var size = streamInfo.size;
    writeStream(streamInfo, '$path');
    print("다운로드 완료");
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

  void getData() async {
    for (int i = 0; i < 10; i++) {
      var songMap = Map<String, dynamic>();
      await cloudStore.doc("song$i").get().then((doc) {
        songMap = doc.data();
        songsMap['$i'] = songMap;
      }).catchError((error) => print(error));
    }
    setState(() {
      isEmpty = true;
    });
  }

  @override
  void initState() {
    getData();
    super.initState();
    // print(songsMap);
  }

  @override
  Widget build(BuildContext context) {
    var theme = widget.theme;
    var media = MediaQuery.of(context);
    var width = media.size.width;
    var height = media.size.height;
    // cloudStore = widget.store;
    return Scaffold(
      backgroundColor: theme.primaryColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
            child: Text(
              "내 취향인 가수의 노래",
              style: theme.textTheme.headline3,
            ),
          ),
          TasteCategories(cartegoriesMap: songsMap, theme: theme),
          TextButton(
            child: Text("youtube url 재생"),
            onPressed: () {
              if (audioPlayer.playing == true) {
                audioPlayer.pause();
              } else {
                audioPlayer.play();
              }
            },
          ),
          TextButton(
            child: Text("cloud store test"),
            onPressed: () => getData(),
          ),
          TextButton(
            child: Text("downlaod music"),
            onPressed: () async {
              var path = "${await _externalPath}/${songsMap['9']['title']}.wav";
              await downloadMP3("${songsMap['9']['url']}", path);
              play(path);
            },
          ),
        ],
      ),
      bottomNavigationBar: Container(
        width: width,
        height: height * 0.3,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [musicPlayerBar(theme), buildBottomNavigationBar(theme)],
        ),
      ),
    );
    ;
  }

  Widget musicPlayerBar(ThemeData theme) {
    return Row();
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
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "홈"),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "둘러보기"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "검색"),
        ]);
  }
}

class TasteCategories extends StatefulWidget {
  TasteCategories({Key key, this.cartegoriesMap, this.theme}) : super(key: key);

  Map<String, dynamic> cartegoriesMap;
  ThemeData theme;

  @override
  _TasteCategoriesState createState() => _TasteCategoriesState();
}

class _TasteCategoriesState extends State<TasteCategories> {
  List<String> cartegoriesList = [];

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context);
    var fwidth = media.size.width;
    var fheight = media.size.height;

    if (0 < cartegoriesList.length) {
      for (var i = 0; i < widget.cartegoriesMap.length; i++) {
        cartegoriesList.removeAt(0);
      }
    }

    for (var i = 0; i < widget.cartegoriesMap.length; i++) {
      cartegoriesList.add(widget.cartegoriesMap['$i']['title']);
    }

    return ListTile(
      title: Padding(
        padding: EdgeInsets.all(5),
        child: SizedBox(
          height: fheight * 0.2,
          child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: cartegoriesList.length,
              itemBuilder: (context, index) =>
                  buildCategory(index, fwidth, fheight)),
        ),
      ),
      onTap: () {},
    );
  }

  Widget buildCategory(int index, var width, var height) {
    return Container(
        width: width * 0.3,
        height: height * 0.15,
        child: TextButton(
            onPressed: () {
              for (int i = 0; i < widget.cartegoriesMap.length; i++) {
                if (cartegoriesList[9] ==
                    widget.cartegoriesMap['$i']['title']) {}
              }
            },
            child: Column(
              children: [
                Image.network(
                    "https://cdnimg.melon.co.kr/cm2/album/images/105/54/246/10554246_20210325161233_500.jpg?304eb9ed9c07a16ec6d6e000dc0e7d91/melon/resize/282/quality/80/optimize"),
                Text(
                  cartegoriesList[index],
                  maxLines: 2,
                  overflow: TextOverflow.fade,
                  softWrap: true,
                  textAlign: TextAlign.center,
                  style: widget.theme.textTheme.bodyText2,
                ),
              ],
            )
            // child: Image.asset("assets/images/RandomPlayIcon-nobg.png"),
            ));
  }
}
