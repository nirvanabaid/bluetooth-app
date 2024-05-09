import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_bluetooth_serial_example/constants/constant_color.dart';
import 'package:flutter_bluetooth_serial_example/devices/fp_enrol.dart';
import 'package:http/http.dart' as http;
class fp extends StatefulWidget {
  final BluetoothDevice server;

  const fp({required this.server});

  @override
  _fp createState() => new _fp();
}

class _Message {
  int whom;
  String text;

  _Message(this.whom, this.text);
}

class _fp extends State<fp> {
  bool ignoreNoFP= true;
  String latestReadData="";
  String temp="";
  int no_of_messages_received=0;
  int i=0;
  bool recv=false;
  static final clientID = 0;
  BluetoothConnection? connection;

  List<_Message> messages = List<_Message>.empty(growable: true);
  String _messageBuffer = '';

  final TextEditingController textEditingController =
  new TextEditingController();
  final ScrollController listScrollController = new ScrollController();

  bool isConnecting = false;
  bool get isConnected => (connection?.isConnected ?? false);
  bool crON=true;
  bool isDisconnecting = false;

  @override


  void initState() {
    super.initState();
    connectToDevice();

  }

  void connectToDevice() {
    BluetoothConnection.toAddress(widget.server.address).then((_connection) {
      print('Connected to the device');
      connection = _connection;
      setState(() {
        isConnecting = false;
        isDisconnecting = false;
      });

      connection!.input!.listen(_onDataReceived).onDone(() {
        if (isDisconnecting) {
          print('Disconnecting locally!');
        } else {
          print('Disconnected remotely!');
        }
        if (this.mounted) {
          setState(() {});
        }
      });
    }).catchError((error) {
      print('Cannot connect, an exception occurred');
      print(error);
    });
  }

  void reconnect() {
    if(isConnected){
      showSnackBar(context, "Already Connected", highlight);
    }
    else{
      setState(() {
        isConnecting = false;
        isDisconnecting = false;
      });
      connectToDevice();
    }
  }


