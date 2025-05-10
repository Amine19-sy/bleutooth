import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

import 'package:bleutooth/models/item.dart';

class ItemDetails extends StatefulWidget {
  final Item item;
  const ItemDetails({Key? key, required this.item}) : super(key: key);

  @override
  State<ItemDetails> createState() => _ItemDetailsState();
}

class _ItemDetailsState extends State<ItemDetails> {
  BluetoothDevice? connectedDevice;
  BluetoothConnection? connection;

  bool isBluetoothActive = false;
  bool isServoOpen = false;
  bool isBuzzerOn = false;
  bool isLedOn = false;
  bool isTempOn = false;

  String ssid = '';
  String password = '';
  String userId = '';
  String status = '🔌 Not connected';

  double? lastTemp;
  int? lastHumidity;
  int? lastTemperatureId;

  static const String BASE_URL = "https://groupeproject.vercel.app/";
  static const int BOX_ID = 1;

  @override
  void initState() {
    super.initState();
    requestPermissions().then((_) {
      autoDetectDevice();
      fetchLastTemperature();
    });
  }

  Future<void> requestPermissions() async {
    await [
      Permission.bluetooth,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.location,
    ].request();
  }

  Future<void> autoDetectDevice() async {
    try {
      await FlutterBluetoothSerial.instance.requestEnable();
      final devices = await FlutterBluetoothSerial.instance.getBondedDevices();

      for (BluetoothDevice d in devices) {
        if ((d.name?.toLowerCase().contains("raspberry") ?? false) ||
            (d.address == "D8:3A:DD:94:95:09")) {
          setState(() {
            connectedDevice = d;
            status = '🔗 Auto-selected: ${d.name}';
          });
          return;
        }
      }

      setState(() => status = '⚠️ Raspberry Pi not found.');
    } catch (e) {
    }
  }

