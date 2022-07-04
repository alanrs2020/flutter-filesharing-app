import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:bytes/WifiDirect.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';
import 'globals.dart' as globals;

class popUpMenu extends StatefulWidget {
  @override
  _popUpMenuState createState() => _popUpMenuState();
}
 class _popUpMenuState extends State {
   @override
   Widget build(BuildContext context) {
     // TODO: implement build
     return PopupMenuButton(
         onSelected: (value) {
           /*Fluttertoast.showToast(msg: "Selected: $value",
               toastLength: Toast.LENGTH_SHORT,
               gravity: ToastGravity.TOP,
               timeInSecForIosWeb: 1,
               backgroundColor: Colors.amber,
               textColor: Colors.black,
               fontSize: 16.0);*/
           if(value == 2){
             showDialog(
                 context: context,
                 barrierDismissible: true,
                 builder: (_) {
                   return AlertDialog(
                     title: Row(children: [
                       Icon(Icons.color_lens_outlined),
                       Text("Select Theme"),
                     ],),
                     content: Text("Choose one color from below"),
                     actions: <Widget>[
                       TextButton(child: Text("Amber",style: TextStyle(color: Colors.amber),),
                         onPressed:() async{

                           Navigator.pop(context);
                           globals.themeColor = Colors.amber;



                         },
                       ),

                       TextButton(onPressed: (){
                         Navigator.pop(context);
                         globals.themeColor = Colors.deepPurple;
                       },
                           child: Text("Purple",style: TextStyle(color: Colors.deepPurple))),
                   TextButton(child: Text("Blue",style: TextStyle(color: Colors.blue),),
                   onPressed:(){
                     Navigator.pop(context);
                     globals.themeColor = Colors.blue;
                   },),
                     ],
                     //backgroundColor: Colors.amber,
                   );
                 });
           }
           else if(value == 1){
             showDialog(
                 context: context,
                 barrierDismissible: false,
                 builder: (_) {
                   return AlertDialog(
                     title: Text("Disconnect"),
                     content: Text("Are you sure want to Disconnect from all device ?"),
                     actions: <Widget>[
                       TextButton(child: Text("No",style: TextStyle(color: Colors.amber)),
                         onPressed:(){ Navigator.pop(context);},
                       ),
                       TextButton(onPressed: (){
                         Navigator.pop(context);
                         WifiDirect(onlineAction: (String value) {  },).invokeDisConnect(context);
                       },
                           child: Text("Yes",style: TextStyle(color: Colors.amber)))
                     ],
                     //backgroundColor: Colors.amber,
                   );
                 });


           }else if(value == 5) {
             try{
                launch("https://bytesweb.web.app/help.html");
             }catch(msg){
               print('Could not launch help'+msg.toString());
             }
           }
           else if(value == 4){
             Share.share("https://play.google.com/store/apps/details?id=com.bytes");
           }
         },
         itemBuilder: (context) =>
         [
           if(globals.device_Id.isNotEmpty)

           PopupMenuItem(
               value: 1,
               child:
               Row(
                 children: [
                   Padding(
                     padding: EdgeInsets.fromLTRB(2, 2, 8, 2),
                     child:
                     Card(
                       clipBehavior: Clip.hardEdge,
                       child: Icon(Icons.wifi_off_outlined,color: Colors.cyan,),
                       elevation: 10,
                       color: Color.fromARGB(255, 55, 55, 55),
                       shape: RoundedRectangleBorder(
                           borderRadius: BorderRadius.circular(5)
                       ),
                     ),
                   ),

                   Text("Disconnect"),
                 ],
               )

           ) ,

           /*PopupMenuItem(
               value: 2,
               child:
               Row(
                 children: [
                   Padding(
                     padding: EdgeInsets.fromLTRB(2, 2, 8, 2),
                     child:
                     Icon(Icons.color_lens_outlined),
                   ),

                   Text("Theme"),
                 ],
               )

           ),
           PopupMenuItem(
               value: 3,
               child:
               Row(
                 children: [
                   Padding(
                     padding: EdgeInsets.fromLTRB(2, 2, 8, 2),
                     child:
                     Icon(Icons.dangerous, color: Colors.deepOrange,),
                   ),

                   Text("Kill Button"),
                 ],
               )

           ),*/
           PopupMenuItem(
               value: 4,
               child:
               Row(
                 children: [
                   Padding(
                     padding: EdgeInsets.fromLTRB(2, 2, 8, 2),
                     child:
                     Card(
                       clipBehavior: Clip.hardEdge,
                       child: Icon(Icons.share_outlined,color: Colors.cyan,),
                       elevation: 10,
                       color: Color.fromARGB(255, 55, 55, 55),
                       shape: RoundedRectangleBorder(
                           borderRadius: BorderRadius.circular(5)
                       ),
                     ),
                   ),
                   Text("Share"),
                 ],
               )

           ),
           PopupMenuItem(
               value: 5,
               child:
               Row(
                 children: [
                   Padding(
                     padding: EdgeInsets.fromLTRB(2, 2, 8, 2),
                     child:
                     Card(
                       clipBehavior: Clip.hardEdge,
                       child: Icon(Icons.help_center_outlined,color: Colors.cyan,),
                       elevation: 10,
                       color: Color.fromARGB(255, 55, 55, 55),
                       shape: RoundedRectangleBorder(
                           borderRadius: BorderRadius.circular(5)
                       ),
                     ),
                   ),

                   Text("Help"),
                 ],
               )

           )
         ]

     );
   }

   // ignore: non_constant_identifier_names

 }