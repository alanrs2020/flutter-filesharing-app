import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'globals.dart' as globals;

class sendFile {
  sendFile(
      this.title,
      this.path
      );
  final String path;
  final String title;



 void sendfile() async {



   for (MapEntry<String, ConnectionInfo> m in globals.endpointMap.entries) {


     int payloadId = await Nearby().sendFilePayload(m.key, path);

     print(path);
     Fluttertoast.showToast(
         msg: "Sending $title to " + m.key,
         toastLength: Toast.LENGTH_SHORT,
         gravity: ToastGravity.TOP,
         timeInSecForIosWeb: 1,
         backgroundColor: Color.fromARGB(255, 55 ,55, 55),
         textColor: Colors.cyanAccent,
         fontSize: 16.0
     );
     globals.titleName[payloadId] = title;
     Nearby().sendBytesPayload(m.key, Uint8List.fromList("$payloadId:$title".codeUnits));

   }
 }


}
class sender with ChangeNotifier{
  final String id;
  final String title;
  String size;
  String bytes;
  double pValue;


  sender({
    this.id,
    this.title,
    this.size,
    this.bytes,
    this.pValue,
  });
}