  Future<void> fetchLastTemperature({bool retryOnSameId = false}) async {
    try {
      final url = Uri.parse("${BASE_URL}api/last_temperature?box_id=$BOX_ID");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final int newId = data["id"];

        if (!retryOnSameId || newId != lastTemperatureId) {
          setState(() {
            lastTemp = (data["temperature"] as num).toDouble();
            lastHumidity = data["humidity"];
            lastTemperatureId = newId;
          });
        } else {
          await Future.delayed(Duration(seconds: 1));
          fetchLastTemperature(retryOnSameId: true);
        }
      }
    } catch (e) {
      print("❌ Error fetching temperature: $e");
    }
  }

  Future<void> sendCommand(String command) async {
    try {
      final url = Uri.parse("${BASE_URL}api/send_command");
      final payload = {"command": command, "box_id": BOX_ID};

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode(payload),
      );

      if (response.statusCode == 201) {
        setState(() => status = "✅ Command '$command' sent");
      } else {
        setState(() => status = "❌ Failed: ${response.statusCode}");
      }
    } catch (e) {
      setState(() => status = "❌ Error: $e");
    }
  }

  Future<void> sendCredentials() async {
    if (connectedDevice == null || ssid.isEmpty || password.isEmpty || userId.isEmpty) {
      setState(() => status = '⚠️ Missing info or no device');
      return;
    }

    setState(() => status = '🔄 Connecting...');

    try {
      connection = await BluetoothConnection.toAddress(connectedDevice!.address);
      setState(() => status = '✅ Connected. Sending...');

      String message = '$ssid,$password,$userId\n';
      connection!.output.add(Uint8List.fromList(message.codeUnits));
      await connection!.output.allSent;

      connection!.input!.listen((data) {
        String response = String.fromCharCodes(data).trim();
        setState(() => status = '📬 Pi: $response');
      }).onDone(() {
        connection?.dispose();
        setState(() => status = '🔌 Disconnected.');
      });
    } catch (e) {
      setState(() => status = '❌ Failed: $e');
    }
  }

  void triggerWithAutoReset({
    required bool currentState,
    required String onCommand,
    required String offCommand,
    required Function(bool) updateState,
    Function? afterOn,
  }) {
    if (currentState) {
      sendCommand(offCommand);
      updateState(false);
    } else {
      sendCommand(onCommand);
      updateState(true);
      if (afterOn != null) afterOn();
      Future.delayed(Duration(seconds: 5), () {
        sendCommand(offCommand);
        if (mounted) updateState(false);
      });
    }
  }

  @override
  void dispose() {
    connection?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(title: Text(widget.item.name)),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              widget.item.imagePath != null && widget.item.imagePath!.isNotEmpty
                  ? Image.network(
                      widget.item.imagePath!,
                      width: double.infinity,
                      height: 250,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: double.infinity,
                      height: 250,
                      color: Colors.grey[200],
                      child: const Icon(Icons.image_not_supported, size: 60, color: Colors.grey),
                    ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(widget.item.name, style: Theme.of(context).textTheme.titleLarge),
                  Text(widget.item.addedAt.toString(), style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 24),

                  // Commands
                  Wrap(
                    spacing: 16,
                    children: [
                      IconButton(
                        icon: Icon(Icons.music_note, size: 36, color: isBuzzerOn ? Colors.blue : Colors.grey),
                        onPressed: () {
                          triggerWithAutoReset(
                            currentState: isBuzzerOn,
                            onCommand: "buzzer",
                            offCommand: "stop_buzzer",
                            updateState: (val) => setState(() => isBuzzerOn = val),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.lightbulb, size: 36, color: isLedOn ? Colors.yellow : Colors.grey),
                        onPressed: () {
                          triggerWithAutoReset(
                            currentState: isLedOn,
                            onCommand: "led",
                            offCommand: "stop_led",
                            updateState: (val) => setState(() => isLedOn = val),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.device_thermostat, size: 36, color: isTempOn ? Colors.red : Colors.grey),
                        onPressed: () {
                          triggerWithAutoReset(
                            currentState: isTempOn,
                            onCommand: "temp",
                            offCommand: "stop_temp",
                            updateState: (val) => setState(() => isTempOn = val),
                            afterOn: () => fetchLastTemperature(retryOnSameId: true),
                          );
                        },
                      ),
                      ElevatedButton(
                        onPressed: () {
                          sendCommand(isServoOpen ? "close_servo" : "open_servo");
                          setState(() => isServoOpen = !isServoOpen);
                        },
                        child: Text(isServoOpen ? "Close Servo" : "Open Servo"),
                      ),
                    ],
                  ),

                  if (lastTemp != null && lastHumidity != null) ...[
                    const SizedBox(height: 12),
                    Text("🌡️ Temp: ${lastTemp!.toStringAsFixed(1)} °C"),
                    Text("💧 Humidity: $lastHumidity %"),
                  ],

                  SwitchListTile(
                    title: const Text("Activate Bluetooth"),
                    value: isBluetoothActive,
                    onChanged: (v) {
                      setState(() => isBluetoothActive = v);
                      sendCommand(v ? "start_bluetooth" : "stop_bluetooth");
                    },
                  ),

                  if (isBluetoothActive) ...[
                    TextField(
                      decoration: const InputDecoration(labelText: 'Wi-Fi SSID'),
                      onChanged: (val) => ssid = val,
                    ),
                    TextField(
                      decoration: const InputDecoration(labelText: 'Wi-Fi Password'),
                      obscureText: true,
                      onChanged: (val) => password = val,
                    ),
                    TextField(
                      decoration: const InputDecoration(labelText: 'User ID'),
                      onChanged: (val) => userId = val,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(onPressed: sendCredentials, child: const Text("Send Wi-Fi Credentials")),
                  ],

                  const SizedBox(height: 12),
                  Text(status, style: const TextStyle(fontSize: 16)),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
