import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'dart:io';
import 'DialogBoxWidget.dart';
import 'globals.dart' as globals;


class WifiDirect extends StatefulWidget {

  final ValueChanged<String> onlineAction;
  WifiDirect({Key key,this.onlineAction}) : super(key: key);

  @override
  _WifiDirectState createState() => _WifiDirectState();

  void invokeDisConnect(BuildContext context){
    _WifiDirectState().disConnect(context);
  }

  void invokeS(BuildContext context) {
    _WifiDirectState().invokeSend(context);

  }

  void invokeR(BuildContext context) {

    _WifiDirectState().invokeReceive(context);

  }


}

class senderProgress{
   String id;
   String title;
  String size;
  String bytes;
  double pValue;

  senderProgress({
    this.id,
    this.title,
    this.size,
    this.bytes,
    this.pValue,
  });
}
class receiverProgress{
   String id;
   String title;
  String size;
  String bytes;
  double pValue;

  receiverProgress({
    this.id,
    this.title,
    this.size,
    this.bytes,
    this.pValue,
  });
}

class _WifiDirectState extends State<WifiDirect> {

  final String userName = globals.username;
  final Strategy strategy = Strategy.P2P_POINT_TO_POINT;
  final String ServiceId = "com.devalanrs.bytes";
  String cId = "0"; //currently connected device ID
  static String tempFile; //reference to the file currently being transferred
  static Map<int, String> map = new Map(); //store filename mapped to corresponding payloadId
  static dynamic items;
  static dynamic ditems;
  String filenam;
  static List Ufiles = [];
  static List Dfiles = [];
  String Uname;
  String Ubytes;
  String Usize;
  double Up;
  double progress;
  double dprogress;
  AdWidget adWidget ,adWidget2,adWidget3;
  static const platform = const MethodChannel('storage_access');
  static final _kAdIndex = 1;
  BannerAdListener listener;
  bool _isAdLoaded = false;
  @override
  void initState() {
    super.initState();
    listener = BannerAdListener(
      // Called when an ad is successfully received.
      onAdLoaded: (Ad ad) {
        setState(() {
          _isAdLoaded = true;
        });
      },
      // Called when an ad request failed.
      onAdFailedToLoad: (Ad ad, LoadAdError error) {
        ad.dispose();
        _isAdLoaded =false;
        print('Ad failed to load: $error');
      },
      // Called when an ad opens an overlay that covers the screen.
      onAdOpened: (Ad ad) => print('Ad opened.'),
      // Called when an ad removes an overlay that covers the screen.
      onAdClosed: (Ad ad) => print('Ad closed.'),
      // Called when an ad is in the process of leaving the application.

      onAdWillDismissScreen: (Ad ad) => print('Left application.'),
    );

    myBanner.load();
    myBanner2.load();
    myBanner3.load();

  }
  final BannerAd myBanner = BannerAd(
    adUnitId: 'ca-app-pub-8379180632315258/8610079961',
    size: AdSize.mediumRectangle,
    request: AdRequest(),
    listener: BannerAdListener(),
  );
  final BannerAd myBanner2 = BannerAd(
    adUnitId: 'ca-app-pub-8379180632315258/5374446497',
    size: AdSize.mediumRectangle,
    request: AdRequest(),
    listener: BannerAdListener(),
  );
  final BannerAd myBanner3 = BannerAd(
    adUnitId: 'ca-app-pub-8379180632315258/7617466459',
    size: AdSize.mediumRectangle,
    request: AdRequest(),
    listener: BannerAdListener(),
  );
  @override
  Widget build(BuildContext context) {
    // globals.buildContext = context;
    return Scaffold(
      body: DefaultTabController(
        initialIndex: 1,
        length: 3,
        child: Scaffold(

          appBar: TabBar(
            labelColor: Colors.black87,
            tabs: [
              Tab(text: "Sended",),
              Tab(text: "Received",),
              Tab(text: "Devices",),
            ],
          ),

          body: IndexedStack(children:[
            TabBarView(children: [
              //GalleryView(parentAction: addSelectedFiles,),
              UploadHistory(),
              DownloadHistory(),
              ConnectedDiveces(),
            ])
          ]),
        ),
      ),
    );


  }




