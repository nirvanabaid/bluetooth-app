import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_bluetooth_serial_example/constants/constant_color.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
class acs extends StatefulWidget {
  final BluetoothDevice server;

  const acs({required this.server});

  @override
  _acs createState() => new _acs();
}

class _Message {
  int whom;
  String text;

  _Message(this.whom, this.text);
}

class _acs extends State<acs> {
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

  bool isDisconnecting = false;

  @override
  // void initState() {
  //   super.initState();
  //
  //   BluetoothConnection.toAddress(widget.server.address).then((_connection) {
  //     print('Connected to the device');
  //     connection = _connection;
  //     setState(() {
  //       isConnecting = false;
  //       isDisconnecting = false;
  //     });
  //
  //     connection!.input!.listen(_onDataReceived).onDone(() {
  //       // Example: Detect which side closed the connection
  //       // There should be `isDisconnecting` flag to show are we are (locally)
  //       // in middle of disconnecting process, should be set before calling
  //       // `dispose`, `finish` or `close`, which all causes to disconnect.
  //       // If we except the disconnection, `onDone` should be fired as result.
  //       // If we didn't except this (no flag set), it means closing by remote.
  //       if (isDisconnecting) {
  //         print('Disconnecting locally!');
  //       } else {
  //         print('Disconnected remotely!');
  //       }
  //       if (this.mounted) {
  //         setState(() {});
  //       }
  //     });
  //   }).catchError((error) {
  //     print('Cannot connect, exception occured');
  //     print(error);
  //   });
  // }

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
                      await _sendMessage("Params");
                      await changeDetect();
                      if(latestReadData != null) { // or any other condition you have to validate latestReadData
                        setState(() {
                          i = no_of_messages_received;
                        });
                        _showFlatDialog(latestReadData);
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
                      "FLAT Config",
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
                      ? () {
                    _showQuadDialog();
                  }
                      : null,
                  child: Center(child: Text("QUAD Config", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: height*0.02),),),
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
                            ? () {
                            showSnackBar(context, "Under Construction", highlight);
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
                            ? () {
                          showSnackBar(context, "Under Construction", highlight);
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
                            ? () {
                          _sendMessage("ota");
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
                            ? () {}
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

              Padding(
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
              SizedBox(height: height*0.016,),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: width*0.055, vertical: height*0.005),
                child: ElevatedButton(
                  onPressed: isConnected
                      ? () async{
                    _sendMessage("!RESET_SPIFFS");

                  }
                      : null,
                  child: Center(child: Text("RESET SPIFFS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: height*0.02),),),
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
    String dataString = String.fromCharCodes(buffer);
    int index = buffer.indexOf(13);
    if (~index != 0) {
      setState(() {
        messages.add(
          _Message(
            1,
            backspacesCounter > 0
                ? _messageBuffer.substring(
                0, _messageBuffer.length - backspacesCounter)
                : _messageBuffer + dataString.substring(0, index),
          ),
        );
        latestReadData=backspacesCounter > 0
            ? _messageBuffer.substring(
            0, _messageBuffer.length - backspacesCounter)
            : _messageBuffer + dataString.substring(0, index);
        _messageBuffer = dataString.substring(index);

        no_of_messages_received ++;

      });
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

  }

  Future<void> _showSimpleDialog(String version, String title) async {
    await showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return Dialog( // <-- SEE HERE
            child: SizedBox(
              height: 200,
              child: Scaffold(
                appBar: AppBar(
                  title: Text(title),
                ),
                body: Container(
                  color: Colors.blueGrey,
                  height: 200,
                  child: Center(
                    child: Text(version),
                  ),
                ),
              ),
            ),
          );
        });
  }

  Future<void> _showFlatDialog(String a ) async{
    String b="{"+a.trim()+"}";
    print(b);
    String params_data= convertJsonString(b);
    print(params_data);
    Map<String, dynamic> data = jsonDecode(params_data);
    String data_string= jsonEncode(data);
    print("=========================================================\n=========================================================");
    print(data_string);
    final TextEditingController X_POS =new TextEditingController(text: data['X_pos']);
    final TextEditingController X_NEG =new TextEditingController(text: data['X_neg']);
    final TextEditingController Alert =new TextEditingController(text: data['ALERT']);
    final TextEditingController Emergency =new TextEditingController(text: data['EMERGENCY']);
    final imageList = ['assets/ACS.png'];
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
                    title: Text("FLAT Configuration"),
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
                          Container(
                            height: height*0.3,
                            child: PhotoViewGallery.builder(

                              itemCount: imageList.length,
                              builder: (context, index) {
                                return PhotoViewGalleryPageOptions(
                                  imageProvider:AssetImage(imageList[index],),
                                  minScale: PhotoViewComputedScale.contained * 0.8,
                                  maxScale: PhotoViewComputedScale.covered * 2,
                                );
                              },
                              scrollPhysics: BouncingScrollPhysics(),
                              backgroundDecoration: BoxDecoration(
                                color: Theme.of(context).canvasColor,
                              ),

                              enableRotation:false,
                              loadingBuilder: (context, event) => Center(
                                child: Container(
                                  width: 30.0,
                                  height: 30.0,
                                  child: CircularProgressIndicator(
                                    backgroundColor:Colors.orange,
                                    value: (event == null || event.expectedTotalBytes == null)
                                        ? 0
                                        : event.cumulativeBytesLoaded / event.expectedTotalBytes!.toDouble(),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: height*0.02,
                          ),
                          Padding(
                              padding: EdgeInsets.symmetric(horizontal: width*0.06),
                              child: Text("A", style: TextStyle(color:Colors.white,fontSize: height*0.025, fontWeight: FontWeight.w500),)),
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
                              controller: X_POS,
                              decoration: InputDecoration.collapsed(
                                hintText: "Enter value for A",
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
                              child: Text("B", style: TextStyle(color:Colors.white,fontSize: height*0.025, fontWeight: FontWeight.w500),)),
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
                              controller: X_NEG,
                              decoration: InputDecoration.collapsed(
                                hintText: "Enter value for B",
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
                              child: Text("ALERT", style: TextStyle(color:Colors.white,fontSize: height*0.025, fontWeight: FontWeight.w500),)),
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
                              controller: Alert,
                              decoration: InputDecoration.collapsed(
                                hintText: "Enter value for Alert",
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
                              child: Text("EMERGENCY", style: TextStyle(color:Colors.white,fontSize: height*0.025, fontWeight: FontWeight.w500),)),
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
                              controller: Emergency,
                              decoration: InputDecoration.collapsed(
                                hintText: "Enter value for Emergency",
                                hintStyle:  TextStyle(color: Colors.white),
                              ),
                              enabled: isConnected,
                            ),
                          ),
                          SizedBox(
                            height: height*0.01,
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: width*0.025, vertical: height*0.005),
                            child: ElevatedButton(
                              onPressed: isConnected
                                  ? () async{
                                if(X_POS.text=="" || X_NEG.text=="" || Alert.text=="" || Emergency.text=="")
                                  {
                                    showSnackBar(context, "Enter all Details", Colors.red);
                                  }
                                else{
                                  data['X_pos']=X_POS.value.text;
                                  data['X_neg']=X_NEG.value.text;
                                  data['ALERT']=Alert.value.text;
                                  data['EMERGENCY']=Emergency.value.text;
                                  Map<String, dynamic> convertedData= convertDataTypes(data);
                                  Map<String, dynamic> toSend= {"emergency": convertedData['EMERGENCY'],"alert": convertedData['ALERT'],"X_pos": convertedData['X_pos'],"X_neg":convertedData['X_neg']};
                                  String toSendStr="Update_Value"+jsonEncode(toSend);
                                  _sendMessage(toSendStr);
                                  await changeDetect();
                                  i=no_of_messages_received;
                                  Navigator.pop(context);
                                  showSnackBar(context, "SENT Succesfully", Colors.green);
                                }

                              }
                                  : null,
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
  String convertJsonString(String a) {
    String jsonString =a;
    // Remove spaces around colons and convert values to strings
    jsonString = jsonString.replaceAllMapped(
        RegExp(r'(\w+)\s*:\s*([^,}\s]+)'), (match) => '"${match.group(1)}": "${match.group(2)}"');

    //print(jsonString);
    return jsonString;
  }

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
  }

  Future<void> _showQuadDialog() async{
    List<int> b_alr=[0,0,0,0];
    List<int> alr=[0,0,0,0];
    List<int> emr=[0,0,0,0];

    final TextEditingController direction =new TextEditingController();
    final TextEditingController b_alr1 =new TextEditingController();
    final TextEditingController b_alr2 =new TextEditingController();
    final TextEditingController b_alr3 =new TextEditingController();
    final TextEditingController b_alr4 =new TextEditingController();
    final TextEditingController alr1 =new TextEditingController();
    final TextEditingController alr2 =new TextEditingController();
    final TextEditingController alr3 =new TextEditingController();
    final TextEditingController alr4 =new TextEditingController();
    final TextEditingController emr1 =new TextEditingController();
    final TextEditingController emr2 =new TextEditingController();
    final TextEditingController emr3 =new TextEditingController();
    final TextEditingController emr4 =new TextEditingController();
    final imageList = ['assets/QUAD(1).png', 'assets/QUAD(2).png',];
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
                    title: Text("QUAD Configuration"),
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
                            Container(
                              height: height*0.3,
                              child: PhotoViewGallery.builder(

                                itemCount: imageList.length,
                                builder: (context, index) {
                                  return PhotoViewGalleryPageOptions(
                                    imageProvider:AssetImage(imageList[index],),
                                    minScale: PhotoViewComputedScale.contained * 0.8,
                                    maxScale: PhotoViewComputedScale.covered * 2,
                                  );
                                },
                                scrollPhysics: BouncingScrollPhysics(),
                                backgroundDecoration: BoxDecoration(
                                  color: Theme.of(context).canvasColor,
                                ),

                                enableRotation:false,
                                loadingBuilder: (context, event) => Center(
                                  child: Container(
                                    width: 30.0,
                                    height: 30.0,
                                    child: CircularProgressIndicator(
                                      backgroundColor:Colors.orange,
                                      value: (event == null || event.expectedTotalBytes == null)
                                          ? 0
                                          : event.cumulativeBytesLoaded / event.expectedTotalBytes!.toDouble(),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: height*0.02),
                            Padding(
                                padding: EdgeInsets.symmetric(horizontal: width*0.06),
                                child: Text("Direction", style: TextStyle(color:Colors.white,fontSize: height*0.025, fontWeight: FontWeight.w500),)),
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
                                controller: direction,
                                decoration: InputDecoration.collapsed(
                                  hintText: "Enter value for direction",
                                  hintStyle:  TextStyle(color: Colors.white),
                                ),
                                enabled: isConnected,
                              ),
                            ),
                            SizedBox(height: height*0.02,),
                            Padding(
                                padding: EdgeInsets.symmetric(horizontal: width*0.06),
                                child: Text("B_ALR", style: TextStyle(color:Colors.white,fontSize: height*0.025, fontWeight: FontWeight.w500),)),
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
                                controller: b_alr1,
                                decoration: InputDecoration.collapsed(
                                  hintText: "Enter value for q1.b_alr",
                                  hintStyle:  TextStyle(color: Colors.white),
                                ),
                                enabled: isConnected,
                              ),
                            ),
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
                                controller: b_alr2,
                                decoration: InputDecoration.collapsed(
                                  hintText: "Enter value for q2.b_alr",
                                  hintStyle:  TextStyle(color: Colors.white),
                                ),
                                enabled: isConnected,
                              ),
                            ),
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
                                controller: b_alr3,
                                decoration: InputDecoration.collapsed(
                                  hintText: "Enter value for q3.b_alr",
                                  hintStyle:  TextStyle(color: Colors.white),
                                ),
                                enabled: isConnected,
                              ),
                            ),
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
                                controller: b_alr4,
                                decoration: InputDecoration.collapsed(
                                  hintText: "Enter value for q4.b_alr",
                                  hintStyle:  TextStyle(color: Colors.white),
                                ),
                                enabled: isConnected,
                              ),
                            ),
                            SizedBox(height: height*0.02),
                            Padding(
                                padding: EdgeInsets.symmetric(horizontal: width*0.06),
                                child: Text("ALR", style: TextStyle(color:Colors.white,fontSize: height*0.025, fontWeight: FontWeight.w500),)),
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
                                controller: alr1,
                                decoration: InputDecoration.collapsed(
                                  hintText: "Enter value for q1.alr",
                                  hintStyle:  TextStyle(color: Colors.white),
                                ),
                                enabled: isConnected,
                              ),
                            ),
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
                                controller: alr2,
                                decoration: InputDecoration.collapsed(
                                  hintText: "Enter value for q2.alr",
                                  hintStyle:  TextStyle(color: Colors.white),
                                ),
                                enabled: isConnected,
                              ),
                            ),
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
                                controller: alr3,
                                decoration: InputDecoration.collapsed(
                                  hintText: "Enter value for q3.alr",
                                  hintStyle:  TextStyle(color: Colors.white),
                                ),
                                enabled: isConnected,
                              ),
                            ),
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
                                controller: alr4,
                                decoration: InputDecoration.collapsed(
                                  hintText: "Enter value for q4.alr",
                                  hintStyle:  TextStyle(color: Colors.white),
                                ),
                                enabled: isConnected,
                              ),
                            ),
                            SizedBox(height: height*0.02),
                            Padding(
                                padding: EdgeInsets.symmetric(horizontal: width*0.06),
                                child: Text("EMR", style: TextStyle(color:Colors.white,fontSize: height*0.025, fontWeight: FontWeight.w500),)),
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
                                controller: emr1,
                                decoration: InputDecoration.collapsed(
                                  hintText: "Enter value for q1.emr",
                                  hintStyle:  TextStyle(color: Colors.white),
                                ),
                                enabled: isConnected,
                              ),
                            ),
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
                                controller: emr2,
                                decoration: InputDecoration.collapsed(
                                  hintText: "Enter value for q2.emr",
                                  hintStyle:  TextStyle(color: Colors.white),
                                ),
                                enabled: isConnected,
                              ),
                            ),
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
                                controller: emr3,
                                decoration: InputDecoration.collapsed(
                                  hintText: "Enter value for q3.emr",
                                  hintStyle:  TextStyle(color: Colors.white),
                                ),
                                enabled: isConnected,
                              ),
                            ),
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
                                controller: emr4,
                                decoration: InputDecoration.collapsed(
                                  hintText: "Enter value for q4.emr",
                                  hintStyle:  TextStyle(color: Colors.white),
                                ),
                                enabled: isConnected,
                              ),
                            ),
                            SizedBox(
                              height: height*0.03,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: width*0.025, vertical: height*0.005),
                              child: ElevatedButton(
                                onPressed: isConnected
                                    ? () async{
                                  if(b_alr1.text.trim()=="" || b_alr2.text.trim()=="" || b_alr3.text.trim()=="" || b_alr4.text.trim()=="" || alr1.text.trim()=="" || alr2.text.trim()=="" || alr3.text.trim()=="" || alr4.text.trim()=="" || emr1.text.trim()=="" || emr2.text.trim()=="" || emr3.text.trim()=="" || emr4.text.trim()=="" || direction.text.trim()=="")
                                  {
                                    showSnackBar(context, "Enter all Details", Colors.red);
                                  }
                                  else{
                                    Map<String, dynamic> data={"direction": direction.value.text.trim(), "q1.B_alr": b_alr1.value.text.trim(), "q2.B_alr": b_alr1.value.text.trim(), "q3.B_alr": b_alr1.value.text.trim(), "q4.B_alr": b_alr4.value.text.trim(), "q1.emr": emr1.value.text.trim(), "q2.emr": emr2.value.text.trim(), "q3.emr": emr3.value.text.trim(), "q4.emr": emr4.value.text.trim(), "q1.alr": alr1.value.text.trim(), "q2.alr": alr2.value.text.trim(), "q3.alr": alr3.value.text.trim(), "q4.alr": alr4.value.text.trim()};
                                    Map<String, dynamic> convertedData= convertDataTypes(data);
                                    String toSendStr="quad"+jsonEncode(convertedData);
                                    print(toSendStr);
                                    _sendMessage(toSendStr);
                                    await changeDetect();
                                    i=no_of_messages_received;
                                    Navigator.pop(context);
                                    showSnackBar(context, "SENT Succesfully", Colors.green);
                                  }

                                }
                                    : null,
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
                    )

                      ),
                    ),

                  ),


          );
        }
    );
  }



}
