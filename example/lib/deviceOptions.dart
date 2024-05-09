import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_bluetooth_serial_example/ChatPage.dart';
import 'package:flutter_bluetooth_serial_example/constants/constant_color.dart';
import 'package:flutter_bluetooth_serial_example/devices/acs.dart';
import 'package:flutter_bluetooth_serial_example/devices/canLogger.dart';
import 'package:flutter_bluetooth_serial_example/devices/casnode.dart';
import 'package:flutter_bluetooth_serial_example/devices/fp.dart';
import 'package:flutter_bluetooth_serial_example/devices/pdb.dart';
import 'package:flutter_bluetooth_serial_example/devices/test.dart';


class deviceOptions extends StatefulWidget {
  const deviceOptions({Key? key, required this.server}) : super(key: key);

  final BluetoothDevice server;


  @override
  State<deviceOptions> createState() => _deviceOptionsState();
}

class _deviceOptionsState extends State<deviceOptions> {
  @override
  Widget build(BuildContext context) {
    var width=MediaQuery.of(context).size.width;
    var height=MediaQuery.of(context).size.height;

    return  Scaffold(
      appBar: AppBar(
        title: Text("Choose a device"),
        backgroundColor: background,
      ),
      backgroundColor: background,
      body: SafeArea(
        child: Padding(
          padding:  EdgeInsets.symmetric(horizontal: width*0.05, vertical: height*0.045),
          child: ListView(
            children: [

              Padding(
                padding:  EdgeInsets.symmetric(vertical:height*0.015),
                child: ElevatedButton(onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => acs(server: widget.server)));
                },
                  child:  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("      ACS", style: TextStyle(color: Colors.white, fontSize: height*0.023),),
                      Icon(Icons.arrow_forward_ios_rounded, color: highlight,)
                    ],
                  ),
                  style: ButtonStyle(
                    padding: MaterialStatePropertyAll(EdgeInsets.symmetric(horizontal: width*0.04, vertical: height*0.03)),
                    backgroundColor: MaterialStatePropertyAll(background2),
                    shape: MaterialStatePropertyAll(RoundedRectangleBorder( borderRadius: BorderRadius.circular(12), side: BorderSide(width: 2, color: highlight))),
                  ),
                ),
              ),
              Padding(
                padding:  EdgeInsets.symmetric(vertical: height*0.015),
                child: ElevatedButton(onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => casnode(server: widget.server)));
                },
                  child:  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("      CasNode", style: TextStyle(color: Colors.white, fontSize: height*0.023),),
                      Icon(Icons.arrow_forward_ios_rounded, color: highlight,)
                    ],
                  ),
                  style: ButtonStyle(
                    padding: MaterialStatePropertyAll(EdgeInsets.symmetric(horizontal: width*0.04, vertical: height*0.03)),
                    backgroundColor: MaterialStatePropertyAll(background2),
                    shape: MaterialStatePropertyAll(RoundedRectangleBorder( borderRadius: BorderRadius.circular(12), side: BorderSide(width: 2, color: highlight))),
                  ),
                ),
              ),

              Padding(
                padding:  EdgeInsets.symmetric(vertical: height*0.015),
                child: ElevatedButton(onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => pdb(server: widget.server)));
                },
                  child:  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("      PDB", style: TextStyle(color: Colors.white, fontSize: height*0.023),),
                      Icon(Icons.arrow_forward_ios_rounded, color: highlight,)
                    ],
                  ),
                  style: ButtonStyle(
                    padding: MaterialStatePropertyAll(EdgeInsets.symmetric(horizontal: width*0.04, vertical: height*0.03)),
                    backgroundColor: MaterialStatePropertyAll(background2),
                    shape: MaterialStatePropertyAll(RoundedRectangleBorder( borderRadius: BorderRadius.circular(12), side: BorderSide(width: 2, color: highlight))),
                  ),
                ),
              ),

               Padding(
                padding:  EdgeInsets.symmetric(vertical: height*0.015),
                child: ElevatedButton(onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => fp(server: widget.server)));
                },
                  child:  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("      FP", style: TextStyle(color: Colors.white, fontSize: height*0.023),),
                      Icon(Icons.arrow_forward_ios_rounded, color: highlight,)
                    ],
                  ),
                  style: ButtonStyle(
                    padding: MaterialStatePropertyAll(EdgeInsets.symmetric(horizontal: width*0.04, vertical: height*0.03)),
                    backgroundColor: MaterialStatePropertyAll(background2),
                    shape: MaterialStatePropertyAll(RoundedRectangleBorder( borderRadius: BorderRadius.circular(12), side: BorderSide(width: 2, color: highlight))),
                  ),
                ),
              ),

              Padding(
                padding:  EdgeInsets.symmetric(vertical: height*0.015),
                child: ElevatedButton(onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => canLogger(server: widget.server)));
                },
                  child:  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("      canLogger", style: TextStyle(color: Colors.white, fontSize: height*0.023),),
                      Icon(Icons.arrow_forward_ios_rounded, color: highlight,)
                    ],
                  ),
                  style: ButtonStyle(
                    padding: MaterialStatePropertyAll(EdgeInsets.symmetric(horizontal: width*0.04, vertical: height*0.03)),
                    backgroundColor: MaterialStatePropertyAll(background2),
                    shape: MaterialStatePropertyAll(RoundedRectangleBorder( borderRadius: BorderRadius.circular(12), side: BorderSide(width: 2, color: highlight))),
                  ),
                ),
              ),

              Padding(
                padding:  EdgeInsets.symmetric(vertical: height*0.015),
                child: ElevatedButton(onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ChatPage(server: widget.server)));
                },
                  child:  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("      Read and Write", style: TextStyle(color: Colors.white, fontSize: height*0.023),),
                      Icon(Icons.arrow_forward_ios_rounded, color: highlight,)
                    ],
                  ),
                  style: ButtonStyle(
                    padding: MaterialStatePropertyAll(EdgeInsets.symmetric(horizontal: width*0.04, vertical: height*0.03)),
                    backgroundColor: MaterialStatePropertyAll(background2),
                    shape: MaterialStatePropertyAll(RoundedRectangleBorder( borderRadius: BorderRadius.circular(12), side: BorderSide(width: 2, color: highlight))),
                  ),
                ),
              ),

              Padding(
                padding:  EdgeInsets.symmetric(vertical: height*0.015),
                child: ElevatedButton(onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => test()));
                },
                  child:  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("      Test", style: TextStyle(color: Colors.white, fontSize: height*0.023),),
                      Icon(Icons.arrow_forward_ios_rounded, color: highlight,)
                    ],
                  ),
                  style: ButtonStyle(
                    padding: MaterialStatePropertyAll(EdgeInsets.symmetric(horizontal: width*0.04, vertical: height*0.03)),
                    backgroundColor: MaterialStatePropertyAll(background2),
                    shape: MaterialStatePropertyAll(RoundedRectangleBorder( borderRadius: BorderRadius.circular(12), side: BorderSide(width: 2, color: highlight))),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
