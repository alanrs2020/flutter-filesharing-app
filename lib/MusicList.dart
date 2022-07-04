
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:just_audio/just_audio.dart';
import 'globals.dart' as globals;

class MusicList extends StatefulWidget{

  final ValueChanged<Map> parentAction;
  MusicList({Key key,this.parentAction}) : super(key: key);  @override
  _MusicListState createState() => _MusicListState();
}
List<SongInfo> files = [];

class _MusicListState extends State<MusicList> {

  final FlutterAudioQuery audioQuery = FlutterAudioQuery();

  _fetchMusicFiles() async {
    List<SongInfo> songs = await audioQuery.getSongs();
    files = songs;
    if (mounted) {
      setState(() {
       files.add(files[4]);
      });
    }
  }
  AudioPlayer audioPlayer = AudioPlayer();
  var myIcon = Icons.play_arrow;
  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }
  static final _kAdIndex = 4;
  NativeAd _ad;
  bool _isAdLoaded = false;

  Future<void> playorpause(int selectedItem) async {
    await audioPlayer.setFilePath(files[selectedItem].filePath);


    if(audioPlayer.playing){
      await audioPlayer.stop();
    }else{
      await audioPlayer.play();
    }

  }

 static bool isSelected = false;
  bool isPlaying = false;



  @override
  void initState() {
    super.initState();
    _fetchMusicFiles();
    ///Ad
      // TODO: Create a NativeAd instance
      _ad = NativeAd(
        adUnitId: "ca-app-pub-8379180632315258/1266776565",
        factoryId: 'listTile',
        request: AdRequest(),
        listener: NativeAdListener(
          onAdLoaded: (_) {
            setState(() {
              _isAdLoaded = true;
            });
          },
          onAdFailedToLoad: (ad, error) {
            // Releases an ad resource when it fails to load
            ad.dispose();

            print('Ad load failed (code=${error.code} message=${error.message})');       },
        ),
      );

      _ad.load();
    }
  _sizeOfSong(String file) {
    var sizeInBytes = int.parse(file);

    double _size = sizeInBytes / (1000*1000);
    String megaBytes = _size.toString().split(".").first;
    if(megaBytes == "0"){
      megaBytes = _size.toString().split(".").last.substring(0,3)+" KB";
    }else{
      megaBytes = _size.toString().substring(0,4)+" MB";
    }
    return megaBytes;
  }
  var selecteditems;
  static var count = 0;
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return files.isEmpty ? Center(
        child: Text("0 Audio files found.")) :
    ListView.builder(
      itemCount: files.length,
      primary: true,
      itemBuilder: (BuildContext context, int index) {

      if(globals.MusicList[index] == null){
        //count=0;
        globals.MusicList[index] = false;
        isSelected = false;
      }else{
        if(globals.MusicList[index] == true){
             count++;
             isSelected = true;

        }
      }
      if (_isAdLoaded && index == _kAdIndex) {
    return Container(
    child: AdWidget(ad: _ad),
    height: 80.0,
    alignment: Alignment.center,
    );
    } else {

        return Container(
          color: Color.fromARGB(255, 51, 51, 51),
          padding: EdgeInsets.all(5),
          //color: Color.fromARGB(255, 55, 55, 55),
           child: Card(
             shape: RoundedRectangleBorder(
               borderRadius: BorderRadius.circular(20)
             ),
                color: Color.fromARGB(255, 51, 51, 51),
                elevation: 10,
                shadowColor: Colors.black,
                child: Column(
                  children: [
                    !isSelected ? new ListTile(
                      title: Text(files[index].title,style: TextStyle(color: Colors.cyan),),
                      leading:Card(
                        color: Color.fromARGB(255, 51, 51, 51),
                        child: Icon(Icons.music_note_outlined,color: Colors.cyan,size: 40,),
                        elevation: 4,
                        shadowColor: Colors.black,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(35)
                        ),
                      ),
                      subtitle: Text(_sizeOfSong(files[index].fileSize) +
                          "   ${getDuration(int.parse(files[index].duration))}",style: TextStyle(color: Colors.black)),
                      trailing: isPlaying ? index == selecteditems
                          ? Card(
                        clipBehavior: Clip.hardEdge,
                        child: Icon(Icons.pause_circle_filled_outlined,color: Colors.amberAccent,size: 40,),
                        elevation: 5,
                        color: Color.fromARGB(255, 51, 51, 51),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25)
                        ),
                      )
                          : Card(
                        clipBehavior: Clip.hardEdge,
                        child: Icon(Icons.play_circle_outline_outlined,color: Colors.cyan,size: 40,),
                        elevation: 5,
                        color: Color.fromARGB(255, 51, 51, 51),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25)
                        ),
                      ) :
                      Card(
                        clipBehavior: Clip.hardEdge,
                        child: Icon(Icons.play_circle_outline_outlined,color: Colors.cyan,size: 40,),
                        elevation: 5,
                        color: Color.fromARGB(255, 51, 51, 51),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25)
                        ),
                      ),
                      selected: selecteditems == index,

                      onLongPress: () {
                        setState(() {
                          count = 1;
                          //playorpause(selecteditems);
                          isSelected = true;
                          globals.MusicList[index] = true;
                          Map<String, String> lmap = Map();
                          lmap[files[index].filePath
                              .split("/")
                              .last] = files[index].filePath;
                          widget.parentAction(lmap);
                        });
                      },
                      onTap: () {
                        if (!isSelected && !isPlaying) {
                          setState(() {
                            selecteditems = index;
                            playorpause(selecteditems);
                            isPlaying = true;
                          });
                        }
                        else {
                          setState(() {
                            selecteditems = index;
                            playorpause(selecteditems);
                            isPlaying = false;
                          });
                        }
                      },
                    ) : CheckboxListTile(

                      value: globals.MusicList[index],
                      onChanged: (bool newValue) {
                        setState(() {
                          globals.MusicList[index] = newValue;
                        });

                        Map<String, String> lmap = Map();
                        lmap[files[index].filePath
                            .split("/")
                            .last] = files[index].filePath;
                        widget.parentAction(lmap);
                      },
                      title: Text(files[index].title,style: TextStyle(color: Colors.cyan),),
                      subtitle: Text(_sizeOfSong(files[index].fileSize),style: TextStyle(color: Colors.black)),
                      secondary:Card(
                        color: Color.fromARGB(255, 55, 55, 55),
                        child: Icon(Icons.music_note_outlined,color: Colors.cyan,size: 40,),
                        elevation: 4,
                        shadowColor: Colors.black,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(35)
                        ),
                      ),
                      controlAffinity: ListTileControlAffinity.trailing,
                    ),
                    // checkBoxList(files.length, files[index].displayName, _sizeOfSong(files[index].fileSize),null,files[index].filePath) ,
                  ],
                )
            ),
        );
      }
      },

    );
  }
}
getDuration(int millis){
  double seconds = (millis)/1000;
  String min = (seconds/60).toString().split(".").first;
  if(min == "0"){
    return seconds.toString().substring(0,2)+" s";
  }
  else{
    return (seconds/60).toString().substring(0,3)+" min";
  }
}
