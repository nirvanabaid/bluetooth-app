import 'package:flutter/material.dart';

Color background= Color(0xff222222);
Color highlight= Color(0xffF1A600);
Color background2= Color(0xFF444444);

void showSnackBar(BuildContext context, String text, Color bg) {
  final snackBar = SnackBar(
    content: Container(child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.campaign, color: Colors.white,),
        SizedBox(width: MediaQuery.of(context).size.width*0.03,),
        Text(text, style: TextStyle(fontSize: MediaQuery.of(context).size.width*0.05, fontWeight: FontWeight.w500),),
      ],
    )),
    backgroundColor: bg,
    behavior: SnackBarBehavior.floating,
    width: MediaQuery.of(context).size.width*0.8,

  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