  Widget ConnectedDiveces() {
    List<String> titles = [];
     adWidget2 = AdWidget(ad: myBanner2);
    for (MapEntry<String, ConnectionInfo> m in globals.endpointMap.entries) {
      String title = globals.endpointMap[m.key].endpointName;

      titles.add(title);
    }

    void disConnectThis(String title) {
      if(globals.endpointMap.containsValue(title)){
        globals.endpointMap.removeWhere((key, value) => globals.endpointMap[key].endpointName == title);
        Fluttertoast.showToast(msg: "Disconnected");
      }else{
        Fluttertoast.showToast(msg: "Can't disconnect");
      }
    }
    return
      globals.endpointMap.isNotEmpty ?
          // <Widget> is the type of items in the list.
          Container(
            color: Color.fromARGB(255, 55, 55, 55),
            child:Column(
              children: [
                Expanded(
              child:
              ListView.builder(
                itemCount: titles.length,
                itemBuilder: (BuildContext context, int index) =>
                    Card(
                      elevation: 5,
                     color: Color.fromARGB(255, 55, 55, 55),
                     shape: RoundedRectangleBorder(
                       borderRadius: BorderRadius.circular(20)
                     ),
                     child: ListTile(
                          title: Text(titles[index],style: TextStyle(color: Colors.cyanAccent),),
                          subtitle: Text(
                            "Connected", style: TextStyle(color: Colors.green),),
                          leading: Icon(
                            Icons.phone_android_outlined, color: Colors.amber,),
                          trailing: TextButton(
                              child: Text("Disconnect",
                                style: TextStyle(color: Colors.deepOrange),),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (_) {
                                    return AlertDialog(
                                      title: Text("Disconnect"),
                                      content: Text(
                                          "Are you sure want to Disconnect from ${titles[index]} ?"),
                                      actions: <Widget>[
                                        TextButton(child: Text("No"),
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                        ),
                                        TextButton(onPressed: () {
                                          Navigator.pop(context);
                                          disConnectThis(titles[index]);
                                        },
                                            child: Text("Yes"))
                                      ],
                                      //backgroundColor: Colors.amber,
                                    );
                                  },
                                );
                              }
                          )
                      ),
                    ),
              ),
            ),
           ]
          ),
          //SendReceive(),
      ) :  Container(
        child: Column(
          children: [
            Center(child: Text("0 device found.")),

            Container(
              child: adWidget2,
              width: myBanner.size.width.toDouble(),
              height: myBanner.size.height.toDouble(),
            ),
          ],
        ),
      );
  }



  Widget DownloadHistory(){
    adWidget = AdWidget(ad: myBanner);
    getProgress(double p){
      Future.delayed(Duration(seconds: 1), ()
      {
        if (mounted) {
          setState(() {
            if (p == 1) {
              dprogress = 1;
            } else {
              dprogress = p;
            }
          });
        }
      });
        return dprogress;
    }
    return Dfiles.isNotEmpty ?
    Container(
        color: Color.fromARGB(255, 55, 55, 55),
        child:Column(
            children: [
        Expanded(
        child:
    ListView.builder(
        itemCount: Dfiles.length,
        itemBuilder: (context,i) =>
        Card(
           child: ListTile(
              isThreeLine: true,
              title: Text(Dfiles[i].title,style: TextStyle(color: Colors.cyanAccent),),
              leading:
              Dfiles[i].title.endsWith("jpeg") || Dfiles[i].title.endsWith("jpg") || Dfiles[i].title.endsWith("png") ?
             Icon(Icons.image,color: Colors.cyan,):
              Dfiles[i].title.endsWith("mp4") || Dfiles[i].title.endsWith("mkv") || Dfiles[i].title.endsWith("3gp") ?
              Icon(Icons.video_label_outlined,color: Colors.cyan,):
              Dfiles[i].title.endsWith("pdf") ?
              Icon(Icons.picture_as_pdf,color: Colors.cyan,):
              Dfiles[i].title.endsWith("apk") ?
              Icon(Icons.android_outlined,color: Colors.cyan,):
              Dfiles[i].title.endsWith("mp3") || Dfiles[i].title.endsWith("m4a") ?
              Icon(Icons.music_note_outlined,color: Colors.cyan,):
              Icon(Icons.download_outlined,color: Colors.cyanAccent,),
              subtitle: Column(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child:Text(Dfiles[i].size,style: TextStyle(color: Colors.cyanAccent),) ,
                  ),
                  Dfiles[i].bytes != Dfiles[i].size ?
                  LinearProgressIndicator(
                    value:  getProgress(Dfiles[i].pValue),
                    valueColor: AlwaysStoppedAnimation(Colors.cyanAccent),
                    backgroundColor: Color.fromARGB(255, 51, 51, 51),
                    minHeight: 4,
                  ):
                  LinearProgressIndicator(
                    value: 1,
                    valueColor: AlwaysStoppedAnimation(Colors.cyanAccent),
                    minHeight: 4,
                  ),
                  Dfiles[i].bytes != Dfiles[i].size ?
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(Dfiles[i].bytes,style: TextStyle(color: Colors.redAccent)),
                  ):Align(
                    alignment: Alignment.bottomRight,
                    child: Text("Received",style: TextStyle(color: Colors.green)),
                  ),
                ],
              ),
             trailing: IconButton(
               onPressed: (){
                 setState(() {
                   Dfiles.removeAt(i);
                 });
               },
               icon: Icon(Icons.close,color: Colors.red,),
             ),
           ),
          elevation: 5,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)
          ),
          color: Color.fromARGB(255, 55, 55, 55),
        )
    )
    )]
        )
    ): Container(
      child: Column(
        children: [
      Center(child: Text("No active data transfer.")),

     Container(
    child: adWidget,
    width: myBanner.size.width.toDouble(),
    height: myBanner.size.height.toDouble(),
    ),
        ],
      ),
    );
  }

  /// Called upon Connection request (on both devices)
  /// Both need to accept connection to start sending/receiving

  //wifiDirect

  Widget UploadHistory(){
    adWidget3 = AdWidget(ad: myBanner3);
getProgress(double v){

  Future.delayed(Duration(seconds: 1), () {

    if(mounted) {
      setState(() {
        if (v == 1) {
          progress = 1;
        }
        else {
          progress = v;
        }
      });
    }
  });
  return progress;
}
    return Ufiles.isNotEmpty ?
    Container(
        color: Color.fromARGB(255, 55, 55, 55),
        child:Column(
            children: [
        Expanded(
        child:
    ListView.builder(
        itemCount: Ufiles.length,
        itemBuilder: (BuildContext context,int i) =>

           Card(
             child:  ListTile(
               isThreeLine: true,
               title: Text(Ufiles[i].title,style: TextStyle(color: Colors.cyanAccent),),
               leading: Ufiles[i].title.endsWith("jpeg") || Ufiles[i].title.endsWith("jpg") || Ufiles[i].title.endsWith("png") ?
               Icon(Icons.image,color: Colors.cyan,):
               Ufiles[i].title.endsWith("mp4") || Ufiles[i].title.endsWith("mkv") || Ufiles[i].title.endsWith("3gp") ?
               Icon(Icons.video_label_outlined,color: Colors.cyan,):
               Ufiles[i].title.endsWith("pdf") ?
               Icon(Icons.picture_as_pdf,color: Colors.cyan,):
               Ufiles[i].title.endsWith("apk") ?
               Icon(Icons.android_outlined,color: Colors.cyan,):
               Ufiles[i].title.endsWith("mp3") || Ufiles[i].title.endsWith("m4a") ?
               Icon(Icons.music_note_outlined,color: Colors.cyan,):
               Icon(Icons.upload_outlined,color: Colors.cyanAccent,),

               subtitle: Column(
                 children: [
                   Align(
                     alignment: Alignment.topLeft,
                     child:Text(Ufiles[i].size,style: TextStyle(color: Colors.cyanAccent)) ,
                   ),
                   Ufiles[i].bytes != Ufiles[i].size ?
                   LinearProgressIndicator(
                     value: getProgress(Ufiles[i].pValue),
                     valueColor: AlwaysStoppedAnimation(Colors.cyanAccent),
                     backgroundColor: Color.fromARGB(255, 51, 51, 51),
                     minHeight: 4,
                   ):
                   LinearProgressIndicator(
                     value: 1,
                     valueColor: AlwaysStoppedAnimation(Colors.cyanAccent),
                     minHeight: 4,
                   ),
                   Ufiles[i].bytes != Ufiles[i].size ?
                   Align(
                     alignment: Alignment.bottomRight,
                     child: Text(Ufiles[i].bytes,style: TextStyle(color: Colors.redAccent)),
                   ):Align(
                     alignment: Alignment.bottomRight,
                     child: Text("Completed",style: TextStyle(color: Colors.green),),
                   ),
                 ],
               ),
               trailing: IconButton(
                 onPressed: (){
                   setState(() {
                     Ufiles.removeAt(i);
                   });
                 },
                 icon: Icon(Icons.close,color: Colors.red,),
               ),
             ),
             elevation: 5,
             shape: RoundedRectangleBorder(
               borderRadius: BorderRadius.circular(20)
             ),
             color: Color.fromARGB(255, 55, 55, 55),
           )
    )
    )
        ]
        )
    ):Container(
      child: Column(
        children: [
          Center(child: Text("No active data transfer.")),

          Container(
            child: adWidget3,
            width: myBanner.size.width.toDouble(),
            height: myBanner.size.height.toDouble(),
          ),
        ],
      ),
    );
  }



  _checkPermissions() async {
    if (await Nearby().checkExternalStoragePermission()) {
      Fluttertoast.showToast(
          msg: "Storage Permission granted. :)",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 1,
          backgroundColor: Color.fromARGB(255, 51, 51, 51),
          textColor: Colors.white,
          fontSize: 16.0
      );
    }
    else {
      Nearby().askExternalStoragePermission();
    }
    if (await Nearby().askLocationPermission()) {
      Fluttertoast.showToast(
          msg: "Location permission granted :)",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 1,
          backgroundColor: Color.fromARGB(255, 51, 51, 51),
          textColor: Colors.cyan,
          fontSize: 16.0
      );
      if (await Nearby().enableLocationServices()) {
        //Scaffold.of(context).showSnackBar(SnackBar(content: Text("Location Service Enabled :)")));
      } else {
        if (await Nearby().checkLocationEnabled()) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Location is ON :)")));
        } else {
          if (await Nearby().checkLocationPermission()) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text("Location permissions granted :)")));
          } else {
            Fluttertoast.showToast(
                msg: "Location permissions not granted :(",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                timeInSecForIosWeb: 1,
                backgroundColor: Color.fromARGB(255, 51, 51, 51),
                textColor: Colors.cyan,
                fontSize: 16.0
            );
          }
        }
      }
      return true;
    }
    else {
      await Nearby().askLocationPermission();
    }
  }


  void showSnackbar(dynamic a) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(a.toString()),
    ));
  }

  invokeReceive(BuildContext context) async {
    _checkPermissions();

    DialogUtils.showCustomDialog(context,
      title: "WAITING...",
      txtcontent: "Ask your friend to tap send button.",
      cancelBtnText: "Cancel",
      cancelBtnFunction: () =>
      {
        Nearby().stopAdvertising(),
        Fluttertoast.showToast(
            msg: "Connection Cancelled",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.TOP,
            timeInSecForIosWeb: 1,
            backgroundColor: Color.fromARGB(255, 51, 51, 51),
            textColor: Colors.cyan,
            fontSize: 16.0
        ),
      },
    );
    try {
      bool a = await Nearby().startAdvertising(
        userName,
        strategy,
        onConnectionInitiated: onConnectionInit,
        onConnectionResult: (id, status) {
          showSnackbar(status);
          Navigator.pop(context);
        },
        onDisconnected: (id) {
          showSnackbar("Disconnected: " + id);
          Fluttertoast.showToast(msg: "Disconnected from $id");
        },
        serviceId: ServiceId,
      );
      // showSnackbar("Receive Key: " + a.toString());
    } catch (exception) {
      showSnackbar('Something went wrong error 201');
      Fluttertoast.showToast(msg: "Please try again error 201");
    }
  }

  invokeSend(BuildContext context) async {
    _checkPermissions();

    DialogUtils.showCustomDialog(context,
        title: "SEARCHING...",
        txtcontent: "Ask your friend to tap receive button.",
        cancelBtnText: "Cancel",
        cancelBtnFunction: () =>
        {
          Nearby().stopDiscovery(),
          Fluttertoast.showToast(
              msg: "Search Cancelled",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.TOP,
              timeInSecForIosWeb: 1,
              backgroundColor: Color.fromARGB(255, 51, 51, 51),
              textColor: Colors.cyan,
              fontSize: 16.0
          ),
        }
    );
    try {
      bool a = await Nearby().startDiscovery(
        userName,
        strategy,
        onEndpointFound: (id, name, serviceId) {
          // show sheet automatically to request connection
          //  Navigator.pop(context);
          showModalBottomSheet(
            context: context,
            builder: (builder) {
              return Container(
                height: 200,
                child: Wrap(
                  children: <Widget>[

                    ListTile(
                      title: Text(name),
                      subtitle: Text("Connection Id: " + id),
                      leading: Icon(Icons.phone_android_outlined,color: Colors.black,),
                      trailing: TextButton(
                        child: Text("Request"),
                        onPressed: () {
                          Navigator.pop(context);
                          Nearby().requestConnection(
                            userName,
                            id,
                            onConnectionInitiated: (id, info) {
                              onConnectionInit(id, info);
                            },
                            onConnectionResult: (id, status) {
                              showSnackbar(status);
                            },
                            onDisconnected: (id) {
                              showSnackbar('Disconnected :$id');
                              Fluttertoast.showToast(msg: "Disconnected from $id");
                            },
                          );
                        },
                      ),
                    ),

                  ],
                ),
              );
            },
          );
        },
        onEndpointLost: (id) {
          showSnackbar("Lost Connection:" + id);
        },
        serviceId: ServiceId,
      );
      //showSnackbar("Searching: ");
    } catch (e) {
      showSnackbar('Something went wrong error 202');
    }
  }


  onConnectionInit(String id, ConnectionInfo info) {
    Navigator.pop(globals.buildContext);
    Nearby().stopDiscovery();
    showModalBottomSheet(
      context: globals.buildContext,
      builder: (_) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 10),
          child: Column(
            children: <Widget>[
              ListTile(
                title: Text(info.endpointName),
                subtitle: Text("Connection Id: " + id),
                leading: Icon(Icons.phone_android_outlined),
                trailing:
                TextButton(
                  child: Text("Connect"),
                  onPressed: () async {
                    Navigator.pop(globals.buildContext);
                    globals.device_Id.add(id);
                    globals.endpointMap[id] = info;
                    cId = id;

                    Nearby().acceptConnection(
                      id,
                      onPayLoadRecieved: (endid, payload) async {

                        if (payload.type == PayloadType.BYTES) {
                          String str = String.fromCharCodes(payload.bytes);
                          print(endid + ": " + str);
                          if (str.contains(':')) {
                            int payloadId = int.parse(str.split(':')[0]);
                            String fileName = (str.split(':')[1]);
                           globals.map[payloadId] = fileName;


                            if (map.containsKey(payloadId)) {
                              if (tempFile != null) {
                                try {
                                  moveFile(tempFile, fileName);
                                }
                                catch(e){
                                  Fluttertoast.showToast(msg: "Error file 89");
                                }
                              } else {
                                print("File doesn't exist");
                              }
                            } else {
                              //add to map if not already
                              map[payloadId] = fileName;
                              // print(fileName);
                            }
                          }
                        } else if (payload.type == PayloadType.FILE) {
                          tempFile = payload.uri;
                          Fluttertoast.showToast(
                              msg: "File transfer Started :)",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.TOP,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Color.fromARGB(255, 51, 51, 51),
                              textColor: Colors.cyan,
                              fontSize: 16.0
                          );

                        }

                      },
                      onPayloadTransferUpdate: (endid, payloadTransferUpdate) async{
                        if (payloadTransferUpdate.status ==
                            PayloadStatus.IN_PROGRESS) {
                         // final path = await _localPath;
                          if(globals.titleName[payloadTransferUpdate.id] != null) {
                            try {
                              Uname =
                              globals.titleName[payloadTransferUpdate.id];
                              Ubytes = getBytes(
                                  payloadTransferUpdate.bytesTransferred);
                              Usize =
                                  getsBytes(payloadTransferUpdate.totalBytes);
                              Up = (payloadTransferUpdate.bytesTransferred /
                                  (1000 * 1000)) /
                                  (payloadTransferUpdate.totalBytes /
                                      (1000 * 1000));
                              //print("Progress:" +Uname+"/"+Ubytes+"/"+Usize+"/"+Up.toString());

                              items = senderProgress(
                                  id: payloadTransferUpdate.id.toString(),
                                  title: Uname,
                                  size: Usize,
                                  bytes: Ubytes,
                                  pValue: Up);


                              if (items.title != null) {
                                if (Ufiles.isEmpty ||
                                    Ufiles.every((element) => element.id
                                        .toString() != items.id.toString())) {
                                  Ufiles.add(items);
                                }
                                else {
                                  int index = Ufiles.indexWhere((element) =>
                                  element.id.toString() == items.id.toString());
                                  if (index != -1) {
                                    Ufiles[index].size = items.size;
                                    Ufiles[index].bytes = items.bytes;
                                    Ufiles[index].pValue = items.pValue;
                                  } else {
                                    print("Index error 1");
                                  }
                                }
                              }
                              else {
                                print("Id or name is null");
                              }
                            } catch (e) {
                              print(e);
                            }
                          }
                          else {
                            try {
                              if (tempFile != null &&
                                  map.containsKey(payloadTransferUpdate.id)) {
                                String dname = globals.map[payloadTransferUpdate
                                    .id];
                                String dbytes = getBytes(
                                    payloadTransferUpdate.bytesTransferred);
                                String dsize = getsBytes(
                                    payloadTransferUpdate.totalBytes);
                                double dp = (payloadTransferUpdate
                                    .bytesTransferred / (1000 * 1000)) /
                                    (payloadTransferUpdate.totalBytes /
                                        (1000 * 1000));
                                ditems = receiverProgress(
                                    id: payloadTransferUpdate.id.toString(),
                                    title: dname,
                                    size: dsize,
                                    bytes: dbytes,
                                    pValue: dp);
                                if (Dfiles.every((element) =>
                                element.id != ditems.id) &&
                                    ditems.title != null) {
                                  Dfiles.add(ditems);
                                } else {
                                  int index = Dfiles.indexWhere((
                                      element) => element.id == ditems.id);
                                  if (index != -1) {
                                    Dfiles[index].size = ditems.size;
                                    Dfiles[index].bytes = ditems.bytes;
                                    Dfiles[index].pValue = ditems.pValue;
                                  } else {
                                    print("Index error 2");
                                  }
                                }
                              }
                            } catch (e) {
                              print(e);
                            }
                          }
                          print("InProgress");
                        }
                        else if (payloadTransferUpdate.status ==
                            PayloadStatus.FAILURE) {
                          print("failed");
                          print(endid + ": FAILED to transfer file");



                        } else if (payloadTransferUpdate.status ==
                            PayloadStatus.SUCCESS) {

                          if (map.containsKey(payloadTransferUpdate.id)){
                            try {
                              //final path = await _localPath;
                              String name = map[payloadTransferUpdate.id];
                              //moveFile(tempFile, name);
                              
                            }catch (e){
                             print("Rename error $e");
                            }


                          } else {

                            map[payloadTransferUpdate.id] = "";

                          }
                          print("Success");

                        }
                      },
                    );
                    /*try {
              await Nearby().rejectConnection(id);
            } catch (e) {
              showSnackbar(e);
            }*/

                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  Future<bool> moveFile(String uri, String fileName) async {
    try {
      await platform.invokeMethod("Save",<String,String>{
        'name':fileName,
        'uri':uri
      });

    }catch (e){
      print("Rename error $e");
    }
  }
  getsBytes(int sizeInBytes){
    double size = sizeInBytes / (1000*1000);
    String megaBytes = size.toString().split(".").first;
    if(megaBytes == "0"){
      megaBytes = size.toString().split(".").last.substring(0,3)+" KB";
    }else{
      megaBytes = size.toString().substring(0,4)+" MB";
    }
    return megaBytes;
  }
  getByte(int sizeInBytes){

    double size = sizeInBytes / (1000*1000);
    String megaBytes = size.toString().split(".").first;
    if(megaBytes == "0"){
      megaBytes = size.toString().split(".").last.substring(0,3)+" KB";
    }else{
      megaBytes = size.toString().substring(0,4)+" MB";
    }
    return megaBytes;
  }
  getBytes(int bytes){
    double size = bytes / (1000*1000);
    String megaBytes = size.toString().split(".").first;
    if(megaBytes == "0"){
      megaBytes = size.toString().split(".").last.substring(0,3)+" KB";
    }else{
      megaBytes = size.toString().substring(0,4)+" MB";
    }
    return megaBytes;
  }
  void disConnect(BuildContext context) async{

     try{
       await Nearby().stopAllEndpoints();
       globals.endpointMap.clear();
       globals.device_Id = [];
       globals.MusicList.clear();
       globals.ImageList.clear();
       globals.fileList.clear();
       globals.VideoList.clear();
     }catch(e){
       Fluttertoast.showToast(msg: e);
     }


  }


}