  @override
  void dispose() {
    // Avoid memory leak (`setState` after dispose) and disconnect
    if (isConnected) {
      isDisconnecting = true;
      connection?.dispose();
      connection = null;
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Row> list = messages.map((_message) {
      return Row(
        children: <Widget>[
          Container(
            child: Text(
                    (text) {
                  return text == '/shrug' ? '¯\\_(ツ)_/¯' : text;
                }(_message.text.trim()),
                style: TextStyle(color: Colors.white)),
            padding: EdgeInsets.all(12.0),
            margin: EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0),
            width: 222.0,
            decoration: BoxDecoration(
                color:
                _message.whom == clientID ? Colors.blueAccent : Colors.green,
                borderRadius: BorderRadius.circular(7.0)),
          ),
        ],
        mainAxisAlignment: _message.whom == clientID
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
      );
    }).toList();

    final serverName = widget.server.name ?? "Unknown";
    var width=MediaQuery.of(context).size.width;
    var height=MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: background2,
      appBar: AppBar(
        backgroundColor: background,
        title: (isConnecting
            ? Text('Connecting chat to ' + serverName + '...')
            : isConnected
            ? Text('Live chat with ' + serverName)
            : Text('Chat log with ' + serverName)),
        actions: [
          IconButton(onPressed: (){
            reconnect();
          }, icon: Icon(Icons.refresh))
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(height: 20,),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: width*0.055, vertical: height*0.005),
                child: ElevatedButton(
                  onPressed: isConnected
                      ? () async {

                    try {
                      await _sendMessage("settings");
                      await changeDetect();
                      if(latestReadData != null) { // or any other condition you have to validate latestReadData
                        setState(() {
                          i = no_of_messages_received;
                        });
                        //await _showSimpleDialog(latestReadData, "SETTINGS");
                        await _showSettingsDialog(latestReadData);
                      } else {
                        print("latestReadData is not ready");
                        showSnackBar(context, "latestReadData not available.\nPlease try again.", Colors.red);
                      }
                    } catch (error) {
                      print("An error occurred: $error. Dialog box can't be opened");
                      showSnackBar(context, "An error occured.\nPlease try again.", Colors.red);
                    }
                  }
                      : null,
                  child: Center(
                    child: Text(
                      "Settings",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: height*0.02
                      ),
                    ),
                  ),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(background),
                    shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9),
                            side: BorderSide(width: 2, color: highlight)
                        )
                    ),
                    padding: MaterialStateProperty.all(EdgeInsets.symmetric(vertical: height*0.016)),
                  ),
                ),

              ),
              SizedBox(height: height*0.016,),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: width*0.055, vertical: height*0.005),
                child: ElevatedButton(
                  onPressed: isConnected
                      ? () async {

                    try {
                      await _sendMessage("Devicetype");
                      await changeDetect();
                      if(latestReadData != null) { // or any other condition you have to validate latestReadData
                        setState(() {
                          i = no_of_messages_received;
                        });
                        //await _showSimpleDialog(latestReadData, "PARAMS");
                        await _showDeviceDialog(latestReadData);
                      } else {
                        print("latestReadData is not ready");
                        showSnackBar(context, "latestReadData not available.\nPlease try again.", Colors.red);
                      }
                    } catch (error) {
                      print("An error occurred: $error. Dialog box can't be opened");
                      showSnackBar(context, "An error occured.\nPlease try again.", Colors.red);
                    }
                  }
                      : null,
                  child: Center(child: Text("Device Type", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: height*0.02),),),
                  style: ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(background),
                    shape: MaterialStatePropertyAll(RoundedRectangleBorder( borderRadius: BorderRadius.circular(9), side: BorderSide(width: 2, color: highlight))),
                    padding: MaterialStatePropertyAll(EdgeInsets.symmetric(vertical: height*0.016)),

                  ),
                ),
              ),

              SizedBox(height: height*0.016,),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: width*0.055, vertical: height*0.005),
                child: ElevatedButton(
                  onPressed: isConnected
                      ? () async {

                    try {
                      await _sendMessage("Devicetype");
                      await changeDetect();
                      Map<String, dynamic> data = jsonDecode(latestReadData);
                      print(data["TOKEN"]);
                      if(true)
                      {
                        try {
                          int res=await Navigator.push(context, MaterialPageRoute(builder: (context) => fp_enrol(server: widget.server, key_opt: 0, rfi: 0, dev_token: data["TOKEN"]),maintainState: true));
                          showSnackBar(context, (res==1)?"POSTED":"FAILED", (res==1)?Colors.green:Colors.red);

                        } catch (error) {
                          print("An error occurred: $error. Screen can't be opened");
                          showSnackBar(context, "An error occured.\nPlease try again.", Colors.red);
                        }
                      }
                      else{
                        showSnackBar(context, "Enrolment not possible!!", Colors.red);
                      }
                    } catch (error) {
                      print("An error occurred: $error. Dialog box can't be opened");
                      showSnackBar(context, "An error occured.\nPlease try again.", Colors.red);
                    }
                  }
                      : null,
                  child: Center(child: Text("ENROL", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: height*0.02),),),
                  style: ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(background),
                    shape: MaterialStatePropertyAll(RoundedRectangleBorder( borderRadius: BorderRadius.circular(9), side: BorderSide(width: 2, color: highlight))),
                    padding: MaterialStatePropertyAll(EdgeInsets.symmetric(vertical: height*0.016)),

                  ),
                ),
              ),

              SizedBox(height: height*0.016,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: width*0.5,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: width*0.055, vertical: height*0.005),
                      child: ElevatedButton(
                        onPressed: isConnected
                            ? () async{
                          await _sendMessage("enrData");
                          await changeDetect();
                          i=no_of_messages_received;
                          _showSimpleDialog(latestReadData, "enrData");
                        }
                            : null,
                        child: Center(child: Text("enrData", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: height*0.02),),),
                        style: ButtonStyle(
                          backgroundColor: MaterialStatePropertyAll(background),
                          shape: MaterialStatePropertyAll(RoundedRectangleBorder( borderRadius: BorderRadius.circular(9), side: BorderSide(width: 2, color: highlight))),
                          padding: MaterialStatePropertyAll(EdgeInsets.symmetric(vertical: height*0.016, horizontal: width*0.05)),

                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: width*0.5,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: width*0.055, vertical: height*0.005),
                      child: ElevatedButton(
                        onPressed: isConnected
                            ? () async {

                          try {
                            await _sendMessage("list");
                            await changeDetect();
                            if(latestReadData != null) { // or any other condition you have to validate latestReadData
                              setState(() {
                                i = no_of_messages_received;
                              });
                              _showSimpleDialog(latestReadData, "PARAMS");
                              //_showEnrolDialog();
                            } else {
                              print("latestReadData is not ready");
                              showSnackBar(context, "latestReadData not available.\nPlease try again.", Colors.red);
                            }
                          } catch (error) {
                            print("An error occurred: $error. Dialog box can't be opened");
                            showSnackBar(context, "An error occured.\nPlease try again.", Colors.red);
                          }
                        }
                            : null,
                        child: Center(child: Text("LIST", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: height*0.02),),),
                        style: ButtonStyle(
                          backgroundColor: MaterialStatePropertyAll(background),
                          shape: MaterialStatePropertyAll(RoundedRectangleBorder( borderRadius: BorderRadius.circular(9), side: BorderSide(width: 2, color: highlight))),
                          padding: MaterialStatePropertyAll(EdgeInsets.symmetric(vertical: height*0.016, horizontal: width*0.05)),

                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: height*0.016,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: width*0.5,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: width*0.055, vertical: height*0.005),
                      child: ElevatedButton(
                        onPressed: isConnected
                            ? () async {

                          try {
                            await _sendMessage("list");
                            await changeDetect();
                            if(latestReadData != null) { // or any other condition you have to validate latestReadData
                              setState(() {
                                i = no_of_messages_received;
                              });
                              //await _showSimpleDialog(latestReadData, "SETTINGS");
                              await _showEnrDelDialog(latestReadData);
                            } else {
                              print("latestReadData is not ready");
                              showSnackBar(context, "latestReadData not available.\nPlease try again.", Colors.red);
                            }
                          } catch (error) {
                            print("An error occurred: $error. Dialog box can't be opened");
                            showSnackBar(context, "An error occured.\nPlease try again.", Colors.red);
                          }
                        }
                            : null,
                        child: Center(child: Text("Del Emp", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: height*0.02),),),
                        style: ButtonStyle(
                          backgroundColor: MaterialStatePropertyAll(background),
                          shape: MaterialStatePropertyAll(RoundedRectangleBorder( borderRadius: BorderRadius.circular(9), side: BorderSide(width: 2, color: highlight))),
                          padding: MaterialStatePropertyAll(EdgeInsets.symmetric(vertical: height*0.016, horizontal: width*0.05)),

                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: width*0.5,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: width*0.055, vertical: height*0.005),
                      child: ElevatedButton(
                        onPressed: isConnected
                            ? () async{
                          await _sendMessage("log");
                          await changeDetect();
                          i=no_of_messages_received;
                          await _showSimpleDialog(latestReadData, "LOG");
                        }
                            : null,
                        child: Center(child: Text("LOG", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: height*0.02),),),
                        style: ButtonStyle(
                          backgroundColor: MaterialStatePropertyAll(background),
                          shape: MaterialStatePropertyAll(RoundedRectangleBorder( borderRadius: BorderRadius.circular(9), side: BorderSide(width: 2, color: highlight))),
                          padding: MaterialStatePropertyAll(EdgeInsets.symmetric(vertical: height*0.016, horizontal: width*0.05)),

                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: height*0.016,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: width*0.5,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: width*0.055, vertical: height*0.005),
                      child: ElevatedButton(
                        onPressed: isConnected
                            ? () async{
                          await _sendMessage("ota1");
                        }
                            : null,
                        child: Center(child: Text("OTA", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: height*0.02),),),
                        style: ButtonStyle(
                          backgroundColor: MaterialStatePropertyAll(background),
                          shape: MaterialStatePropertyAll(RoundedRectangleBorder( borderRadius: BorderRadius.circular(9), side: BorderSide(width: 2, color: highlight))),
                          padding: MaterialStatePropertyAll(EdgeInsets.symmetric(vertical: height*0.016, horizontal: width*0.05)),

                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: width*0.5,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: width*0.055, vertical: height*0.005),
                      child: ElevatedButton(
                        onPressed: isConnected
                            ? () async{
                          await _sendMessage("ota2");
                        }
                            : null,
                        child: Center(child: Text("OTA via  Web", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: height*0.02),),),
                        style: ButtonStyle(
                          backgroundColor: MaterialStatePropertyAll(background),
                          shape: MaterialStatePropertyAll(RoundedRectangleBorder( borderRadius: BorderRadius.circular(9), side: BorderSide(width: 2, color: highlight))),
                          padding: MaterialStatePropertyAll(EdgeInsets.symmetric(vertical: height*0.016, horizontal: width*0.05)),

                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: height*0.016,),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: width*0.5,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: width*0.055, vertical: height*0.005),
                      child: ElevatedButton(
                        onPressed: isConnected
                            ? () async {
                          await _sendMessage("reset");
                          await changeDetect();
                          i=no_of_messages_received;
                          await _showResetlDialog();
                        }
                            : null,
                        child: Center(child: Text("ESP_RST", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: height*0.02),),),
                        style: ButtonStyle(
                          backgroundColor: MaterialStatePropertyAll(background),
                          shape: MaterialStatePropertyAll(RoundedRectangleBorder( borderRadius: BorderRadius.circular(9), side: BorderSide(width: 2, color: highlight))),
                          padding: MaterialStatePropertyAll(EdgeInsets.symmetric(vertical: height*0.016, horizontal: width*0.05)),

                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: width*0.5,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: width*0.055, vertical: height*0.005),
                      child: ElevatedButton(
                        onPressed: isConnected
                            ? () async{
                          await _sendMessage("boot");

                          showSnackBar(context, "BOOT command sent", Colors.green);
                        }
                            : null,
                        child: Center(child: Text("BOOT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: height*0.02),),),
                        style: ButtonStyle(
                          backgroundColor: MaterialStatePropertyAll(background),
                          shape: MaterialStatePropertyAll(RoundedRectangleBorder( borderRadius: BorderRadius.circular(9), side: BorderSide(width: 2, color: highlight))),
                          padding: MaterialStatePropertyAll(EdgeInsets.symmetric(vertical: height*0.016, horizontal: width*0.05)),

                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: height*0.016,),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: width*0.5,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: width*0.055, vertical: height*0.005),
                      child: ElevatedButton(
                        onPressed: isConnected
                            ? () async{
                          _sendMessage("version");
                          await changeDetect();
                          i=no_of_messages_received;
                          // await changeDetect();
                          // i=no_of_messages_received;

                          await _showSimpleDialog(temp+latestReadData, "VERSION");
                        }
                            : null,
                        child: Center(child: Text("Version", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: height*0.02),),),
                        style: ButtonStyle(
                          backgroundColor: MaterialStatePropertyAll(background),
                          shape: MaterialStatePropertyAll(RoundedRectangleBorder( borderRadius: BorderRadius.circular(9), side: BorderSide(width: 2, color: highlight))),
                          padding: MaterialStatePropertyAll(EdgeInsets.symmetric(vertical: height*0.016, horizontal: width*0.05)),

                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: width*0.5,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: width*0.055, vertical: height*0.005),
                      child: ElevatedButton(
                        onPressed: isConnected
                            ? () async {

                          try {
                            await _sendMessage("nums");
                            await changeDetect();
                            if(latestReadData != null) { // or any other condition you have to validate latestReadData
                              setState(() {
                                i = no_of_messages_received;
                              });
                              //_showSimpleDialog(latestReadData, "PARAMS");

                              await _showNumsDialog(latestReadData);
                            } else {
                              print("latestReadData is not ready");
                              showSnackBar(context, "latestReadData not available.\nPlease try again.", Colors.red);
                            }
                          } catch (error) {
                            print("An error occurred: $error. Dialog box can't be opened");
                            showSnackBar(context, "An error occured.\nPlease try again.", Colors.red);
                          }
                        }
                            : null,
                        child: Center(child: Text("Nums", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: height*0.02),),),
                        style: ButtonStyle(
                          backgroundColor: MaterialStatePropertyAll(background),
                          shape: MaterialStatePropertyAll(RoundedRectangleBorder( borderRadius: BorderRadius.circular(9), side: BorderSide(width: 2, color: highlight))),
                          padding: MaterialStatePropertyAll(EdgeInsets.symmetric(vertical: height*0.016, horizontal: width*0.05)),

                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: height*0.016,),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: width*0.5,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: width*0.055, vertical: height*0.005),
                      child: ElevatedButton(
                        onPressed: isConnected
                            ? () async{
                          _sendMessage("clearCrash");
                          showSnackBar(context, "clearCrash command sent", Colors.green);
                        }
                            : null,
                        child: Center(child: Text("Clear Crash", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: height*0.02),),),
                        style: ButtonStyle(
                          backgroundColor: MaterialStatePropertyAll(background),
                          shape: MaterialStatePropertyAll(RoundedRectangleBorder( borderRadius: BorderRadius.circular(9), side: BorderSide(width: 2, color: highlight))),
                          padding: MaterialStatePropertyAll(EdgeInsets.symmetric(vertical: height*0.016, horizontal: width*0.05)),

                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: width*0.5,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: width*0.055, vertical: height*0.005),
                      child: ElevatedButton(
                        onPressed: isConnected
                            ? () async {
                          await _sendMessage("posted");
                          showSnackBar(context, "POST command sent", Colors.green);
                        }
                            : null,
                        child: Center(child: Text("Posted", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: height*0.02),),),
                        style: ButtonStyle(
                          backgroundColor: MaterialStatePropertyAll(background),
                          shape: MaterialStatePropertyAll(RoundedRectangleBorder( borderRadius: BorderRadius.circular(9), side: BorderSide(width: 2, color: highlight))),
                          padding: MaterialStatePropertyAll(EdgeInsets.symmetric(vertical: height*0.016, horizontal: width*0.05)),

                        ),
                      ),
                    ),
                  ),
                ],
              ),
              //
              SizedBox(height: height*0.016,),

              Padding(
                  padding: EdgeInsets.symmetric(horizontal: width*0.06),
                  child: Text("Write Data", style: TextStyle(color:Colors.white,fontSize: height*0.025, fontWeight: FontWeight.w500),)),
              Container(
                height: height*0.06,
                padding:EdgeInsets.symmetric(vertical: height*0.015, horizontal: width*0.05),
                decoration:  BoxDecoration(
                    color: background,
                    border: Border.all(
                      color: highlight,
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.circular(10)
                ),
                margin: EdgeInsets.symmetric(horizontal: width*0.055, vertical: height*0.005),
                child: TextField(
                  cursorColor: Colors.tealAccent,

                  style:  TextStyle(fontSize: height*0.02, color: Colors.white),
                  controller: textEditingController,
                  decoration: InputDecoration.collapsed(
                    hintText: isConnecting
                        ? 'Wait until connected...'
                        : isConnected
                        ? 'Type your message...'
                        : 'Chat got disconnected',
                    hintStyle: const TextStyle(color: Colors.white),
                  ),
                  enabled: isConnected,
                ),
              ),
              Align(
                alignment: Alignment.centerRight,

                child: SizedBox(
                  width: width*0.35,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: width*0.055, vertical: height*0.005),
                    child: ElevatedButton(
                      onPressed: isConnected
                          ? () => _sendMessage(textEditingController.text)
                          : null,
                      child: Center(child: Text("SEND", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: height*0.019),),),
                      style: ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll(background),
                        shape: MaterialStatePropertyAll(RoundedRectangleBorder( borderRadius: BorderRadius.circular(9), side: BorderSide(width: 2, color: highlight))),

                      ),
                    ),
                  ),
                ),
              ),
              //     padding: EdgeInsets.symmetric(horizontal: width*0.06),
              //     child: Text("Write Data", style: TextStyle(color:Colors.white,fontSize: height*0.025, fontWeight: FontWeight.w500),)),
              // Container(
              //   height: height*0.06,
              //   padding:EdgeInsets.symmetric(vertical: height*0.015, horizontal: width*0.05),
              //   decoration:  BoxDecoration(
              //       color: background,
              //       border: Border.all(
              //         color: highlight,
              //         width: 2.0,
              //       ),
              //       borderRadius: BorderRadius.circular(10)
              //   ),
              //   margin: EdgeInsets.symmetric(horizontal: width*0.055, vertical: height*0.005),
              //   child: TextField(
              //     cursorColor: Colors.tealAccent,
              //
              //     style:  TextStyle(fontSize: height*0.02, color: Colors.white),
              //     controller: textEditingController,
              //     decoration: InputDecoration.collapsed(
              //       hintText: isConnecting
              //           ? 'Wait until connected...'
              //           : isConnected
              //           ? 'Type your message...'
              //           : 'Chat got disconnected',
              //       hintStyle: const TextStyle(color: Colors.white),
              //     ),
              //     enabled: isConnected,
              //   ),
              // ),
              // Align(
              //   alignment: Alignment.centerRight,
              //
              //   child: SizedBox(
              //     width: width*0.35,
              //     child: Padding(
              //       padding: EdgeInsets.symmetric(horizontal: width*0.055, vertical: height*0.005),
              //       child: ElevatedButton(
              //         onPressed: isConnected
              //             ? () => _sendMessage(textEditingController.text)
              //             : null,
              //         child: Center(child: Text("SEND", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: height*0.019),),),
              //         style: ButtonStyle(
              //           backgroundColor: MaterialStatePropertyAll(background),
              //           shape: MaterialStatePropertyAll(RoundedRectangleBorder( borderRadius: BorderRadius.circular(9), side: BorderSide(width: 2, color: highlight))),
              //
              //         ),
              //       ),
              //     ),
              //   ),
              // ),
              SizedBox(height: height*0.04,),

              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text("Summary", style: TextStyle(fontSize: height*0.03, fontWeight: FontWeight.w500, color: Colors.white),)),
              SizedBox(
                height: height*0.4,
                child: Container(
                  decoration:  BoxDecoration(
                      color: background,
                      border: Border.all(
                        color: highlight,
                        width: 3.0,
                      ),
                      borderRadius: BorderRadius.circular(10)
                  ),
                  margin: EdgeInsets.symmetric(horizontal: width*0.055, vertical: height*0.005),

                  child: ListView(
                      shrinkWrap: true,
                      //physics: NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(12.0),
                      // controller: listScrollController,
                      children: list),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onDataReceived(Uint8List data) {
    // Allocate buffer for parsed data
    int backspacesCounter = 0;
    data.forEach((byte) {
      if (byte == 8 || byte == 127) {
        backspacesCounter++;
      }
    });
    Uint8List buffer = Uint8List(data.length - backspacesCounter);
    int bufferIndex = buffer.length;

    // Apply backspace control character
    backspacesCounter = 0;
    for (int i = data.length - 1; i >= 0; i--) {
      if (data[i] == 8 || data[i] == 127) {
        backspacesCounter++;
      } else {
        if (backspacesCounter > 0) {
          backspacesCounter--;
        } else {
          buffer[--bufferIndex] = data[i];
        }
      }
    }

    // Create message if there is new line character
    String dataString = String.fromCharCodes(buffer)+'\n';
    print(dataString);
    int index = buffer.indexOf(13);
    //if ()
    if (true)
    {
      setState(() {
        messages.add(
          _Message(
            1,
            backspacesCounter > 0
                ? _messageBuffer.substring(
                0, _messageBuffer.length - backspacesCounter)
                : _messageBuffer + dataString.substring(0, dataString.length),
          ),
        );

        temp=latestReadData;
        latestReadData=backspacesCounter > 0
            ? _messageBuffer.substring(
            0, _messageBuffer.length - backspacesCounter)
            : _messageBuffer + dataString.substring(0, dataString.length);
        _messageBuffer = dataString.substring(dataString.length);

        setState(() {
          no_of_messages_received ++;
        });

      });


    } else {
      print("hi");
      _messageBuffer = (backspacesCounter > 0
          ? _messageBuffer.substring(
          0, _messageBuffer.length - backspacesCounter)
          : _messageBuffer + dataString);
    }
  }


  Future<void> _sendMessage(String text) async {
    text = text.trim();
    textEditingController.clear();

    if (text.length > 0) {
      try {
        connection!.output.add(Uint8List.fromList(utf8.encode(text)));
        await connection!.output.allSent;

        setState(() {
          messages.add(_Message(clientID, text));
        });

        Future.delayed(Duration(milliseconds: 333)).then((_) {
          listScrollController.animateTo(
              listScrollController.position.maxScrollExtent,
              duration: Duration(milliseconds: 333),
              curve: Curves.easeOut);
        });
      } catch (e) {
        // Ignore error, but notify state
        setState(() {});
      }
    }
  } //end of _sendMessage

  Future<void> changeDetect () async{
    while(i == no_of_messages_received){
      await Future.delayed(Duration(milliseconds: 100));
    }
    setState(() {
      i=no_of_messages_received;
    });
    print("Change Detected.");
  }

  Future<String> waitForSuccess () async{
    while(!latestReadData.startsWith('success')){

      await Future.delayed(Duration(milliseconds: 2000));
      print("for success- $latestReadData");
    }
    setState(() {
      i=no_of_messages_received;
    });
    print("succcessDetected");
    return latestReadData;
  }

  Future<void> _showSimpleDialog(String version, String title) async {
    await showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          var height= MediaQuery.of(context).size.height;
          return Dialog( // <-- SEE HERE
            child: SizedBox(
              height: height*0.7,
              child: Scaffold(
                backgroundColor: background2,
                appBar: AppBar(
                  backgroundColor: background,
                  title: Text(title),
                ),
                body: Container(
                  color: background2,
                  height: 200,
                  child: Center(
                    child: Text(version, style: TextStyle(color: Colors.white),),
                  ),
                ),
              ),
            ),
          );
        });
  }

  Future<void> _showSettingsDialog(String a ) async{
    print("Entered Dialog");
    Map<String, dynamic> data = jsonDecode(a);
    String data_string= jsonEncode(data);
    print("=========================================================\n=========================================================");


    final TextEditingController IP =new TextEditingController(text: data["ip"].toString());

    int? OTA= data["OTA"];
    int? CRSH= (data["CRSH"]==false)?0:1;
    var height=MediaQuery.of(context).size.height;
    var width=MediaQuery.of(context).size.width;
    await showDialog<void>(
        barrierDismissible: false,
        barrierColor: Colors.black87,
        context: context,
        builder: (BuildContext context){

          return Dialog(

              child: SizedBox(
                height:height*0.7,
                child: Scaffold(
                  backgroundColor: background2,
                  appBar: AppBar(
                    title: Text("Settings"),
                    backgroundColor: background,
                    elevation: 0,
                    automaticallyImplyLeading: false,
                    actions: [
                      IconButton(onPressed: (){Navigator.pop(context);}, icon: Icon(Icons.close))
                    ],
                  ),
                  body: SingleChildScrollView(
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          SizedBox(
                            height: height*0.02,
                          ),
                          Padding(
                              padding: EdgeInsets.symmetric(horizontal: width*0.06),
                              child: Text("IP", style: TextStyle(color:Colors.white,fontSize: height*0.025, fontWeight: FontWeight.w500),)),
                          Container(
                            padding:EdgeInsets.symmetric(vertical: height*0.015, horizontal: width*0.05),
                            decoration:  BoxDecoration(
                                color: background,
                                border: Border.all(
                                  color: highlight,
                                  width: 2.0,
                                ),
                                borderRadius: BorderRadius.circular(10)
                            ),
                            margin: EdgeInsets.symmetric(horizontal: width*0.055, vertical: height*0.005),
                            child: TextField(
                              cursorColor: Colors.tealAccent,
                              keyboardType: TextInputType.number,
                              style:  TextStyle(fontSize: height*0.02, color: Colors.white),
                              controller: IP,
                              decoration: InputDecoration.collapsed(
                                hintText: "Enter value for IP",
                                hintStyle:  TextStyle(color: Colors.white),
                              ),
                              enabled: isConnected,
                            ),
                          ),


                          SizedBox(
                            height: height*0.02,
                          ),
                          Padding(
                              padding: EdgeInsets.symmetric(horizontal: width*0.06),
                              child: Text("OTA", style: TextStyle(color:Colors.white,fontSize: height*0.025, fontWeight: FontWeight.w500),)),
                          Container(
                            padding: EdgeInsets.symmetric(vertical: height * 0.015, horizontal: width * 0.05),
                            decoration: BoxDecoration(
                              color: background,
                              border: Border.all(
                                color: highlight,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            margin: EdgeInsets.symmetric(horizontal: width * 0.055, vertical: height * 0.005),
                            child: IgnorePointer(
                              ignoring: !isConnected, // Disable the dropdown menu if isConnected is false
                              child: DropdownButtonFormField<int>(
                                value: OTA,
                                onChanged: (int? newValue) {
                                  setState(() {
                                    OTA = newValue;
                                  });
                                },
                                items: [
                                  DropdownMenuItem<int>(
                                    value: 0,
                                    child: Text(
                                      '0',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  DropdownMenuItem<int>(
                                    value: 1,
                                    child: Text(
                                      '1',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),

                                ],
                                dropdownColor: background2,
                                icon: Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.white,
                                ),
                                iconSize: height * 0.03,
                                style: TextStyle(fontSize: height * 0.02, color: Colors.white),
                                decoration: InputDecoration.collapsed(
                                  hintText: "Select an option",
                                  hintStyle: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ),


                          SizedBox(
                            height: height*0.02,
                          ),
                          Padding(
                              padding: EdgeInsets.symmetric(horizontal: width*0.06),
                              child: Text("CRSH", style: TextStyle(color:Colors.white,fontSize: height*0.025, fontWeight: FontWeight.w500),)),
                          Container(
                            padding: EdgeInsets.symmetric(vertical: height * 0.015, horizontal: width * 0.05),
                            decoration: BoxDecoration(
                              color: background,
                              border: Border.all(
                                color: highlight,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            margin: EdgeInsets.symmetric(horizontal: width * 0.055, vertical: height * 0.005),
                            child: IgnorePointer(
                              ignoring: !isConnected, // Disable the dropdown menu if isConnected is false
                              child: DropdownButtonFormField<int>(
                                value: CRSH,
                                onChanged: (int? newValue) {
                                  setState(() {
                                    CRSH = newValue;
                                  });
                                },
                                items: [
                                  DropdownMenuItem<int>(
                                    value: 0,
                                    child: Text(
                                      'False',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  DropdownMenuItem<int>(
                                    value: 1,
                                    child: Text(
                                      'True',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),

                                ],
                                dropdownColor: background2,
                                icon: Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.white,
                                ),
                                iconSize: height * 0.03,
                                style: TextStyle(fontSize: height * 0.02, color: Colors.white),
                                decoration: InputDecoration.collapsed(
                                  hintText: "Select an option",
                                  hintStyle: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ),


                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: width*0.025, vertical: height*0.005),
                            child: ElevatedButton(
                              onPressed: isConnected
                                  ? () async{

                                String crshRes=(CRSH==0)?"false":"true";
                                String res='settings{"ip":'+IP.text+',"CRSH":'+crshRes+',"OTA":'+OTA.toString()+'}';
                                print(res);
                                await _sendMessage(res);
                                await changeDetect();
                                setState(() {
                                  no_of_messages_received=i;
                                });
                                Navigator.pop(context);
                                showSnackBar(context, "Data Updated", Colors.green);
                              } : null,
                              child: Center(child: Text("CONFIGURE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: height*0.02),),),
                              style: ButtonStyle(
                                backgroundColor: MaterialStatePropertyAll(background),
                                shape: MaterialStatePropertyAll(RoundedRectangleBorder( borderRadius: BorderRadius.circular(9), side: BorderSide(width: 2, color: highlight))),
                                padding: MaterialStatePropertyAll(EdgeInsets.symmetric(vertical: height*0.016)),

                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  ),
                ),
              )
          );
        }
    );
  }

  Future<void> _showDeviceDialog(String a ) async{
    print("Entered Dialog");
    Map<String, dynamic> data = jsonDecode(a);
    String data_string= jsonEncode(data);
    print("=========================================================\n=========================================================");

    int? TYPE= (data["TYPE"] == 'FP')? 0:1;
    int? PIN= data["PIN"];
    final TextEditingController TOKEN =new TextEditingController(text: data["TOKEN"].toString());
    var height=MediaQuery.of(context).size.height;
    var width=MediaQuery.of(context).size.width;
    await showDialog<void>(
        barrierDismissible: false,
        barrierColor: Colors.black87,
        context: context,
        builder: (BuildContext context){

          return Dialog(

              child: SizedBox(
                height:height*0.5,
                child: Scaffold(
                  backgroundColor: background2,
                  appBar: AppBar(
                    title: Text("Device Type"),
                    backgroundColor: background,
                    elevation: 0,
                    automaticallyImplyLeading: false,
                    actions: [
                      IconButton(onPressed: (){Navigator.pop(context);}, icon: Icon(Icons.close))
                    ],
                  ),
                  body: SingleChildScrollView(
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          SizedBox(
                            height: height*0.02,
                          ),
                          Padding(
                              padding: EdgeInsets.symmetric(horizontal: width*0.06),
                              child: Text("Type", style: TextStyle(color:Colors.white,fontSize: height*0.025, fontWeight: FontWeight.w500),)),
                          Container(
                              width: width,
                              height: height*0.07,
                              padding: EdgeInsets.symmetric(vertical: height * 0.015, horizontal: width * 0.05),
                              decoration: BoxDecoration(
                                color: background,
                                border: Border.all(
                                  color: highlight,
                                  width: 2.0,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              margin: EdgeInsets.symmetric(horizontal: width * 0.055, vertical: height * 0.005),
                              child: Center(child: Text(data["TYPE"].toString(), style: TextStyle(color: Colors.white, fontSize: height*0.02),))
                          ),

                          SizedBox(
                            height: height*0.02,
                          ),
                          Padding(
                              padding: EdgeInsets.symmetric(horizontal: width*0.06),
                              child: Text("PIN", style: TextStyle(color:Colors.white,fontSize: height*0.025, fontWeight: FontWeight.w500),)),
                          Container(
                            padding: EdgeInsets.symmetric(vertical: height * 0.015, horizontal: width * 0.05),
                            decoration: BoxDecoration(
                              color: background,
                              border: Border.all(
                                color: highlight,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            margin: EdgeInsets.symmetric(horizontal: width * 0.055, vertical: height * 0.005),
                            child: Center(
                              child: Text(data["PIN"].toString(), style: TextStyle(color: Colors.white, fontSize: height*0.02),),),
                          ),

                          SizedBox(
                            height: height*0.02,
                          ),
                          Padding(
                              padding: EdgeInsets.symmetric(horizontal: width*0.06),
                              child: Text("TOKEN", style: TextStyle(color:Colors.white,fontSize: height*0.025, fontWeight: FontWeight.w500),)),
                          Container(
                              padding:EdgeInsets.symmetric(vertical: height*0.015, horizontal: width*0.05),
                              decoration:  BoxDecoration(
                                  color: background,
                                  border: Border.all(
                                    color: highlight,
                                    width: 2.0,
                                  ),
                                  borderRadius: BorderRadius.circular(10)
                              ),
                              margin: EdgeInsets.symmetric(horizontal: width*0.055, vertical: height*0.005),
                              child: Center(child: Text(data["TOKEN"], style: TextStyle(color: Colors.white, fontSize: height*0.02),),)
                          ),


                        ],
                      ),
                    ),

                  ),
                ),
              )
          );
        }
    );
  }

  Future<void> _showEnrolDialog(String deviceToken, int? key, int? rfi) async{
    print("Entered Dialog");

    print("=========================================================\n=========================================================");

    int? keypad=key;
    int? rfid=rfi;
    final TextEditingController eName =new TextEditingController();
    final TextEditingController eCode =new TextEditingController();
    final TextEditingController eId =new TextEditingController();
    final TextEditingController eRole =new TextEditingController();
    final TextEditingController pass=new TextEditingController();
    final TextEditingController devToken =new TextEditingController(text: deviceToken);
    var height=MediaQuery.of(context).size.height;
    var width=MediaQuery.of(context).size.width;
    await showDialog<void>(
        barrierDismissible: false,
        barrierColor: Colors.black87,
        context: context,
        builder: (BuildContext context){

          return Dialog(

              child: SizedBox(
                height:height*0.7,
                child: Scaffold(
                  backgroundColor: background2,
                  appBar: AppBar(
                    title: Text("ENROL"),
                    backgroundColor: background,
                    elevation: 0,
                    automaticallyImplyLeading: false,
                    actions: [
                      IconButton(onPressed: (){Navigator.pop(context);}, icon: Icon(Icons.close))
                    ],
                  ),
                  body: SingleChildScrollView(
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          SizedBox(
                            height: height*0.02,
                          ),
                          Padding(
                              padding: EdgeInsets.symmetric(horizontal: width*0.06),
                              child: Text("Keypad", style: TextStyle(color:Colors.white,fontSize: height*0.025, fontWeight: FontWeight.w500),)),
                          Container(
                            padding: EdgeInsets.symmetric(vertical: height * 0.015, horizontal: width * 0.05),
                            decoration: BoxDecoration(
                              color: background,
                              border: Border.all(
                                color: highlight,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            margin: EdgeInsets.symmetric(horizontal: width * 0.055, vertical: height * 0.005),
                            child: IgnorePointer(
                              ignoring: !isConnected, // Disable the dropdown menu if isConnected is false
                              child: DropdownButtonFormField<int>(
                                value: keypad,
                                onChanged: (int? newValue) {
                                  setState(() {
                                    keypad = newValue;

                                  });
                                  Navigator.pop(context);
                                  _showEnrolDialog(deviceToken, keypad, rfid);
                                },
                                items: [
                                  DropdownMenuItem<int>(
                                    value: 0,
                                    child: Text(
                                      'No',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  DropdownMenuItem<int>(
                                    value: 1,
                                    child: Text(
                                      'Yes',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),

                                ],
                                dropdownColor: background2,
                                icon: Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.white,
                                ),
                                iconSize: height * 0.03,
                                style: TextStyle(fontSize: height * 0.02, color: Colors.white),
                                decoration: InputDecoration.collapsed(
                                  hintText: "Select an option",
                                  hintStyle: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ),

                          SizedBox(
                            height: height*0.02,
                          ),
                          Padding(
                              padding: EdgeInsets.symmetric(horizontal: width*0.06),
                              child: Text("RFID", style: TextStyle(color:Colors.white,fontSize: height*0.025, fontWeight: FontWeight.w500),)),
                          Container(
                            padding: EdgeInsets.symmetric(vertical: height * 0.015, horizontal: width * 0.05),
                            decoration: BoxDecoration(
                              color: background,
                              border: Border.all(
                                color: highlight,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            margin: EdgeInsets.symmetric(horizontal: width * 0.055, vertical: height * 0.005),
                            child: IgnorePointer(
                              ignoring: !isConnected, // Disable the dropdown menu if isConnected is false
                              child: DropdownButtonFormField<int>(
                                value: rfid,
                                onChanged: (int? newValue) {
                                  setState(() {
                                    rfid = newValue;
                                  });
                                },
                                items: [
                                  DropdownMenuItem<int>(
                                    value: 0,
                                    child: Text(
                                      'No',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  DropdownMenuItem<int>(
                                    value: 1,
                                    child: Text(
                                      'Yes',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                                dropdownColor: background2,
                                icon: Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.white,
                                ),
                                iconSize: height * 0.03,
                                style: TextStyle(fontSize: height * 0.02, color: Colors.white),
                                decoration: InputDecoration.collapsed(
                                  hintText: "Select an option",
                                  hintStyle: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ),


                          SizedBox(
                            height: (keypad==1)?height*0.02:0,
                          ),
                          Padding(
                              padding: EdgeInsets.symmetric(horizontal: width*0.06),
                              child: Text((keypad==1)?"Password":"", style: TextStyle(color:Colors.white,fontSize: height*0.025, fontWeight: FontWeight.w500),)),
                          Container(

                            padding:(keypad==1)?EdgeInsets.symmetric(vertical: height*0.015, horizontal: width*0.05):EdgeInsets.symmetric(vertical: height*0, horizontal: width*0),
                            decoration: (keypad==1)?BoxDecoration(
                                color: background,
                                border: Border.all(
                                  color: highlight,
                                  width: 2.0,
                                ),
                                borderRadius: BorderRadius.circular(10)
                            ):
                            BoxDecoration(),
                            margin: (keypad==1)?EdgeInsets.symmetric(horizontal: width*0.055, vertical: height*0.005):EdgeInsets.symmetric(vertical: height*0, horizontal: width*0),
                            child: (keypad==1)?
                            TextField(
                              maxLength: 6,
                              keyboardType: TextInputType.number,
                              cursorColor: Colors.tealAccent,
                              style:  TextStyle(fontSize: height*0.02, color: Colors.white),
                              controller: pass,

                              decoration: InputDecoration.collapsed(
                                hintText: "Enter 6 digit pass",
                                hintStyle:  TextStyle(color: Colors.white),
                              ),
                              enabled: isConnected,
                            ):
                            SizedBox(
                              height: 0,
                            ),
                          ),


                          SizedBox(
                            height: height*0.02,
                          ),
                          Padding(
                              padding: EdgeInsets.symmetric(horizontal: width*0.06),
                              child: Text("eName", style: TextStyle(color:Colors.white,fontSize: height*0.025, fontWeight: FontWeight.w500),)),
                          Container(
                            padding:EdgeInsets.symmetric(vertical: height*0.015, horizontal: width*0.05),
                            decoration:  BoxDecoration(
                                color: background,
                                border: Border.all(
                                  color: highlight,
                                  width: 2.0,
                                ),
                                borderRadius: BorderRadius.circular(10)
                            ),
                            margin: EdgeInsets.symmetric(horizontal: width*0.055, vertical: height*0.005),
                            child: TextField(
                              cursorColor: Colors.tealAccent,
                              style:  TextStyle(fontSize: height*0.02, color: Colors.white),
                              controller: eName,
                              decoration: InputDecoration.collapsed(
                                hintText: "Enter value for eName",
                                hintStyle:  TextStyle(color: Colors.white),
                              ),
                              enabled: isConnected,
                            ),
                          ),

                          SizedBox(
                            height: height*0.02,
                          ),
                          Padding(
                              padding: EdgeInsets.symmetric(horizontal: width*0.06),
                              child: Text("eRole", style: TextStyle(color:Colors.white,fontSize: height*0.025, fontWeight: FontWeight.w500),)),
                          Container(
                            padding:EdgeInsets.symmetric(vertical: height*0.015, horizontal: width*0.05),
                            decoration:  BoxDecoration(
                                color: background,
                                border: Border.all(
                                  color: highlight,
                                  width: 2.0,
                                ),
                                borderRadius: BorderRadius.circular(10)
                            ),
                            margin: EdgeInsets.symmetric(horizontal: width*0.055, vertical: height*0.005),
                            child: TextField(
                              cursorColor: Colors.tealAccent,
                              style:  TextStyle(fontSize: height*0.02, color: Colors.white),
                              controller: eRole,
                              decoration: InputDecoration.collapsed(
                                hintText: "Enter value for eRole",
                                hintStyle:  TextStyle(color: Colors.white),
                              ),
                              enabled: isConnected,
                            ),
                          ),

                          SizedBox(
                            height: height*0.02,
                          ),
                          Padding(
                              padding: EdgeInsets.symmetric(horizontal: width*0.06),
                              child: Text("eID", style: TextStyle(color:Colors.white,fontSize: height*0.025, fontWeight: FontWeight.w500),)),
                          Container(
                            padding:EdgeInsets.symmetric(vertical: height*0.015, horizontal: width*0.05),
                            decoration:  BoxDecoration(
                                color: background,
                                border: Border.all(
                                  color: highlight,
                                  width: 2.0,
                                ),
                                borderRadius: BorderRadius.circular(10)
                            ),
                            margin: EdgeInsets.symmetric(horizontal: width*0.055, vertical: height*0.005),
                            child: TextField(
                              cursorColor: Colors.tealAccent,
                              keyboardType: TextInputType.number,
                              style:  TextStyle(fontSize: height*0.02, color: Colors.white),
                              controller: eId,
                              decoration: InputDecoration.collapsed(
                                hintText: "Enter value for eID",
                                hintStyle:  TextStyle(color: Colors.white),
                              ),
                              enabled: isConnected,
                            ),
                          ),

                          SizedBox(
                            height: height*0.02,
                          ),
                          Padding(
                              padding: EdgeInsets.symmetric(horizontal: width*0.06),
                              child: Text("Device Token", style: TextStyle(color:Colors.white,fontSize: height*0.025, fontWeight: FontWeight.w500),)),
                          Container(
                            padding:EdgeInsets.symmetric(vertical: height*0.015, horizontal: width*0.05),
                            decoration:  BoxDecoration(
                                color: background,
                                border: Border.all(
                                  color: highlight,
                                  width: 2.0,
                                ),
                                borderRadius: BorderRadius.circular(10)
                            ),
                            margin: EdgeInsets.symmetric(horizontal: width*0.055, vertical: height*0.005),
                            child: TextField(
                              cursorColor: Colors.tealAccent,

                              style:  TextStyle(fontSize: height*0.02, color: Colors.white),
                              controller: devToken,
                              decoration: InputDecoration.collapsed(
                                hintText: "Enter value for Device Token",
                                hintStyle:  TextStyle(color: Colors.white),
                              ),
                              enabled: isConnected,
                            ),
                          ),


                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: width*0.025, vertical: height*0.005),
                            child: ElevatedButton(
                              onPressed: !isConnected
                                  ? null
                                  : () async {
                                print("clicked");
                                if (eRole.text.trim() != "" &&
                                    eId.text.trim() != "" &&
                                    eName.text.trim() != "" &&
                                    devToken.text.trim() != "" &&
                                    (keypad == 0 || pass.text.trim() != "") &&
                                    (keypad == 0 || keypad ==1) &&
                                    (rfid == 0 || rfid == 1)) {

                                  String res = (rfid==1)?((keypad==1)?('enrol{"eName": "' + eName.text + '", "eRole": "' + eRole.text + '", "eID": "' + eId.text + '", "eCode": "' + pass.text + '","rf":"2"}'): ('enrol{"eName": "' + eName.text + '", "eRole": "' + eRole.text + '", "eID": "' + eId.text + '","rf":"2"}')):((keypad==1)?('enrol{"eName": "' + eName.text + '", "eRole": "' + eRole.text + '", "eID": "' + eId.text + '", "eCode": "' + pass.text + '"}'):('enrol{"eName": "' + eName.text + '", "eRole": "' + eRole.text + '", "eID": "' + eId.text + '"}'));
                                  print(res);
                                  await _sendMessage(res);
                                  String succ_str= await waitForSuccess();
                                  int fpid=int.parse(succ_str.substring(7));

                                  int result= await sendDataToAPI(devToken.text, eName.text, fpid, int.parse(eId.text), eRole.text);
                                  if(result ==1){
                                      await _sendMessage("posted");
                                     await changeDetect();

                                      Navigator.pop(context);
                                      showSnackBar(context, "Data Posted to Cloud", Colors.green);
                                      setState(() {
                                        i=no_of_messages_received;
                                      });
                                  }
                                  else{
                                    Navigator.pop(context);
                                    await changeDetect();
                                    await changeDetect();
                                    showSnackBar(context, "API call failed", Colors.red);
                                  }

                                }
                                else {
                                  showSnackBar(context, "INCOMPLETE", Colors.red);
                                }
                              },

                              child: Center(child: Text("CONFIGURE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: height*0.02),),),
                              style: ButtonStyle(
                                backgroundColor: MaterialStatePropertyAll(background),
                                shape: MaterialStatePropertyAll(RoundedRectangleBorder( borderRadius: BorderRadius.circular(9), side: BorderSide(width: 2, color: highlight))),
                                padding: MaterialStatePropertyAll(EdgeInsets.symmetric(vertical: height*0.016)),

                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  ),
                ),
              )
          );
        }
    );
  }

  Future<void> _showEnrDelDialog(String a) async{
    print("Entered Dialog");

    print("=========================================================\n=========================================================");

    final TextEditingController eName =new TextEditingController();

    var height=MediaQuery.of(context).size.height;
    var width=MediaQuery.of(context).size.width;
    await showDialog<void>(
        barrierDismissible: false,
        barrierColor: Colors.black87,
        context: context,
        builder: (BuildContext context){

          return Dialog(

              child: SizedBox(
                height:height*0.7,
                child: Scaffold(
                  backgroundColor: background2,
                  appBar: AppBar(
                    title: Text("Delete Employee"),
                    backgroundColor: background,
                    elevation: 0,
                    automaticallyImplyLeading: false,
                    actions: [
                      IconButton(onPressed: (){Navigator.pop(context);}, icon: Icon(Icons.close))
                    ],
                  ),
                  body: SingleChildScrollView(
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          SizedBox(
                            height: height*0.02,
                          ),
                          Padding(
                              padding: EdgeInsets.symmetric(horizontal: width*0.06),
                              child: Text("Available Employees", style: TextStyle(color:Colors.white,fontSize: height*0.025, fontWeight: FontWeight.w500),)),
                          Container(
                            padding:EdgeInsets.symmetric(vertical: height*0.015, horizontal: width*0.05),
                            decoration:  BoxDecoration(
                                color: background,
                                border: Border.all(
                                  color: highlight,
                                  width: 2.0,
                                ),
                                borderRadius: BorderRadius.circular(10)
                            ),
                            margin: EdgeInsets.symmetric(horizontal: width*0.055, vertical: height*0.005),
                            child: Center(child: Text(a, style: TextStyle(color: Colors.white),),),
                          ),

                          SizedBox(
                            height: height*0.02,
                          ),
                          Padding(
                              padding: EdgeInsets.symmetric(horizontal: width*0.06),
                              child: Text("eName", style: TextStyle(color:Colors.white,fontSize: height*0.025, fontWeight: FontWeight.w500),)),
                          Container(
                            padding:EdgeInsets.symmetric(vertical: height*0.015, horizontal: width*0.05),
                            decoration:  BoxDecoration(
                                color: background,
                                border: Border.all(
                                  color: highlight,
                                  width: 2.0,
                                ),
                                borderRadius: BorderRadius.circular(10)
                            ),
                            margin: EdgeInsets.symmetric(horizontal: width*0.055, vertical: height*0.005),
                            child: TextField(
                              cursorColor: Colors.tealAccent,
                              style:  TextStyle(fontSize: height*0.02, color: Colors.white),
                              controller: eName,
                              decoration: InputDecoration.collapsed(
                                hintText: "Enter value for eName",
                                hintStyle:  TextStyle(color: Colors.white),
                              ),
                              enabled: isConnected,
                            ),
                          ),





                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: width*0.025, vertical: height*0.005),
                            child: ElevatedButton(
                              onPressed: !isConnected
                                  ? null
                                  : () async {
                                if (eName.text.trim() != "") {
                                  String res = 'delete'+eName.text;
                                  print(res);
                                  await _sendMessage(res);
                                  Navigator.pop(context);
                                  showSnackBar(context, "Data Updated", Colors.green);
                                } else {
                                  showSnackBar(context, "INCOMPLETE", Colors.red);
                                }
                              },

                              child: Center(child: Text("DELETE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: height*0.02),),),
                              style: ButtonStyle(
                                backgroundColor: MaterialStatePropertyAll(background),
                                shape: MaterialStatePropertyAll(RoundedRectangleBorder( borderRadius: BorderRadius.circular(9), side: BorderSide(width: 2, color: highlight))),
                                padding: MaterialStatePropertyAll(EdgeInsets.symmetric(vertical: height*0.016)),

                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  ),
                ),
              )
          );
        }
    );
  }

  Future<void> _showResetlDialog() async{
    print("Entered Dialog");

    print("=========================================================\n=========================================================");

    final TextEditingController eName =new TextEditingController();

    var height=MediaQuery.of(context).size.height;
    var width=MediaQuery.of(context).size.width;
    await showDialog<void>(
        barrierDismissible: false,
        barrierColor: Colors.black87,
        context: context,
        builder: (BuildContext context){

          return Dialog(

              child: SizedBox(
                height:height*0.7,
                child: Scaffold(
                  backgroundColor: background2,
                  appBar: AppBar(
                    title: Text("Reset ESP"),
                    backgroundColor: background,
                    elevation: 0,
                    automaticallyImplyLeading: false,
                    actions: [
                      IconButton(onPressed: (){Navigator.pop(context);}, icon: Icon(Icons.close))
                    ],
                  ),
                  body: SingleChildScrollView(
                    child: Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          SizedBox(
                            height: height*0.02,
                          ),

                          Text("  ARE YOU SURE YOU WANT TO RESET ESP?  ", style: TextStyle(color: Colors.white, fontWeight:
                          FontWeight.bold, fontSize: height*0.034),),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                onPressed: isConnected
                                    ? () async{
                                  _sendMessage("confirmreset");
                                  await changeDetect();
                                  i=no_of_messages_received;
                                  Navigator.pop(context);
                                  showSnackBar(context, "RESET Initiated", highlight);
                                }
                                    : null,
                                child: Text("YES", style: TextStyle(color: Colors.white),),
                                style: ButtonStyle(
                                    backgroundColor: MaterialStatePropertyAll(Colors.green)
                                ),
                              ),

                              ElevatedButton(
                                onPressed: isConnected
                                    ? () async{
                                  _sendMessage("noreset");
                                  await changeDetect();
                                  i=no_of_messages_received;
                                  Navigator.pop(context);
                                  showSnackBar(context, "RESET Cancelled", highlight);
                                }
                                    : null,
                                child: Text("NO", style: TextStyle(color: Colors.white),),
                                style: ButtonStyle(
                                    backgroundColor: MaterialStatePropertyAll(Colors.red)
                                ),
                              ),

                            ],
                          )


                        ],
                      ),
                    ),

                  ),
                ),
              )
          );
        }
    );
  }

  Future<void> _showNumsDialog(String a ) async{
    print("Entered Dialog");

    print("=========================================================\n=========================================================");


    var height=MediaQuery.of(context).size.height;
    var width=MediaQuery.of(context).size.width;
    await showDialog<void>(
        barrierDismissible: false,
        barrierColor: Colors.black87,
        context: context,
        builder: (BuildContext context){

          return Dialog(

              child: SizedBox(
                height:height*0.4,
                child: Scaffold(
                  backgroundColor: background2,
                  appBar: AppBar(
                    title: Text("NUMS"),
                    backgroundColor: background,
                    elevation: 0,
                    automaticallyImplyLeading: false,
                    actions: [
                      IconButton(onPressed: (){Navigator.pop(context);}, icon: Icon(Icons.close))
                    ],
                  ),
                  body: SingleChildScrollView(
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [



                          SizedBox(
                            height: height*0.02,
                          ),
                          Padding(
                              padding: EdgeInsets.symmetric(horizontal: width*0.06),
                              child: Text("Number of users", style: TextStyle(color:Colors.white,fontSize: height*0.025, fontWeight: FontWeight.w500),)),
                          Container(
                              padding:EdgeInsets.symmetric(vertical: height*0.015, horizontal: width*0.05),
                              decoration:  BoxDecoration(
                                  color: background,
                                  border: Border.all(
                                    color: highlight,
                                    width: 2.0,
                                  ),
                                  borderRadius: BorderRadius.circular(10)
                              ),
                              margin: EdgeInsets.symmetric(horizontal: width*0.055, vertical: height*0.005),
                              child: Center(child: Text(a.substring(a.indexOf(':')+1, a.lastIndexOf('S')), style: TextStyle(color: Colors.white),),)
                          ),

                          SizedBox(
                            height: height*0.02,
                          ),
                          Padding(
                              padding: EdgeInsets.symmetric(horizontal: width*0.06),
                              child: Text("Number of templates", style: TextStyle(color:Colors.white,fontSize: height*0.025, fontWeight: FontWeight.w500),)),
                          Container(
                              padding:EdgeInsets.symmetric(vertical: height*0.015, horizontal: width*0.05),
                              decoration:  BoxDecoration(
                                  color: background,
                                  border: Border.all(
                                    color: highlight,
                                    width: 2.0,
                                  ),
                                  borderRadius: BorderRadius.circular(10)
                              ),
                              margin: EdgeInsets.symmetric(horizontal: width*0.055, vertical: height*0.005),
                              child: Center(child: Text(a.substring(a.lastIndexOf(':')+1), style: TextStyle(color: Colors.white),),)
                          ),


                        ],
                      ),
                    ),

                  ),
                ),
              )
          );
        }
    );
  }

  Map<String, dynamic> jsonStringToMap(String jsonString) {
    // Remove any leading or trailing whitespace
    jsonString = jsonString.trim();

    // Remove the outer curly braces
    jsonString = jsonString.substring(1, jsonString.length - 1);

    // Split the string into key-value pairs
    List<String> keyValuePairs = jsonString.split(',');

    // Create a map to store the key-value pairs
    Map<String, dynamic> jsonMap = {};

    // Process each key-value pair
    for (String pair in keyValuePairs) {
      // Split the pair into key and value
      List<String> parts = pair.split(':');

      // Remove any leading or trailing whitespace from the key
      String key = parts[0].trim();

      // Remove the quotes from the key
      key = key.substring(1, key.length - 1);

      // Remove any leading or trailing whitespace from the value
      String value = parts[1].trim();

      // Parse the value depending on its type
      dynamic parsedValue;
      if (value.startsWith('"') && value.endsWith('"')) {
        // Value is a string
        parsedValue = value.substring(1, value.length - 1);
      } else if (value == 'true' || value == 'false') {
        // Value is a boolean
        parsedValue = value == 'true';
      } else {
        // Value is a number
        parsedValue = num.tryParse(value);
      }

      // Add the key-value pair to the map
      jsonMap[key] = parsedValue;
    }

    return jsonMap;
  }//end of jsonStringtoMap

  String convertJsonString(String a) {
    String jsonString =a;
    // Remove spaces around colons and convert values to strings
    jsonString = jsonString.replaceAllMapped(
        RegExp(r'(\w+)\s*:\s*([^,}\s]+)'), (match) => '"${match.group(1)}": "${match.group(2)}"');

    //print(jsonString);
    return jsonString;
  }//end of convertJsonString

  Map<String, dynamic> convertDataTypes(Map<String, dynamic> data) {
    Map<String, dynamic> convertedData = {};

    data.forEach((key, value) {
      if (value is int) {
        convertedData[key] = value;
      } else if (value is double) {
        convertedData[key] = value;
      } else if (value is String) {
        if (value == 'nan') {
          convertedData[key] = double.nan;
        } else if (value.contains('.') && double.tryParse(value) != null) {
          convertedData[key] = double.parse(value);
        } else if (int.tryParse(value) != null) {
          convertedData[key] = int.parse(value);
        } else {
          String a='$value';
          convertedData[key] = a;
        }
      } else {
        String a='$value';
        convertedData[key] = a;
      }
    });

    return convertedData;
  }// end of convertDataTypes

  Future<int> sendDataToAPI(String deviceToken, String name, int fpId, int eId, String eRole) async {
    final String apiUrl = "https://app.trakr.live/api/v1/$deviceToken/attributes";

    Map<String, dynamic> jsonData = {
      "eName": name,
      "fpId": fpId,
      "eID": eId,
      "eRole": eRole,
      "event": "enrol"
    };
    print(jsonData);

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(jsonData),
      );

      if (response.statusCode >=200 && response.statusCode <=201) {
        return 1; // Success
      } else {
        return 0; // Failure
      }
    } catch (e) {
      return 0; // Failure
    }
  }




}

