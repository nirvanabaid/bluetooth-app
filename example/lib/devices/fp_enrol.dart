import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_bluetooth_serial_example/constants/constant_color.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class fp_enrol extends StatefulWidget {
  final BluetoothDevice server;
   int key_opt;
   int rfi;
  final String dev_token;
   fp_enrol({required this.server, required this.key_opt, required this.rfi, required this.dev_token});

  @override
  _fp_enrol createState() => new _fp_enrol();
}

class _Message {
  int whom;
  String text;

  _Message(this.whom, this.text);
}

class _fp_enrol extends State<fp_enrol> {
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

  final TextEditingController eName =new TextEditingController();

  final TextEditingController eId =new TextEditingController();
  final TextEditingController pass=new TextEditingController();
  TextEditingController devToken = TextEditingController();
  

  @override

  void initState() {
    super.initState();
    connectToDevice();
    reconnect();
    devToken = TextEditingController(text: widget.dev_token);
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

  int? role=1;
  int? rfid=0;
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

    String eRole="";
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
                    value: widget.key_opt,
                    onChanged: (int? newValue) {
                      setState(() {
                        widget.key_opt = newValue!;

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
                height: (widget.key_opt==1)?height*0.02:0,
              ),
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: width*0.06),
                  child: Text((widget.key_opt==1)?"Password":"", style: TextStyle(color:Colors.white,fontSize: height*0.025, fontWeight: FontWeight.w500),)),
              Container(

                padding:(widget.key_opt==1)?EdgeInsets.symmetric(vertical: height*0.015, horizontal: width*0.05):EdgeInsets.symmetric(vertical: height*0, horizontal: width*0),
                decoration: (widget.key_opt==1)?BoxDecoration(
                    color: background,
                    border: Border.all(
                      color: highlight,
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.circular(10)
                ):
                BoxDecoration(),
                margin: (widget.key_opt==1)?EdgeInsets.symmetric(horizontal: width*0.055, vertical: height*0.005):EdgeInsets.symmetric(vertical: height*0, horizontal: width*0),
                child: (widget.key_opt==1)?
                TextField(
                  maxLength: 6,
                  //keyboardType: TextInputType.number,
                  cursorColor: Colors.tealAccent,
                  style:  TextStyle(fontSize: height*0.02, color: Colors.white),
                  controller: pass,

                  decoration: InputDecoration.collapsed(
                    hintText: "Enter 6 digit pass",
                    hintStyle:  TextStyle(color: Colors.white),
                  ),
                  enabled: isConnected,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                ):
                SizedBox(
                  height: 0,
                ),
              ),


              SizedBox(
                height: (widget.key_opt==1)?height*0.02:height*0,
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
                    value: role,
                    onChanged: (int? newValue) {
                      setState(() {
                        role = newValue;
                      });


                    },
                    items: [
                      DropdownMenuItem<int>(
                        value: 0,
                        child: Text(
                          'supervisor',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      DropdownMenuItem<int>(
                        value: 1,
                        child: Text(
                          'operator',
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
                  style: TextStyle(fontSize: height * 0.02, color: Colors.white),
                  controller: eId,
                  decoration: InputDecoration.collapsed(
                    hintText: "Enter value for eID",
                    hintStyle: TextStyle(color: Colors.white),
                  ),
                  enabled: isConnected,
                 // keyboardType: TextInputType.numberWithOptions(decimal: false), // Set the keyboardType to TextInputType.number
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ],
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
                    if (
                        eId.text.trim() != "" &&
                        eName.text.trim() != "" &&
                        devToken.text.trim() != "" &&
                        (widget.key_opt == 0 || pass.text.trim() != "") &&
                        (widget.key_opt == 0 || widget.key_opt ==1) &&
                        (rfid == 0 || rfid == 1)) {
                      eRole=(role==1)?"operator":"supervisor";
                      String res = (rfid==1)?((widget.key_opt==1)?('enrol{"eName": "' + eName.text + '", "eRole": "' + eRole + '", "eID": "' + eId.text + '", "eCode": "' + pass.text + '","rf":"2"}'): ('enrol{"eName": "' + eName.text + '", "eRole": "' + eRole + '", "eID": "' + eId.text + '","rf":"2"}')):((widget.key_opt==1)?('enrol{"eName": "' + eName.text + '", "eRole": "' + eRole + '", "eID": "' + eId.text + '", "eCode": "' + pass.text + '"}'):('enrol{"eName": "' + eName.text + '", "eRole": "' + eRole + '", "eID": "' + eId.text + '"}'));
                      print(res);
                      await _sendMessage(res);
                      String succ_str= await waitForSuccess();
                      int fpid=int.parse(succ_str.substring(7));

                      int result= await sendDataToAPI(devToken.text, eName.text, fpid, int.parse(eId.text), eRole);
                      if(result ==1){
                        await _sendMessage("posted");
                      //  await changeDetect();

                        //Navigator.pop(context,1);
                        showSnackBar(context, "Data Posted to Cloud", Colors.green);
                        setState(() {
                          i=no_of_messages_received;
                        });
                      }
                      else{
                        //Navigator.pop(context);

                        showSnackBar(context, "API call failed", Colors.red);
                      }

                      int end_result= await waitForEnd(eName.text);
                      Navigator.pop(context,end_result);


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

  Future<String> waitForSuccess () async{
    while(!latestReadData.contains('success')){

      await Future.delayed(Duration(milliseconds: 2000));
      print("for success- $latestReadData");
    }
    setState(() {
      i=no_of_messages_received;
    });
    print("succcessDetected");

    return latestReadData.substring(latestReadData.indexOf('success'));
  }

  Future<int> waitForEnd (String eName) async{
    while(!latestReadData.contains('Enrolled employee') && latestReadData!='Deleted'){

      await Future.delayed(Duration(milliseconds: 2000));
      print("Waiting for end- $latestReadData end");


    }


    setState(() {
      i=no_of_messages_received;
    });
    if(latestReadData=='Deleted')
    {
      return 0;
    }
    else{
      return 1;
    }
  }


}
