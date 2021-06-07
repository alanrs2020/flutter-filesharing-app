import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class DialogUtils {
  static DialogUtils _instance = new DialogUtils.internal();

  DialogUtils.internal();

  factory DialogUtils() => _instance;


  static void showCustomDialog(BuildContext context,
      {@required String title,
        String txtcontent,
        String cancelBtnText = "Cancel",
        @required Function cancelBtnFunction}) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: Text(title),
            content: Stack(children: [Image.asset('images/bytesrgif.gif',fit: BoxFit.fill,),
            Text(txtcontent,style: TextStyle(fontSize: 10,color: Colors.black54,),)
            ]),
            actions: <Widget>[
              TextButton(
                  child: Text(cancelBtnText,style: TextStyle(color: Colors.black26),),
                onPressed: (){
                    Navigator.pop(context);
                    cancelBtnFunction();
                },
                   )
            ],
            //backgroundColor: Colors.amber,
            titleTextStyle: TextStyle(color: Colors.cyan,fontSize: 20),
          );
        });
  }
}