import 'dart:async';

import 'package:flutter/material.dart';

class test extends StatefulWidget {
  const test({Key? key}) : super(key: key);

  @override
  State<test> createState() => _testState();
}

class _testState extends State<test> {
  int i=0;
  int j=0;


  void changeVariableAfterDelay() {

    Timer(Duration(seconds: 3), () {
      setState(() {
        i=(i==0)?1:0;
      });

    });
  }
  Future<void> changeDetect () async{
     while(i==j){
      await Future.delayed(Duration(milliseconds: 100));
     }
     j=i;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ElevatedButton(
              child: Text("PRESS"),
              onPressed: () async{
                print("FIRST CALL");
                changeVariableAfterDelay();
                await changeDetect();
                print("Second CALL");


              },
            ),
            ElevatedButton(onPressed: (){
              setState(() {
                i=(i==0)?1:0;
                print(i);
              });
            }, child: Text("Change"))
          ],
        ),
      )
    );
  }
}
