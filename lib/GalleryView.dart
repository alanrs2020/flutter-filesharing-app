
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:open_file/open_file.dart';
import 'package:photo_manager/photo_manager.dart';
import 'globals.dart' as globals;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GalleryView extends StatefulWidget {

  final ValueChanged<Map> parentAction;
  GalleryView({Key key,this.parentAction}) : super(key: key);
  @override
  GalleryViewState createState() => GalleryViewState();
}

class VideoModel{
  String path;
  Uint8List thumbpath;

  VideoModel({
    this.path,
    this.thumbpath,
  });
}
class GalleryViewState extends State<GalleryView>{

  static const platform = const MethodChannel('storage_access');
 List<AssetEntity> videoList = [];
  Future<void> getFiles() async { //asyn function to get list of files
    var result = await PhotoManager.requestPermissionExtend();
    if (result != null) {
      // success
      List<AssetPathEntity> list = await PhotoManager.getAssetPathList(hasAll: true);

      try{
        final assetList = await list[0].getAssetListRange(start: 0, end: 10000000);
        setState(() {
          videoList = assetList;

        });
      }catch(e){
        print(e);
      }



    } else {
      // fail
      /// if result is fail, you can call `PhotoManager.openSetting();`  to open android/ios applicaton's setting to get permission
      Fluttertoast.showToast(msg: "Please allow media permission.");
      PhotoManager.openSetting();
    }

  }
  bool isLongPressed = false;
  @override
  void initState() {
    super.initState();
    getFiles();

  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    PhotoManager.clearFileCache();
  }
  @override
  Widget build(BuildContext context) {


    return videoList.isNotEmpty ?  Container(
      color: Color.fromARGB(255, 51, 51, 51),
      padding: EdgeInsets.all(5) ,
      child: Column(
        children: [
          Expanded(
            child:
            GridView.builder(
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  // A grid view with 3 items per row
                  crossAxisCount: 2,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 5,
                ),
                itemCount: videoList.length,
                itemBuilder: (_,  index) {
                  if (globals.VideoList[index] == null) {
                    globals.VideoList[index] = false;
                  }else{
                    if(globals.VideoList[index] == true){
                      isLongPressed = true;
                    }
                  }
                  AssetEntity asset = videoList[index];

                  return  FutureBuilder(
                      future: asset.thumbnailData,
                      builder: (BuildContext context,AsyncSnapshot snapshot) {
                        var bytes = snapshot.data;
                        if (bytes == null )
                          return Center(child: CircularProgressIndicator());

                        return   Card(
                          clipBehavior: Clip.hardEdge,
                          child: GestureDetector(
                            onTap: () async {
                              if(!isLongPressed){
                                var filepath = await asset.originFile;
                                var path = filepath.toString().split(':')[1].replaceAll("'", "");
                                OpenFile.open(path.trim());
                                globals.VideoList[index] = false;
                              }else if(isLongPressed){
                                setState(() {
                                  if(globals.VideoList[index] == true){
                                    globals.VideoList[index] = false;
                                  }
                                  else if(globals.VideoList[index] == false){
                                    globals.VideoList[index] = true;
                                  }
                                });
                                var filepath = await asset.originFile;
                                var path = filepath.toString().split(':')[1].replaceAll("'", "");
                                Map<String,String> lmap = Map();
                                lmap[path.split("/").last.trim()] = path.trim();
                                widget.parentAction(lmap);
                              }
                              else{
                                print("Gallery Error");
                              }


                            },
                            onLongPress: () async {

                              if(mounted) {
                                setState(() {
                                  isLongPressed = true;
                                  globals.VideoList[index] = true;
                                });
                                var filepath = await asset.originFile;
                                var path = filepath.toString().split(':')[1].replaceAll("'", "");
                                Map<String,String> lmap = Map();
                                lmap[path.split("/").last.trim()] = path.trim();
                                widget.parentAction(lmap);
                              }


                            },
                            // TODO: navigate to Image/Video screen
                            child: Stack(
                              children: [
                                // Wrap the image in a Positioned.fill to fill the space
                                Positioned.fill(child: Image.memory(

                                    bytes, fit: BoxFit.cover,filterQuality: FilterQuality.high,),
                                  ),
                                Align(
                                    alignment: Alignment.bottomCenter,
                                    child:
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        asset.type == AssetType.video ? Icon(Icons.video_collection_outlined,):Icon(Icons.image_outlined,),
                                        Expanded(child: Text(asset.title,
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                            color: Colors.grey, fontSize: 15,)
                                          , maxLines: 1,),)

                                      ],
                                    )
                                ),
                                isLongPressed ?
                                Align(
                                  child: Checkbox(
                                    tristate: false,
                                    value: globals.VideoList[index],
                                    onChanged: (bool newValue) async {
                                      setState(() {
                                        globals.VideoList[index] = newValue;
                                      });

                                      var filepath = await asset.originFile;
                                      var path = filepath.toString().split(':')[1].replaceAll("'", "");
                                      Map<String,String> lmap = Map();
                                      lmap[path.split("/").last.trim()] = path.trim();
                                      widget.parentAction(lmap);



                                    },
                                  ),
                                  alignment: Alignment.topRight,
                                ) : Icon(Icons.more_vert,color: Color.fromARGB(255, 51, 51, 51),),
                                if(asset.type == AssetType.video)
                                  Center(child:
                                  Card(
                                    child: Icon(Icons.play_arrow,size: 50,semanticLabel: "Video",),
                                    color: Colors.black,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(35)
                                    ),
                                  )
                                  ),

                              ],
                            ),
                          ),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)
                          ),
                          color: Color.fromARGB(255, 51, 51, 51),
                          elevation: 10,
                          shadowColor: Colors.black,
                        );
                      }

                  );
                }
          )
            )
        ]
    ),
    ): Center( child: Text("No Media found."));
  }







}
