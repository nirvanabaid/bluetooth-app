import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_bluetooth_serial_example/constants/constant_color.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
class pdb extends StatefulWidget {
  final BluetoothDevice server;

  const pdb({required this.server});

  @override
  _pdb createState() => new _pdb();
}

class _Message {
  int whom;
  String text;

  _Message(this.whom, this.text);
}

class _pdb extends State<pdb> {
  bool ignoreNoFP= true;
  String latestReadData="";
  int no_of_messages_received=0;
  int i=0;
  static final clientID = 0;
  BluetoothConnection? connection;

  List<_Message> messages = List<_Message>.empty(growable: true);
  String _messageBuffer = '';

  final TextEditingController textEditingController =
  new TextEditingController();
  final ScrollController listScrollController = new ScrollController();

  bool isConnecting = false;
  bool get isConnected => (connection?.isConnected ?? false);
  bool filterOn=true;
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
                      await _sendMessage("params");
                      await changeDetect();
                      if(latestReadData != null) { // or any other condition you have to validate latestReadData
                        setState(() {
                          i = no_of_messages_received;
                        });
                        //_showSimpleDialog(latestReadData, "PARAMS");
                        _showParamsDialog(latestReadData);
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
                      "Params",
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
                      await _sendMessage("helmet");
                      await changeDetect();
                      if(latestReadData != null) { // or any other condition you have to validate latestReadData
                        setState(() {
                          i = no_of_messages_received;
                        });
                        //_showSimpleDialog(latestReadData, "PARAMS");
                        _showHelmetDialog(latestReadData);
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
                  child: Center(child: Text("Helmet Config", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: height*0.02),),),
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
                          await _sendMessage("wifi");
                          await changeDetect();
                          _showSimpleDialog(latestReadData, "WIFI");
                        }
                            : null,
                        child: Center(child: Text("WIFI", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: height*0.02),),),
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
                            await _sendMessage("wifi");
                            await changeDetect();
                            if(latestReadData != null) { // or any other condition you have to validate latestReadData
                              setState(() {
                                i = no_of_messages_received;
                              });
                              //_showSimpleDialog(latestReadData, "PARAMS");
                              _showWifiDialog(latestReadData);
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
                        child: Center(child: Text("WIFI Config", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: height*0.02),),),
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
                            ? () {
                          _sendMessage("configure");
                        }
                            : null,
                        child: Center(child: Text("Configure", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: height*0.02),),),
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
                          await _sendMessage("tempdebug");
                        }
                            : null,
                        child: Center(child: Text("Toggle TempDebug", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: height*0.02),),),
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
                            ? () {
                          _sendMessage("ESP_RST");
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
                          await _sendMessage("debug");
                        }
                            : null,
                        child: Center(child: Text("Toggle DBG", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: height*0.02),),),
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
                          _showSimpleDialog(latestReadData, "VERSION");
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
                            await _sendMessage("name");
                            await changeDetect();
                            if(latestReadData != null) { // or any other condition you have to validate latestReadData
                              setState(() {
                                i = no_of_messages_received;
                              });
                              //_showSimpleDialog(latestReadData, "PARAMS");
                              _showNameDialog(latestReadData);
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
                        child: Center(child: Text("Name", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: height*0.02),),),
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

              // Padding(
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
              SizedBox(height: height*0.016,),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: width*0.055, vertical: height*0.005),
                child: ElevatedButton(
                  onPressed: isConnected
                      ? () {
                        showSnackBar(context, "Under Construction", highlight);
                  }
                      : null,
                  child: Center(child: Text("CAS Config", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: height*0.02),),),
                  style: ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(background),
                    shape: MaterialStatePropertyAll(RoundedRectangleBorder( borderRadius: BorderRadius.circular(9), side: BorderSide(width: 2, color: highlight))),
                    padding: MaterialStatePropertyAll(EdgeInsets.symmetric(vertical: height*0.016)),

                  ),
                ),
              ),
              // Padding(
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

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text("Summary", style: TextStyle(fontSize: height*0.03, fontWeight: FontWeight.w500, color: Colors.white),)),

                  Container(
                    margin: EdgeInsets.only(right: width*0.04),
                    decoration: BoxDecoration(
                      color: background,
                      border: Border.all(color: highlight, width: 2),
                      borderRadius: BorderRadius.circular(9)
                      
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: width*0.025, vertical: height*0.00),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding:  EdgeInsets.only(left: width*0.05),
                            child: Text("Filter", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: height*0.023),),
                          ),
                          SizedBox(
                            width: width*0.04,
                          ),
                          Switch(
                            // This bool value toggles the switch.
                            value: filterOn,
                            inactiveThumbColor: Colors.redAccent,
                            inactiveTrackColor: Colors.redAccent.withOpacity(0.2),
                            activeColor: highlight,
                            onChanged: (bool value) {
                              // This is called when the user toggles the switch.
                              setState(() {
                                filterOn = value;

                              });
                            },
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
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
    String dataString = String.fromCharCodes(buffer);
    int index = buffer.indexOf(13);
    String abc=  backspacesCounter > 0
        ? _messageBuffer.substring(
        0, _messageBuffer.length - backspacesCounter)
        : _messageBuffer + dataString.substring(0, index);

    if (~index != 0) {
      setState(() {
       if(filterOn == true)
         {
           if(abc != "No FP" && abc != "No Key" && abc != "No SB" && abc != "No Helmet")
           {
             messages.add(
               _Message(
                 1,
                 abc,
               ),
             );

             if(abc != "No FP" && abc != "No Key" && abc != "No SB" && abc != "No Helmet")
             {
               List<int> asciiValues = [];

               for (int i = 0; i < abc.length; i++) {
                 int ascii = abc.codeUnitAt(i);
                 asciiValues.add(ascii);
               }
               print("string- "+abc);
               print("ascii- " +asciiValues.toString());
               latestReadData=abc;
               no_of_messages_received ++;
             }
             List<int> asciiValues = [];

             for (int i = 0; i < abc.length; i++) {
               int ascii = abc.codeUnitAt(i);
               asciiValues.add(ascii);
             }
             print("message sent- " + abc +" -- "+ asciiValues.toString());

           }
           else{
             print(filterOn);
             print("removed");
           }
         }
       else{

         messages.add(
           _Message(
             1,
             abc,
           ),
         );

         if(abc != "No FP")
         {
           List<int> asciiValues = [];

           for (int i = 0; i < abc.length; i++) {
             int ascii = abc.codeUnitAt(i);
             asciiValues.add(ascii);
           }
           print("string--"+abc);
           print("ascii--" +asciiValues.toString());
           latestReadData=abc;
           no_of_messages_received ++;
         }
         List<int> asciiValues = [];

         for (int i = 0; i < abc.length; i++) {
           int ascii = abc.codeUnitAt(i);
           asciiValues.add(ascii);
         }
         print("message sent- " + abc +" -- "+ asciiValues.toString());

       }

      }
      );
    } else {
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
    print("Change Detected.");
  }

  Future<void> _showSimpleDialog(String version, String title) async {
    await showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return Dialog( // <-- SEE HERE
            child: SizedBox(
              height: 200,
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

  Future<void> _showParamsDialog(String a ) async{
    print("Entered Dialog");
    Map<String, dynamic> data = jsonDecode(a);
    String data_string= jsonEncode(data);
    print("=========================================================\n=========================================================");
    int? selectedOptionKey= data["KEY"];
    int? AC= data["AC"];
    int? SB= data["SB"];
    int? EMR= data["EMR"];
    int? ALR= data["ALR"];
    int? HMI= data["HMI"];
    final TextEditingController SLK =new TextEditingController(text: data["SLK"].toString());
    final TextEditingController BRK =new TextEditingController(text: data["BRK"].toString());
    final TextEditingController BYP =new TextEditingController(text: data["BYP"].toString());
    int? OTA= data["OTA"];
    int? DBG= (data["DBG"]==false)?0:1;








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
                    title: Text("Params"),
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
                              child: Text("KEY", style: TextStyle(color:Colors.white,fontSize: height*0.025, fontWeight: FontWeight.w500),)),
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
                                value: selectedOptionKey,
                                onChanged: (int? newValue) {
                                  setState(() {
                                    selectedOptionKey = newValue;
                                  });
                                },
                                items: [
                                  DropdownMenuItem<int>(
                                    value: 1,
                                    child: Text(
                                      '1',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  DropdownMenuItem<int>(
                                    value: 2,
                                    child: Text(
                                      '2',
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
                              child: Text("AC", style: TextStyle(color:Colors.white,fontSize: height*0.025, fontWeight: FontWeight.w500),)),
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
                                value: AC,
                                onChanged: (int? newValue) {
                                  setState(() {
                                    AC = newValue;
                                  });
                                },
                                items: [
                                  DropdownMenuItem<int>(
                                    value: 1,
                                    child: Text(
                                      '1',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  DropdownMenuItem<int>(
                                    value: 2,
                                    child: Text(
                                      '2',
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
                              child: Text("SB", style: TextStyle(color:Colors.white,fontSize: height*0.025, fontWeight: FontWeight.w500),)),
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
                                value: SB,
                                onChanged: (int? newValue) {
                                  setState(() {
                                    SB = newValue;
                                  });
                                },
                                items: [
                                  DropdownMenuItem<int>(
                                    value: 1,
                                    child: Text(
                                      '1',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  DropdownMenuItem<int>(
                                    value: 2,
                                    child: Text(
                                      '2',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  DropdownMenuItem<int>(
                                    value: 3,
                                    child: Text(
                                      '3',
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
                              child: Text("EMR", style: TextStyle(color:Colors.white,fontSize: height*0.025, fontWeight: FontWeight.w500),)),
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
                                value: EMR,
                                onChanged: (int? newValue) {
                                  setState(() {
                                    EMR = newValue;
                                  });
                                },
                                items: [
                                  DropdownMenuItem<int>(
                                    value: 1,
                                    child: Text(
                                      '1',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  DropdownMenuItem<int>(
                                    value: 2,
                                    child: Text(
                                      '2',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  DropdownMenuItem<int>(
                                    value: 3,
                                    child: Text(
                                      '3',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  DropdownMenuItem<int>(
                                    value: 4,
                                    child: Text(
                                      '4',
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
                              child: Text("ALR", style: TextStyle(color:Colors.white,fontSize: height*0.025, fontWeight: FontWeight.w500),)),
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
                                value: ALR,
                                onChanged: (int? newValue) {
                                  setState(() {
                                    ALR = newValue;
                                  });
                                },
                                items: [
                                  DropdownMenuItem<int>(
                                    value: 1,
                                    child: Text(
                                      '1',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  DropdownMenuItem<int>(
                                    value: 2,
                                    child: Text(
                                      '2',
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
                              child: Text("HMI", style: TextStyle(color:Colors.white,fontSize: height*0.025, fontWeight: FontWeight.w500),)),
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
                                value: HMI,
                                onChanged: (int? newValue) {
                                  setState(() {
                                    HMI = newValue;
                                  });
                                },
                                items: [
                                  DropdownMenuItem<int>(
                                    value: 1,
                                    child: Text(
                                      '1',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  DropdownMenuItem<int>(
                                    value: 2,
                                    child: Text(
                                      '2',
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
                              child: Text("SLK", style: TextStyle(color:Colors.white,fontSize: height*0.025, fontWeight: FontWeight.w500),)),
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
                              controller: SLK,
                              decoration: InputDecoration.collapsed(
                                hintText: "Enter value for SLK",
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
                              child: Text("BRK", style: TextStyle(color:Colors.white,fontSize: height*0.025, fontWeight: FontWeight.w500),)),
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
                              controller: BRK,
                              decoration: InputDecoration.collapsed(
                                hintText: "Enter value for BRK",
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
                              child: Text("BYP", style: TextStyle(color:Colors.white,fontSize: height*0.025, fontWeight: FontWeight.w500),)),
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
                              controller: BYP,
                              decoration: InputDecoration.collapsed(
                                hintText: "Enter value for BYP",
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
                              child: Text("DBG", style: TextStyle(color:Colors.white,fontSize: height*0.025, fontWeight: FontWeight.w500),)),
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
                                value: DBG,
                                onChanged: (int? newValue) {
                                  setState(() {
                                    DBG = newValue;
                                  });
                                },
                                items: [
                                  DropdownMenuItem<int>(
                                    value: 0,
                                    child: Text(
                                      'false',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  DropdownMenuItem<int>(
                                    value: 1,
                                    child: Text(
                                      'true',
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

                                String dbgRes=(DBG==0)?"false":"true";
                                String res='params{"KEY":'+selectedOptionKey.toString()+',"AC":'+AC.toString()+',"SB":'+SB.toString()+',"EMR":'+EMR.toString()+',"ALR": '+ALR.toString()+',"HMI":'+HMI.toString()+',"SLK":'+SLK.text+',"BRK":'+BRK.text+',"BYP":'+BYP.text+',"OTA":'+OTA.toString()+',"DBG":'+dbgRes+'}';
                                print(res);
                                await _sendMessage(res);
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

  Future<void> _showHelmetDialog(String a ) async{
    print("Entered Dialog");
    Map<String, dynamic> data = jsonDecode(a);
    String data_string= jsonEncode(data);
    print("=========================================================\n=========================================================");

    int? HEL= data["HEL"];
    final TextEditingController HDS =new TextEditingController(text: data["HDS"].toString());
    final TextEditingController HL1 =new TextEditingController(text: data["HL1"].toString());
    final TextEditingController HL2 =new TextEditingController(text: data["HL2"].toString());
    final TextEditingController HL3 =new TextEditingController(text: data["HL3"].toString());









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
                    title: Text("Helmet"),
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
                              child: Text("HEL", style: TextStyle(color:Colors.white,fontSize: height*0.025, fontWeight: FontWeight.w500),)),
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
                                value: HEL,
                                onChanged: (int? newValue) {
                                  setState(() {
                                    HEL = newValue;
                                  });
                                },
                                items: [
                                  DropdownMenuItem<int>(
                                    value: 1,
                                    child: Text(
                                      '1',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  DropdownMenuItem<int>(
                                    value: 2,
                                    child: Text(
                                      '2',
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
                              child: Text("HDS", style: TextStyle(color:Colors.white,fontSize: height*0.025, fontWeight: FontWeight.w500),)),
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
                              controller: HDS,
                              decoration: InputDecoration.collapsed(
                                hintText: "Enter value for HDS",
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
                              child: Text("HL1", style: TextStyle(color:Colors.white,fontSize: height*0.025, fontWeight: FontWeight.w500),)),
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
                              controller: HL1,
                              decoration: InputDecoration.collapsed(
                                hintText: "Enter value for HL1",
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
                              child: Text("HL2", style: TextStyle(color:Colors.white,fontSize: height*0.025, fontWeight: FontWeight.w500),)),
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
                              controller: HL2,
                              decoration: InputDecoration.collapsed(
                                hintText: "Enter value for HL2",
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
                              child: Text("HL2", style: TextStyle(color:Colors.white,fontSize: height*0.025, fontWeight: FontWeight.w500),)),
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
                              controller: HL3,
                              decoration: InputDecoration.collapsed(
                                hintText: "Enter value for HL3",
                                hintStyle:  TextStyle(color: Colors.white),
                              ),
                              enabled: isConnected,
                            ),
                          ),



                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: width*0.025, vertical: height*0.005),
                            child: ElevatedButton(
                              onPressed: isConnected
                                  ? () async{

                                String res='helmet{"HEL":'+HEL.toString()+',"HDS":'+HDS.text+',"HL1":"'+HL1.text+'","HL2 ":"'+HL2.text+'","HL3":"'+HL3.text+'"}';
                                print(res);
                                await _sendMessage(res);
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

  Future<void> _showWifiDialog(String a ) async{
    print("Entered Dialog");
    Map<String, dynamic> data = jsonDecode(a);
    String data_string= jsonEncode(data);
    print("=========================================================\n=========================================================");

    final TextEditingController ssid =new TextEditingController(text: data["ssid"].toString());
    final TextEditingController pass =new TextEditingController(text: data["pass"].toString());
    final TextEditingController ip =new TextEditingController(text: data["ip"].toString());
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
                    title: Text("WIFI Config"),
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
                              child: Text("SSID", style: TextStyle(color:Colors.white,fontSize: height*0.025, fontWeight: FontWeight.w500),)),
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
                              controller: ssid,
                              decoration: InputDecoration.collapsed(
                                hintText: "Enter value for SSID",
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
                              child: Text("PASS", style: TextStyle(color:Colors.white,fontSize: height*0.025, fontWeight: FontWeight.w500),)),
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
                              controller: pass,
                              decoration: InputDecoration.collapsed(
                                hintText: "Enter value for PASS",
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
                              controller: ip,
                              decoration: InputDecoration.collapsed(
                                hintText: "Enter value for IP",
                                hintStyle:  TextStyle(color: Colors.white),
                              ),
                              enabled: isConnected,
                            ),
                          ),



                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: width*0.025, vertical: height*0.005),
                            child: ElevatedButton(
                              onPressed: isConnected
                                  ? () async{

                                String res='wifi{"ssid":"'+ssid.text+'","pass":"'+pass.text+'","ip":'+ip.text+'}';
                                print(res);
                                await _sendMessage(res);
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

  Future<void> _showNameDialog(String a ) async{
    print("Entered Dialog");
    Map<String, dynamic> data = jsonDecode(a);
    String data_string= jsonEncode(data);
    print("=========================================================\n=========================================================");

    final TextEditingController nam =new TextEditingController(text: data["NAM"].toString());

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
                    title: Text("Name Config"),
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
                              child: Text("NAME", style: TextStyle(color:Colors.white,fontSize: height*0.025, fontWeight: FontWeight.w500),)),
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
                              controller: nam,
                              decoration: InputDecoration.collapsed(
                                hintText: "Enter value for Name",
                                hintStyle:  TextStyle(color: Colors.white),
                              ),
                              enabled: isConnected,
                            ),
                          ),


                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: width*0.025, vertical: height*0.005),
                            child: ElevatedButton(
                              onPressed: isConnected
                                  ? () async{

                                String res='name{"NAM":"'+nam.text+'"}';
                                print(res);
                                await _sendMessage(res);
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



}
