import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_bluetooth_serial_example/constants/constant_color.dart';
import 'package:flutter_bluetooth_serial_example/deviceOptions.dart';
import 'package:scoped_model/scoped_model.dart';
import './BackgroundCollectedPage.dart';
import './BackgroundCollectingTask.dart';
import './ChatPage.dart';
import './SelectBondedDevicePage.dart';

// import './helpers/LineChart.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPage createState() => new _MainPage();
}

class _MainPage extends State<MainPage> {
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;

  String _address = "...";
  String _name = "...";

  Timer? _discoverableTimeoutTimer;
  int _discoverableTimeoutSecondsLeft = 0;

  BackgroundCollectingTask? _collectingTask;

  bool _autoAcceptPairingRequests = false;

  @override
  void initState() {
    super.initState();

    // Get current state
    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothState = state;
      });
    });

    Future.doWhile(() async {
      // Wait if adapter not enabled
      if ((await FlutterBluetoothSerial.instance.isEnabled) ?? false) {
        return false;
      }
      await Future.delayed(Duration(milliseconds: 0xDD));
      return true;
    }).then((_) {
      // Update the address field
      FlutterBluetoothSerial.instance.address.then((address) {
        setState(() {
          _address = address!;
        });
      });
    });

    FlutterBluetoothSerial.instance.name.then((name) {
      setState(() {
        _name = name!;
      });
    });

    // Listen for futher state changes
    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      setState(() {
        _bluetoothState = state;
        // Discoverable mode is disabled when Bluetooth gets disabled
        _discoverableTimeoutTimer = null;
        _discoverableTimeoutSecondsLeft = 0;
      });
    });
  }

  @override
  void dispose() {
    FlutterBluetoothSerial.instance.setPairingRequestHandler(null);
    _collectingTask?.dispose();
    _discoverableTimeoutTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var width=  MediaQuery.of(context).size.width;
    var height= MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        title: const Text('Flutter Bluetooth Serial'),
      ),
      body: Container(
        child: ListView(
          children: <Widget>[
            Divider(),
            // ListTile(title: const Text('General')),
            Container(
              margin: EdgeInsets.symmetric(horizontal: width*0.035),
              decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: highlight, width: 2)
              ),
              child: SwitchListTile(
                title:  Text('Enable Bluetooth', style: TextStyle(color: Colors.white, fontSize: height*0.022, fontWeight: FontWeight.bold),),
                value: _bluetoothState.isEnabled,
                activeColor: highlight,
                onChanged: (bool value) {
                  // Do the request and update with the true value then
                  future() async {
                    // async lambda seems to not working
                    if (value)
                      await FlutterBluetoothSerial.instance.requestEnable();
                    else
                      await FlutterBluetoothSerial.instance.requestDisable();
                  }

                  future().then((_) {
                    setState(() {});
                  });
                },
              ),
            ),
            Divider(),
            // SwitchListTile(
            //   title: const Text('Automatically Enter Password'),
            //   subtitle: const Text('Pin 1234'),
            //   value: _autoAcceptPairingRequests,
            //   onChanged: (bool value) {
            //     setState(() {
            //       _autoAcceptPairingRequests = value;
            //     });
            //     if (value) {
            //       FlutterBluetoothSerial.instance.setPairingRequestHandler(
            //           (BluetoothPairingRequest request) {
            //         print("Auto-Fill Password");
            //         if (request.pairingVariant == PairingVariant.Pin) {
            //           return Future.value("1234");
            //         }
            //         return Future.value(null);
            //       });
            //     } else {
            //       FlutterBluetoothSerial.instance
            //           .setPairingRequestHandler(null);
            //     }
            //   },
            // ),
            // Divider(),
            //ListTile(title:  Text('Connect and Receive data', style: TextStyle(color: Colors.white, fontSize: height*0.022),)),
            ListTile(
              title: ElevatedButton(
                child: ((_collectingTask?.inProgress ?? false)
                    ?  Text('Disconnect', style: TextStyle(fontSize: height*0.023),)
                    :  Text('Connect to a device', style: TextStyle(fontSize: height*0.022),)),
                style: ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(highlight)
                ),
                onPressed: () async {
                  if (_collectingTask?.inProgress ?? false) {
                    await _collectingTask!.cancel();
                    setState(() {
                      /* Update for `_collectingTask.inProgress` */
                    });
                  } else {
                    final BluetoothDevice? selectedDevice =
                        await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          return SelectBondedDevicePage(checkAvailability: true,);
                        },
                      ),
                    );

                    if (selectedDevice != null) {
                      //await _startBackgroundTask(context, selectedDevice);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => deviceOptions(server: selectedDevice)));
                      //_startChat(context, selectedDevice);
                      setState(() {
                        /* Update for `_collectingTask.inProgress` */
                      });
                    }
                  }
                },
              ),
            ),
            // ListTile(
            //   title: ElevatedButton(
            //     child: const Text('View Collected Data'),
            //     onPressed: (_collectingTask != null)
            //         ? () async {
            //           final valor = await _collectingTask;
            //           print(valor);
            //             // Navigator.of(context).push(
            //             //   MaterialPageRoute(
            //             //     builder: (context) {
            //             //       return ScopedModel<BackgroundCollectingTask>(
            //             //         model: _collectingTask!,
            //             //         child: BackgroundCollectedPage(),
            //             //       );
            //             //     },
            //             //   ),
            //             // );
            //           }
            //         : null,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  void _startChat(BuildContext context, BluetoothDevice server) {
    // Navigator.of(context).push(
    //   MaterialPageRoute(
    //     builder: (context) {
    //       return ChatPage(server: server);
    //     },
    //   ),
    // );
    Navigator.push(context, MaterialPageRoute(builder: (context) => ChatPage(server: server)));
  }

  Future<void> _startBackgroundTask(
    BuildContext context,
    BluetoothDevice server,
  ) async {
    try {
      _collectingTask = await BackgroundCollectingTask.connect(server);
      await _collectingTask!.start();
    } catch (ex) {
      _collectingTask?.cancel();
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error occured while connecting'),
            content: Text("${ex.toString()}"),
            actions: <Widget>[
              new TextButton(
                child: new Text("Close"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }
}
