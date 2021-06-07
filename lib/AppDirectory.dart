
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';


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
  static Map<dynamic,dynamic> map = Map();

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
              Text('App files & folder'),

              Expanded(
                child:
        map.isNotEmpty ?
                    ListView.builder(
                        itemCount: (map.length/2).ceil(),
                        itemBuilder: (_,index){
                  return ListTile(
                    title: Text(map["Name$index"]),
                    subtitle: Text("bytes"),
                    leading: Icon(Icons.folder_open_outlined,color: Colors.cyanAccent,),
                    onTap: ()async{
                      await platform.invokeMethod("OpenFolder",<String,dynamic>{
                        'Path':map['Path$index'],
                      });
                    },
                  );
               }):
              Center(child: Text(
                  "Received files & saved pdf files appear here.",
                  style: TextStyle(color: Colors.black38)),),

              )
            ]
        ));
  }

 void getFiles() async {


   await platform.invokeMethod("getFolders").then((value) {

    if(value != null){
     setState(() {
       map.addAll(value);
         });
         }
    });
  }


}