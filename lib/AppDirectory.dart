
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:open_file/open_file.dart';


class AppDirectory extends StatefulWidget{
  final ValueChanged<Map> parentAction;
  AppDirectory({Key key,this.parentAction}) :super (key: key);
  @override
  AppDirectoryState createState() => AppDirectoryState();

}
class AppDirectoryState extends State<AppDirectory>{

  List<File> files = [];
  List<File> VideoPaths = [];

  static  int j = 0;
  static List<File> folders = [];
  static Map _map = new Map();

  static const platform = const MethodChannel('storage_access');
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getFiles();

  }
  _selectFiles() async{

    FilePickerResult result = await FilePicker.platform.pickFiles(allowMultiple: true,onFileLoading: onLoading(FilePickerStatus.picking));

    if(result != null) {
      List<File> files = result.paths.map((path) => File(path)).toList();
      for(var file in files){
        String path = file.toString().split(':')[1]
            .replaceAll("'", "")
            .trim();

        Map<String,String> lmap = Map();
        lmap[path.toString().split("/").last] = path;
        widget.parentAction(lmap);
      }


      // sendFile(filepaths[i]).sendfile();

    } else {
      // User canceled the picker
    }
  }
  onLoading(FilePickerStatus pickerStatus){

    Fluttertoast.showToast(msg: "Loading....",gravity: ToastGravity.SNACKBAR);

  }
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
          // <Widget> is the type of items in the list.
            children: <Widget>[
              GestureDetector(
                child: Container(
                    height: 80,
                    padding: EdgeInsets.all(20),
                    child:
                    Row(
                      children: [
                        Padding(padding: EdgeInsets.all(5),
                            child: Icon(Icons.storage_outlined, size: 40,)),
                        Text("STORAGE", style: TextStyle(fontSize: 20),)
                      ],
                    )
                ),
                onTap: _selectFiles,
              ),
              Align(
                child: Text('App History'),
                alignment: Alignment.topLeft,
              ),

              Expanded(
                child:
        _map.isEmpty ? Center(child: Text(
                  "Received files & saved pdf files appear here.",
                  style: TextStyle(color: Colors.black38)),):
        ListView.builder(
            itemCount: ((_map.length)/2).ceil(),
            itemBuilder: (_,index){
              return ListTile(
                title: Text(_map["name$index"]),
                subtitle: Text(File(_map["path$index"]).lastAccessedSync().toLocal().toString()),
                leading: FutureBuilder(
                  future: getThumb(_map['path$index']),
                  builder: (_,AsyncSnapshot snapshot){
                   if(snapshot.connectionState == ConnectionState.done){
                     return snapshot.data != null ? Image.memory(snapshot.data,fit: BoxFit.cover,width: 50,height: 50,) : Icon(Icons.file_copy_sharp);
                   }else{
                     return Icon(Icons.file_copy_sharp);
                   }
                  },
                ),
                onTap: ()async{
                  OpenFile.open(_map['path$index']);
                },
              );
            })
              )
            ]
        ));
  }

 void getFiles() async {
   await platform.invokeMethod("AppFiles").then((value) {
     if(value != null){
       setState(() {
         _map.addAll(value);
       });
     }
   });
 }

Future<Uint8List> getThumb(String path) async {
    Uint8List bytes;
   await platform.invokeMethod("getThumb",<String,dynamic>{
     'path':path,
   }).then((value){
       bytes = value;
   });
   return bytes;
 }

}