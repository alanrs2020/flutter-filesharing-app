import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:bytes/webview.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:bytes/AppDirectory.dart';
import 'package:bytes/pdfscanner.dart';
import 'package:bytes/popUpMenu.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';
import 'AppsFragment.dart';
import 'GalleryView.dart';
import 'MusicList.dart';
import 'WifiDirect.dart';
import 'fileSender.dart';
import 'globals.dart' as globals;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';




void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();

  runApp(MyApp());
}


class MyApp extends StatelessWidget {



  @override
  Widget build(BuildContext context) {
    // TODO: implement build
   // globals.buildContext = context;
    return MaterialApp(
      title:'bytes',
      theme:   ThemeData(
        primarySwatch: Colors.cyan,
        primaryColor: Colors.cyan,
          buttonTheme: ButtonThemeData(buttonColor: Colors.cyan,),
          iconTheme: IconThemeData(color: Colors.cyan),
        primaryIconTheme: IconThemeData(color: Colors.cyan),
      ),
      home:  HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
  //wifidirect

}


class HomePage extends StatefulWidget {


  HomePage({Key key}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {


  TextEditingController _controller = TextEditingController();


  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ));

    haveUser();
  }
bool isEnabled = false;
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return  Scaffold(
      backgroundColor: Color.fromARGB(255, 51, 51, 51),
      body: DefaultTabController(
        length: 5,
        child: Scaffold(

            drawer:
            Drawer(

              child: ListView(
                // Important: Remove any padding from the ListView.
                padding: EdgeInsets.zero,
                children: <Widget>[
                  DrawerHeader(duration: Duration(seconds: 5),
                    margin: EdgeInsets.all(30),
                    child:  Image.asset('images/bytes.jpg'),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Color.fromARGB(255, 51, 51, 51),
                    ),
                  ),
                  ListTile(
                    title: Text("Home"),
                    leading:Card(
                      clipBehavior: Clip.hardEdge,
                      child: Icon(Icons.home_outlined,color: Colors.amberAccent,),
                      elevation: 10,
                      color: Color.fromARGB(255, 51, 51, 51),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    title: Text("PDF Scanner"),
                    leading: Card(
                      clipBehavior: Clip.hardEdge,
                      child: Icon(Icons.picture_as_pdf_outlined,color: Colors.cyan,),
                      elevation: 10,
                      color: Color.fromARGB(255, 51, 51, 51),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)
                      ),
                    ),
                    onTap: () async{
                      WidgetsFlutterBinding.ensureInitialized();

                      // Obtain a list of the available cameras on the device.
                      final cameras = await availableCameras();

                      // Get a specific camera from the list of available cameras.
                      final firstCamera = cameras.first;
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder:  (context) => pdfscanner(camera: firstCamera,)));
                    },
                  ),
                  ListTile(
                    title: Text("Add Username"),

                    leading: Card(
                      clipBehavior: Clip.hardEdge,
                      child: Icon(Icons.account_box_outlined,color: Colors.cyan,),
                      elevation: 10,
                      color: Color.fromARGB(255, 51, 51, 51),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)
                      ),
                    ),
                    onTap: () async{
                      Navigator.pop(context);
                     showDialog(context: context, builder: (_)=>
                     AlertDialog(
                       title: Text("Nickname"),
                       content: TextField(
                         decoration: InputDecoration(
                             border: OutlineInputBorder(),
                             hintText: 'Enter your name.'
                         ),
                         controller: _controller,
                       ),
                       actions: [
                         TextButton(onPressed: (){
                           Navigator.pop(context);
                         }, child: Text("Cancel")),
                         TextButton(onPressed: (){
                           if(_controller.text != null){
                             SaveName(_controller.text);
                             Navigator.pop(context);
                           }else{
                             Fluttertoast.showToast(msg: "Empty");
                           }
                         },
                             child: TextButton(onPressed: () {  },
                             child: Text("Save",style: TextStyle(color: Colors.amber),),))
                       ],
                     )
                     );

                    },
                  ),
                  ListTile(
                    title: Text("Connect PC"),
                    leading: Card(
                      clipBehavior: Clip.hardEdge,
                      child: Icon(Icons.desktop_windows,color: Colors.cyan,),
                      elevation: 10,
                      color: Color.fromARGB(255, 51, 51, 51),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)
                      ),
                    ),
                    onTap: () async{
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder:  (context) => WebView()));
                    },
                  ),
                  ListTile(
                    title: Text("Share"),
                    leading: Card(
                      clipBehavior: Clip.hardEdge,
                      child: Icon(Icons.share_outlined,color: Colors.cyan,),
                      elevation: 10,
                      color: Color.fromARGB(255, 51, 51, 51),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Share.share("https://play.google.com/store/apps/details?id=com.bytes");
                    },
                  ),
                  ListTile(
                    title: Text("About"),
                    leading: Card(
                      clipBehavior: Clip.hardEdge,
                      child: Icon(Icons.details_rounded,color: Colors.cyan,),
                      elevation: 10,
                      color: Color.fromARGB(255, 51, 51, 51),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)
                      ),
                    ),
                    onTap: () async{
                      Navigator.pop(context);

                     await canLaunch("https://bytesweb.web.app/about.html") ? await launch("https://bytesweb.web.app/about.html") : throw 'Could not launch about';
                    },
                  ),
                  ListTile(
                    title: Text("Help"),

                    leading: Card(
                      clipBehavior: Clip.hardEdge,
                      child: Icon(Icons.help,color: Colors.cyan,),
                      elevation: 10,
                      color: Color.fromARGB(255, 51, 51, 51),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)
                      ),
                    ),
                    onTap: () async{
                      await canLaunch("https://bytesweb.web.app/help.html") ? await launch("https://bytesweb.web.app/help.html") : throw 'Could not launch help';
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    title: Text("Contact"),

                    leading: Card(
                      clipBehavior: Clip.hardEdge,
                      child: Icon(Icons.mail_outline_rounded,color: Colors.cyan,),
                      elevation: 10,
                      color: Color.fromARGB(255, 55, 55, 55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)
                      ),
                    ),
                    onTap: () async{
                      await canLaunch("mailto: devalanrs@gmail.com") ? await launch("mailto: devalanrs@gmail.com") : throw 'Could not launch mail';
                      Navigator.pop(context);
                    },
                  ),
                 
                ],
              ),
            ),
          appBar:  AppBar(
            backgroundColor: Color.fromARGB(255, 51, 51, 51),
            iconTheme: IconThemeData(color: Colors.cyan),
            centerTitle: true,
          actionsIconTheme: IconThemeData(
              size: 30.0,
              color: Colors.cyan,
          ),
        title: SizedBox(
          height: kToolbarHeight,
          child:  Image.asset('images/bytes.jpg'),
        ),
            actions: [
              Wrap(children:[
                Container(
                  height: kToolbarHeight,
                  width: 40,
                  padding: EdgeInsets.only(right: 30),
                  child: globals.device_Id.isEmpty ? Icon(Icons.online_prediction_outlined,color: Color.fromARGB(255, 51, 51, 51),):
                  Icon(Icons.online_prediction_outlined,color: Colors.green,)
                ),
            Container(
              width: 40,
              height: kToolbarHeight,
              child: Stack(
                children: [
                  Positioned(child: popUpMenu(),right: 0,),
                ],
              ),
            ),
                 // ignore: missing_return


    ],
              ),
      ],
        bottom: TabBar(
          onTap: (index){
            if(index == 4){
              setState(() {
                isEnabled = true;
              });
            }else{
              setState(() {
                isEnabled = false;
              });
            }
          },

          indicatorColor: Colors.cyanAccent,
                indicatorSize: TabBarIndicatorSize.tab,
                isScrollable: true,
                labelColor: Colors.cyan,
                unselectedLabelColor: Colors.cyanAccent,
                tabs:[
                  Tab(icon:Icon(Icons.perm_media_outlined), text: "Media",),
                  Tab(icon: Icon(Icons.library_music_outlined),text: "Audio",),
                  Tab(icon: Icon(Icons.apps_outlined),text: "Apps",),
                  Tab(icon: Icon(Icons.storage_rounded),text: "Storage",),
                  Tab(icon: Icon(Icons.history_outlined),text: "Activity",),
                ],
              ),
          ),

              body: IndexedStack(
                  children:[
                    TabBarView(
                        children: [
                GalleryView(parentAction: addSelected,),
                MusicList(parentAction: addSelected,),
                AppsFragment(parentAction: addSelected,),
                AppDirectory(parentAction: addSelected,),
                WifiDirect(onlineAction: isConnected,),
              ]),
                // ignore: missing_return


      ]),
          floatingActionButton: AnimatedOpacity(
              opacity: isEnabled ? 0.0 : 1.0,
    duration: Duration(milliseconds: 1000),
    child: paths.isNotEmpty ?
               Center(
                child: Row(

             mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Align(
              alignment: Alignment.bottomCenter,
              child: FloatingActionButton(
                onPressed: () async{
                  setState(() {
                    paths.clear();
                    globals.MusicList.clear();
                    globals.ImageList.clear();
                    globals.fileList.clear();
                    globals.VideoList.clear();
                    globals.AppList.clear();
                  });

                },
                child: Icon(Icons.clear),

              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child:
              FloatingActionButton.extended(

                onPressed: () async{
                  if(globals.device_Id.isEmpty){
                    globals.buildContext = context;
                    WifiDirect().invokeS(context);
                  }else {
                   for(var key in paths.keys){
                     String path = paths[key];
                     await Future.delayed(Duration(seconds: 1));
                     sendFile(key, path).sendfile();
                   }
                    setState(() {
                      paths.clear();
                      globals.MusicList.clear();
                      globals.ImageList.clear();
                      globals.fileList.clear();
                      globals.VideoList.clear();
                      globals.AppList.clear();
                    });
                  }
                },
                label: Text(paths.length.toString(),style: TextStyle(color: Colors.cyanAccent),),
                backgroundColor: Color.fromARGB(255, 51, 51, 51),
                icon: Icon(Icons.send_outlined,color: Colors.cyanAccent,),

              ),
            ),
          ],
        ),
      ):
           Center(
            child: Row(

            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Align(
                alignment: Alignment.bottomCenter,
                child: FloatingActionButton(
                  heroTag: "send",
                  child: Column(
                    children: [
                      Icon(Icons.upload_outlined,size: 25,),
                      Text("Send",style: TextStyle(fontSize: 10),),
                    ],
                  ),
                  onPressed: () async {
                      WifiDirect().invokeS(context);
                      globals.buildContext = context;
                  },
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child:
                FloatingActionButton(
                  backgroundColor: Color.fromARGB(255, 51, 51, 51),
                  heroTag: "receive",
                  splashColor: Colors.cyan,
                  child: Column(
                    children: [
                      Icon(Icons.download_outlined,color: Colors.cyanAccent,size: 25,),
                      Text("Receive",style: TextStyle(color: Colors.cyanAccent,fontSize: 10)),
                    ],
                  ),
                  onPressed: () async {
                      globals.buildContext = context;
                      WifiDirect().invokeR(context);
                  },
                ),
              ),
            ],
          ),
          ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        ),
      ),
      );

  }

  void isConnected(String id){
    setState(() {

  });

}
     haveUser() async{
       final path = await _localPath;

    if(path != null){
      print(path);
      File file = File('$path/.name.txt');
      try{
        if(file.existsSync()){
          String name = file.readAsStringSync();
          globals.username = name;
          print(name);
        }
        else{
          globals.username = "bytes " + Random().nextInt(10000).toString();
        }
      }catch(e){

      }
    }
     }
  SaveName(String name) async{
   try {
    final path = await _localPath;
    File file = File('$path/.name.txt');
    setState(() {
    file.writeAsString(name);
    globals.username = name;
    });
    Fluttertoast.showToast(msg: "Successfully Saved");
  }catch(e){

  }
}

  Future<String> get _localPath async {
   const platform = const MethodChannel('storage_access');
   String path;
   await platform.invokeMethod("AppFolder").then((value) async{
     if(value != null){
       path = value;
       print(path);
     }else{
       return null;
     }
   });
   final Directory _appDocDirFolder = Directory(path+"/username");

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


   // ignore: non_constant_identifier_names

   Map<String,String> paths =Map();
  void addSelected(Map path){

    setState(() {
      for (var key in path.keys) {
      if(paths.containsKey(key)){
        paths.remove(key);
      }else{
        paths.addAll(path);
      }
      }
    });

  }

  void getIsEnabled(bool p) {
    setState(() {
      isEnabled = p;
    });
  }





  }

