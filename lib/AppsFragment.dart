import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'globals.dart' as globals;
import 'dart:typed_data';
import 'package:device_apps/device_apps.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppsFragment extends StatefulWidget{
  final ValueChanged<Map> parentAction;
  AppsFragment({Key key, this.parentAction}) : super(key: key);
  @override
  _appsState createState() => _appsState();
}
class _appsState extends State<AppsFragment>{
  List listApps = [];
  static final _kAdIndex = 3;
  NativeAd _ad;
  bool _isAdLoaded = false;

void initState(){
  super.initState();
  _getApp();
  ///Ad
  // TODO: Create a NativeAd instance
  _ad = NativeAd(
    adUnitId: "ca-app-pub-8379180632315258/1266776565",
    factoryId: 'listTile',
    request: AdRequest(),
    listener:NativeAdListener(
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

  void _getApp() async{
    List _apps = await DeviceApps.getInstalledApplications(onlyAppsWithLaunchIntent: true, includeAppIcons: true, includeSystemApps: true);
    for(var app in _apps){
      var item = AppModel(
        title: app.appName,
        package: app.packageName,
        path: app.apkFilePath,
        icon: app.icon,
      );
      listApps.add(item);

    }
    if(mounted){
      setState(() {
        listApps.add(listApps[3]);
      });
    }

    //reloading state
  }
 bool isLongPressed = false;
  @override
  Widget build(BuildContext context) {
    return listApps.isEmpty ? Container(color: Color.fromARGB(255, 51, 51, 51) ,child: Center(child: CircularProgressIndicator(backgroundColor: Colors.black,),)) :

     ListView.builder(

      itemCount: listApps.length,
      primary: true,
      itemBuilder: (context, int i) {

        if (globals.AppList[i] == null ) {

            globals.AppList[i] = false;


        } else {
          if(globals.AppList[i] == true){

             isLongPressed = true;

          }

        }
        if (_isAdLoaded && i == _kAdIndex) {
          return Container(
            child: AdWidget(ad: _ad),
            height: 80,
            alignment: Alignment.center,
          );
        } else {

          return
            Container(
              color: Color.fromARGB(255, 51, 51, 51),
              padding: EdgeInsets.all(5),
              //color: Color.fromARGB(255, 55, 55, 55),
              child: Card(
                elevation: 10,
                shadowColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)
                ),
                color: Color.fromARGB(255, 51, 51, 51),
                child:
                !isLongPressed ? ListTile(
                  leading: Card(
                    clipBehavior: Clip.hardEdge,
                    color: Color.fromARGB(255, 51, 51, 51),
                    child: Image.memory(listApps[i].icon),
                    elevation: 4,
                    shadowColor: Colors.black,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(35)
                    ),
                  ),
                  title: new Text(listApps[i].title,style: TextStyle(color: Colors.cyan)),
                  subtitle: new Text(getfileSize(listApps[i].path) + " MB",style: TextStyle(color: Colors.black)),
                  onLongPress: () async {
                    setState(() {
                      isLongPressed = true;
                      globals.AppList[i] = true;
                    });
                    Map<String, String> lmap = Map();
                    lmap[listApps[i].title + ".apk".trim()] = listApps[i].path;
                    widget.parentAction(lmap);
                  },

                  onTap: () {
                    showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) {
                          return AlertDialog(
                            title: Text("Open App"),
                            content: Text(
                                "Are you sure want to open ${listApps[i].title} ?"),
                            actions: <Widget>[
                              TextButton(child: Text("No"),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                              TextButton(onPressed: () {
                                DeviceApps.openApp(listApps[i].package);
                                Navigator.pop(context);
                              },
                                  child: Text("Yes"))
                            ],
                            //backgroundColor: Colors.amber,
                          );
                        });
                  },
                ) : CheckboxListTile(value: globals.AppList[i],
                  onChanged: (bool newValue) {
                    setState(() {
                      globals.AppList[i] = newValue;
                    });
                    Map<String, String> lmap = Map();
                    lmap[listApps[i].title + ".apk".trim()] = listApps[i].path;
                    widget.parentAction(lmap);
                  },
                  title: new Text(listApps[i].title,style: TextStyle(color: Colors.cyan)),
                  subtitle: new Text(getfileSize(listApps[i].path) + " MB",style: TextStyle(color: Colors.black)),
                  secondary: Image.memory(listApps[i].icon),
                  controlAffinity: ListTileControlAffinity.trailing,
                ),

                //checkBoxList(listApps.length,listApps[i].title, listApps[i].package, listApps[i].icon,listApps[i]),
              ),
            );
        }
        },
    );

  }
  String getfileSize(String path){
    File file = File(path);
    var size = file.lengthSync();
    var sizeInMb = (size/(1024*1024));
    return sizeInMb.toString().substring(0,4);
  }
}

class AppModel{
  final String title;
  final String package;
  final String path;
  final Uint8List icon;

  AppModel({
    this.title,
    this.package,
    this.path,
    this.icon
  });
}

