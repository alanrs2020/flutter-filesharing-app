


import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:bytes/document.dart';
import 'package:bytes/video.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:mime/mime.dart';


import 'package:photo_manager/photo_manager.dart';

import 'audio.dart';
import 'home.dart';


class WebView extends StatefulWidget {
  WebView({Key key}) : super(key: key);


  @override
  _WebViewState createState() => _WebViewState();
}

class _WebViewState extends State<WebView> {




  static const platform = const MethodChannel('storage_access');
  bool connected = false;



  String textMesssage = " ";

  final FlutterAudioQuery audioQuery = FlutterAudioQuery();

  List videoList = [];
  List imageList = [];
  List audioList = [];
  List documentList = [];
  static Map musicMap = new Map();

  Future<void> getFiles() async { //asyn function to get list of files

    print('called');
     var result = await PhotoManager.requestPermissionExtend();
    if (result != null) {
      // success
      setState(() {
        textMesssage = "Loading..";
      });
      List<AssetPathEntity> list = await PhotoManager.getAssetPathList(hasAll: true);

      try{
        final assetList = await list[0].getAssetListRange(start: 0, end: 1000);
        for(var asset in assetList){
          if(asset.type == AssetType.image){
            File paths = await getFilePath(asset);
            imageList.add(paths.toString().split(":")[1].trim());
          }else if(asset.type == AssetType.video){
            File paths = await getFilePath(asset);
            videoList.add(paths.toString().split(":")[1].trim());
          }
          else {

          }
        }
      await _fetchMusicFiles();
        setState(() {

        });
      }catch(e){
        print(e);
      }



    } else {
      // fail
      /// if result is fail, you can call `PhotoManager.openSetting();`  to open android/ios applicaton's setting to get permission
      // Fluttertoast.showToast(msg: "Please allow media permission.");
     // print("No result");
      PhotoManager.openSetting();
    }

  }
  _fetchMusicFiles() async {
    List<SongInfo> songs = await audioQuery.getSongs();
    var cout = 0;
    for(var song in songs ){

      if(song.isMusic && song.id != null){
       File path = new  File(song.filePath);
       musicMap["/"+song.id] = path;
       audioList.add(song.id);
      }
      cout++;
      // if(cout == 20){
      //   break;
      // }

    }
   // print(musicMap);


    }

    getDocuments() async{

    await platform.invokeMethod('getDocuments').then((value) {
      if(value != null){
        print("Flutter Paths: "+value.toString());
      }else{
        print("Null Value");
      }
    });

    }

