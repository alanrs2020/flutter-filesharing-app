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
import 'package:image_cropper/image_cropper.dart';
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
class DisplayPictureScreen extends StatefulWidget {

  String imagePath;
  DisplayPictureScreen({Key key,this.imagePath}) :super(key: key);

  @override
  DisplayPictureScreenState createState() => DisplayPictureScreenState();

}
class DisplayPictureScreenState extends State<DisplayPictureScreen>{


  bool isSaved = false;
  final pdf = pw.Document();
  String newPath;
  static const platform = const MethodChannel('storage_access');
  static List<String> pages = [];


  @override
  void initState() {
    super.initState();


  }
  @override
  Widget build(BuildContext context) {

    if(widget.imagePath != null && !pages.contains(widget.imagePath)){
      setState(() {
        pages.add(widget.imagePath);
      });
    }
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
          title:
                Text('PDF Scanner',style: TextStyle(color: Colors.cyanAccent),),
        backgroundColor: Color.fromARGB(255, 51, 51, 51),
      ),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: Container(
        child:
          Stack(
             children: [
              // Image.file(File(widget.imagePath)),
               pages.length != null ?
          ListView.builder(
              itemCount: pages.length,
              itemBuilder: (_,index){
                return
                  Stack(
                      children: [
                        Image.file(File(pages[index]))  ,

                        Align(
                            alignment: Alignment.topRight,

                            child: Row(
                              children: [
                                Padding(
                                  child: Text("Page "+(index+1).toString(),semanticsLabel: "Pages",style: TextStyle(color: Colors.cyanAccent),),
                                  padding: EdgeInsets.all(20),
                                ),
                                IconButton(onPressed: ()async{
                                  setState(() {
                                    if(pages.length == 1){

                                        Navigator.pop(context);
                                        pages.clear();

                                    }else{

                                       pages.removeAt(index);

                                    }
                                  });
                                },
                                    icon: Icon(Icons.delete)
                                ),
                                IconButton(onPressed: ()async{

                                    _cropImage(File(pages[index]));

                                },
                                    icon: Icon(Icons.crop_sharp)
                                ),
                              ],
                            )
                        )
                      ]
                  );

              }

          ):
               Text("Empty"),

               // Padding(
               //   child: Text("Page "+(pages.length).toString(),semanticsLabel: "Pages",style: TextStyle(color: Colors.cyanAccent),),
               //   padding: EdgeInsets.all(20),
               // )
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

                           try{

                            // pages.add(widget.imagePath);
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
                                           width: image.width.floorToDouble() <= 480 ? image.width.floorToDouble() : 480,
                                           height: image.height.floorToDouble() <= 720 ? image.height.floorToDouble(): 720,
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
                             Fluttertoast.showToast(msg: "Something went wrong."+e.toString());
                           }
                         }
                 ),
                 FloatingActionButton(
                   heroTag: "AddPage",
                     backgroundColor: Color.fromARGB(255, 51, 51, 51),
                     child: Icon(Icons.add_outlined,color: Colors.cyanAccent,),
                     onPressed: () async{
                       //pages.add(widget.imagePath);
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
                 FloatingActionButton(
                     heroTag: "Crop",
                     backgroundColor: Color.fromARGB(255, 51, 51, 51),
                     child: Icon(Icons.crop,color: Colors.cyanAccent,),
                     onPressed: () async{

                       _cropImage(File(widget.imagePath));

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
  Future<File> _cropImage(File imageFile) async {
    File croppedFile = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        aspectRatioPresets: Platform.isAndroid
        ? [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9
        ]
        : [
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio5x3,
        CropAspectRatioPreset.ratio5x4,
        CropAspectRatioPreset.ratio7x5,
        CropAspectRatioPreset.ratio16x9
        ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Crop ',
            toolbarColor: Color.fromARGB(255, 51, 51, 51),
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          title: 'Crop',
        ));
    if (croppedFile != null) {

      setState ( () {
       // pages.insert(pages.indexOf(widget.imagePath), croppedFile.path);
       try {
         pages.removeWhere((element) => element == widget.imagePath);
         widget.imagePath = croppedFile.path;
       }catch (e){
         Fluttertoast.showToast(msg: "Crop failed");
       }
      });
      Fluttertoast.showToast(msg: "Cropped");

    }
  }
}
Future<String> get _localFile async {
 // final path = await _localPath;
 // print(path);
  String time = 'bytesPDFScanner'+Random().nextInt(100000).toString();

  return "$time.pdf";
}
