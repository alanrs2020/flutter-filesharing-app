import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;


// A screen that allows users to take a picture using a given camera.
class pdfscanner extends StatefulWidget {
  final CameraDescription camera;

  const pdfscanner({
    Key key,
    @required this.camera,
  }) : super(key: key);

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<pdfscanner> {
  CameraController _controller;
  Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.ultraHigh,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
   return  Scaffold(
      appBar: AppBar(
        backgroundColor:  Color.fromARGB(255, 51, 51, 51),
          title: Text('PDF Scanner',style: TextStyle(color: Colors.cyanAccent))),
    // Wait until the controller is initialized before displaying the
    // camera preview. Use a FutureBuilder to display a loading spinner
    // until the controller has finished initializing.
    body: FutureBuilder<void>(
    future: _initializeControllerFuture,
    builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.done) {
    // If the Future is complete, display the preview.
    return Container(
      child:CameraPreview(_controller),
      alignment: Alignment.center,
      margin: EdgeInsets.all(5),
    );
    } else {
    // Otherwise, display a loading indicator.
    return Center(child: CircularProgressIndicator());
    }
    },
    ),
    floatingActionButton:
           FloatingActionButton(
             backgroundColor: Color.fromARGB(255, 51, 51, 51),

          child: Icon(Icons.camera_alt,color: Colors.cyanAccent,),
          // Provide an onPressed callback.
          onPressed: () async {
            // Take the Picture in a try / catch block. If anything goes wrong,
            // catch the error.
            try {
              // Ensure that the camera is initialized.
              await _initializeControllerFuture;

              // Attempt to take a picture and get the file `image`
              // where it was saved.
              final image = await _controller.takePicture();
              printPath(image.path);
               await _localFile;
              // If the picture was taken, display it on a new screen.
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DisplayPictureScreen(
                    // Pass the automatically generated path to
                    // the DisplayPictureScreen widget.
                    imagePath: image?.path,
                  ),
                ),
              );
            } catch (e) {
              // If an error occurs, log the error to the console.
              print(e);
            }
          },
        ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
    }
  }


String printPath(String path){
  return path;
}
// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;
  DisplayPictureScreen({Key key, this.imagePath}) : super(key: key);
  bool isSaved = false;
  final pdf = pw.Document();
  String newPath;
  static const platform = const MethodChannel('storage_access');
  static List<String> pages = [];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
          title:
                Text('Save as PDF',style: TextStyle(color: Colors.cyanAccent),),
        backgroundColor: Color.fromARGB(255, 51, 51, 51),
      ),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: Container(
        child:
            Stack(
              children: [
                Image.file(File(imagePath)),
                Padding(
                  child: Text("Page "+(pages.length+1).toString(),semanticsLabel: "Pages",style: TextStyle(color: Colors.cyanAccent),),
                  padding: EdgeInsets.all(20),
                )
              ],
            ),
        alignment: Alignment.center,
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
       mainAxisSize: MainAxisSize.max,
       children: [
         !isSaved ?
             Row(
               children: [
                 FloatingActionButton(
                     backgroundColor: Color.fromARGB(255, 51, 51, 51),
                     child: Text("Save",style: TextStyle(color: Colors.cyanAccent),),
                     onPressed: () async{
                       await platform.invokeMethod("isFolderExits").then((value) async {
                         if (value) {
                           try{

                             pages.add(imagePath);

                             pdf.addPage(
                               pw.MultiPage(
                                 pageFormat: PdfPageFormat.a4,
                                 build: (pw.Context context) =>
                                 List<pw.Widget>.generate(pages.length, (int index) {
                                   final image = pw.MemoryImage(
                                     File(pages[index]).readAsBytesSync(),
                                   );

                                   return  pw.Column(
                                       children: [
                                         pw.SizedBox(
                                           width: 450,
                                           height: 720,
                                           child: pw.Image(
                                             image,
                                             fit: pw.BoxFit.fill,
                                           ),
                                         ),
                                       ]
                                   );
                                 }),
                               ),
                             );
                             // final file = await _localFile;
                             //file.writeAsBytes(await pdf.save());
                             //newPath = file.path;

                             String name = await _localFile;
                             Uint8List bytes = await pdf.save();
                             await platform.invokeMethod("savePDF",<String,dynamic>{
                               'bytes':bytes,
                               'name':name
                             }).then((value){
                               Fluttertoast.showToast(msg: "Successfully Saved.");
                               pages.clear();
                               Navigator.pop(context);
                             });
                             // isSaved = true;

                           }catch(e){
                             print(e);
                             Fluttertoast.showToast(msg: "Something went wrong."+e);
                           }
                         }else{
                           showCupertinoDialog(context: context, builder: (_){
                             return AlertDialog(
                               title: Text("Create Folder"),
                               content: Text("You need to create a new folder or select one."),
                               actions: [
                                 TextButton(onPressed: ()async{

                                   await platform.invokeMethod("CreateFolder").then((value){
                                     if(value){
                                       Navigator.pop(context);
                                     }else{
                                       Fluttertoast.showToast(msg: "Please  create a folder");
                                     }
                                   });
                                 }, child: Text("OK"))
                               ],
                             );
                           });
                         }
                       });


                     }
                 ),
                 FloatingActionButton(
                   heroTag: "AddPage",
                     backgroundColor: Color.fromARGB(255, 51, 51, 51),
                     child: Icon(Icons.add_outlined,color: Colors.cyanAccent,),
                     onPressed: () async{
                       pages.add(imagePath);
                       Navigator.pop(context);
                     }

                 ),
                 FloatingActionButton(
                     heroTag: "Remove",
                     backgroundColor: Color.fromARGB(255, 51, 51, 51),
                     child: Icon(Icons.delete_forever_outlined,color: Colors.cyanAccent,),
                     onPressed: () async{
                       if(pages != null){
                         pages.clear();
                         Fluttertoast.showToast(msg: "Removed");
                       }
                       else{
                         Fluttertoast.showToast(msg: "Empty!!");
                       }
                       Navigator.pop(context);
                     }

                 ),
               ],
             ):


         FloatingActionButton(
             backgroundColor:  Color.fromARGB(255, 51, 51, 51),
             child: Icon(Icons.open_in_new_outlined,color: Colors.cyanAccent,),
             onPressed: (){
               try{
                 Navigator.pop(context);
                 OpenFile.open(newPath);
               }catch(e){
                 print(e);
               }

             }),
       ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

    );
  }
}
Future<String> get _localFile async {
 // final path = await _localPath;
 // print(path);
  String time = 'bytesPDFScanner'+Random().nextInt(100000).toString();

  return "$time.pdf";
}