  getFilePath(AssetEntity file)async{
    File path = await file.file;

    return path;

  }
  startServer() async{
    //await getDocuments();
    await getFiles();

    // print("Image Uploaded");
    setState(() {
      textMesssage = "Connecting...";
    });




    // AssetImage image = AssetImage('files/image2.jpg');
    //print(image.assetName+" "+image.package.toString()+" "+image.bundle.toString());
    setState(() {

      HttpServer
          .bind(InternetAddress.anyIPv6, 8081)
          .then((server) async {
        print("Server started port "+server.port.toString());
        String ip = await platform.invokeMethod('getIp').then((value){
          return value;
        });
        textMesssage = "Connected.."+ ip;

        textMesssage = "Go to: http:"+ip+":8081/";
        connected = true;
        server.listen((HttpRequest request) async {


          //print(request.uri.path.replaceAll("%20", " "));
          if(request.uri.path == "/") {
            request.response
              ..headers.set("Content-Type", "text/html")
              ..write(home().getHome(imageList));
            request.response.close();

          }else if(request.uri.path == "/audio"){

            request.response..headers.
            set('Content-Type', 'text/html')..
            write(audio().getAudio(audioList));
            request.response.close();

          }else if(request.uri.path == "/video"){

            request.response..headers.
            set('Content-Type', 'text/html')..
            write(video().getVideos(videoList));

            request.response.close();

          }else if(request.uri.path == "/document"){

            request.response..headers.
            set('Content-Type', 'text/html')..
            write(document().getDocuments(documentList));

            request.response.close();

          }else if(request.uri.path == "/audioLogo"){
            ByteData data = await rootBundle.load('images/music.png');
            File file = await writeToFile(data,'music.png');
            if(file.existsSync()){
              await request.response.addStream(file.openRead());
              request.response.close();
            }else{
              //request.response.close();
            }


          }
          else if(request.uri.path == "/pdfLogo"){
            ByteData data = await rootBundle.load('images/document.png');
            File file = await writeToFile(data,'document.png');
            if(file.existsSync()){
              await request.response.addStream(file.openRead());
              request.response.close();
            }else{
              //request.response.close();
            }


          }else if(request.uri.path == "/logo"){
            ByteData data = await rootBundle.load('images/bytes.jpg');
            File file = await writeToFile(data,'bytes.jpg');
            if(file.existsSync()){
              await request.response.addStream(file.openRead());
              request.response.close();
            }else{
              request.response.close();
            }


          }else{
            try{
            File imageFile = musicMap[request.uri.path];
            if (imageFile is File) {

              print(imageFile.path);

              if (imageFile.existsSync()) {
                dynamic fileStream = await getStream(imageFile);

                  request.response..headers.set("Content-Type",
                        lookupMimeType(imageFile.path.toString()));

                  await request.response.addStream(fileStream);
                  request.response.close();
                }else{
                print("file not found");

              }



            }else if(File(request.uri.path.replaceAll("%20", " ")) is File){
              File imageFile = File(request.uri.path.replaceAll("%20", " "));
              print(imageFile.path);
              if (imageFile.existsSync()) {
                dynamic fileStream = await getStream(imageFile);
                print(fileStream);
                request.response
                  ..headers.set("Content-Type",
                      lookupMimeType(imageFile.path));

                await request.response.addStream(fileStream);
                request.response.close();
              }else{
                request.response.close();
              }
            }else if(File(request.uri.path.replaceAll("%20", " ")) is Directory){

              File directory = new File(request.uri.path.replaceAll("%20", " "));
              directory.readAsLines();
              request.response..headers.set("Content-Type", "text/html");
              request.response.write(directory.readAsBytes());

              request.response.close();
            }
          }catch(e){
          print(e);
          }

          }

        });
      });
    });
  }


  getPath(path){

  }


  Future<String> get _localPath async {

    String path;
    await platform.invokeMethod("AppFolder").then((value) async{
      if(value != null){
        path = value;
        print(path);
      }else{
        return null;
      }
    });
    final Directory _appDocDirFolder = Directory(path+"/temp");

    if (await _appDocDirFolder
        .exists()) { //if folder already exists return path
      return _appDocDirFolder.path;
    } else {
      //if folder not exists create folder and then return its path
      final Directory _appDocDirNewFolder = await _appDocDirFolder.create(
          recursive: true);
      return _appDocDirNewFolder.path;
    }
  }
  writeToFile(ByteData data,String path) async{
    final buffer = data.buffer;
    String tempPath = await _localPath;
    var filePath = tempPath + '/$path'; // file_01.tmp is dump file, can be anything
    if(!File(filePath).existsSync()){
      return new File(filePath).writeAsBytes(
          buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
    }else{
      return File(filePath);
    }
  }

  Future<Stream<List<int>>> getStream(File imageFile) async{
    return imageFile.openRead();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text("Connect PC")
        ),
        body: Container(
        height: 200,
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            Container(
              height: 40,
            ),
            Text(textMesssage,style: TextStyle(fontSize: 30,color: Colors.black),),
            Container(
              height: 40,
            ),


            TextButton(onPressed: startServer, child: Container(
              color: Colors.cyan,
              height: 40,
              width: 60,
              child: Center(child: Text("Connect",style: TextStyle(color: Colors.black)),),
            )),
            Text("Note: PC must connected with same wifi network.",style: TextStyle(color: Colors.pink),),
          ],
        )
        ),

    );
  }



}
