import 'package:flutter/material.dart';
import 'package:random_music_player/main.dart';

class MusicPlayerBar extends StatefulWidget {
  const MusicPlayerBar(
      {Key key,
      @required this.themeData,
      @required this.maxWidth,
      @required this.maxHeight})
      : super(key: key);

  final ThemeData themeData;
  final num maxWidth;
  final num maxHeight;

  @override
  _MusicPlayerBarState createState() => _MusicPlayerBarState();
}

class _MusicPlayerBarState extends State<MusicPlayerBar> {
  num maxWidth;
  num maxHeight;
  ThemeData themeData;

  @override
  void initState() {
    super.initState();
    maxWidth = widget.maxWidth;
    maxHeight = widget.maxHeight;
    themeData = widget.themeData;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.blue,
        width: maxWidth,
        height: maxHeight * 0.1,
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Row(
            children: [
              // Container(
              //     width: width * 0.15,
              //     child: Image.network(
              //         "https://cdnimg.melon.co.kr/cm2/album/images/105/54/246/10554246_20210325161233_500.jpg?304eb9ed9c07a16ec6d6e000dc0e7d91/melon/resize/282/quality/80/optimize")),
              Container(
                  color: Colors.black,
                  width: maxWidth * 0.73,
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Column(
                      children: [
                        Text('hello world')
                        // Text(
                        //     '${widget.songsMap['1']['singer']} - ${widget.songsMap['1']['title']}')
                      ],
                    ),
                  )),
              Container(
                  width: maxWidth * 0.08,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back_ios),
                    onPressed: true
                        ? () async {
                            print(
                                'audioPlayer => ${MyApp.audioPlayer.playing}');
                            if (MyApp.audioPlayer.playing) {
                              await MyApp.audioPlayer.pause();
                            } else {
                              await MyApp.audioPlayer.play();
                            }
                          }
                        : null,
                  )),
              Container(
                  width: maxWidth * 0.08,
                  child: IconButton(
                      icon: Icon(Icons.play_arrow),
                      onPressed: () {
                        print('play');
                      })),
              Container(
                  width: maxWidth * 0.08,
                  child: IconButton(
                      icon: Icon(Icons.arrow_forward_ios),
                      onPressed: () {
                        print('forward');
                      })),
            ],
          ),
        ));
  }
}
