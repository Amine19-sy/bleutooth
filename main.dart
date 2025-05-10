import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(SmartBoxApp());

class SmartBoxApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartBox Controller',
      home: HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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

  static const String BASE_URL = "https://smartbox-five.vercel.app/";
  static const int BOX_ID = 1;

  @override
  void initState() {
    super.initState();
    requestPermissions().then((_) {
      autoDetectDevice();
      fetchLastTemperature(); // Initial load
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
      setState(() => status = '❌ Error: $e');
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
      } else {
        print("❌ Failed to fetch temperature: ${response.statusCode}");
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
        setState(() => status = "✅ Command '$command' sent successfully");
      } else {
        setState(() => status = "❌ Failed: ${response.statusCode} ${response.body}");
      }
    } catch (e) {
      setState(() => status = "❌ Error sending command: $e");
    }
  }

  Future<void> sendCredentials() async {
    if (connectedDevice == null || ssid.isEmpty || password.isEmpty || userId.isEmpty) {
      setState(() => status = '⚠️ Missing info or no device');
      return;
    }

    setState(() => status = '🔄 Connecting to ${connectedDevice!.name}...');

    try {
      connection = await BluetoothConnection.toAddress(connectedDevice!.address);
      setState(() => status = '✅ Connected. Sending Wi-Fi info...');

      String message = '$ssid,$password,$userId\n';
      connection!.output.add(Uint8List.fromList(message.codeUnits));
      await connection!.output.allSent;

      connection!.input!.listen((data) {
        String response = String.fromCharCodes(data).trim();
        setState(() => status = '📬 Pi responded: $response');
      }).onDone(() {
        connection?.dispose();
        setState(() => status = '🔌 Disconnected.');
      });
    } catch (e) {
      setState(() => status = '❌ Failed to send: $e');
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
    return Scaffold(
      appBar: AppBar(title: Text('SmartBox Controller')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Icons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: Icon(Icons.music_note, size: 40, color: isBuzzerOn ? Colors.blue : Colors.grey),
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
                  icon: Icon(Icons.lightbulb_outline, size: 40, color: isLedOn ? Colors.blue : Colors.grey),
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
                  icon: Icon(Icons.device_thermostat, size: 40, color: isTempOn ? Colors.blue : Colors.grey),
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
              ],
            ),

            if (lastTemp != null && lastHumidity != null) ...[
              SizedBox(height: 16),
              Text("🌡️ Température : ${lastTemp!.toStringAsFixed(2)} °C", style: TextStyle(fontSize: 16)),
              Text("💧 Humidité : ${lastHumidity!} %", style: TextStyle(fontSize: 16)),
            ],

            Divider(height: 30),

            // Servo
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Servo Motor', style: TextStyle(fontSize: 18)),
                ElevatedButton(
                  onPressed: () {
                    if (isServoOpen) {
                      sendCommand("close_servo");
                    } else {
                      sendCommand("open_servo");
                    }
                    setState(() => isServoOpen = !isServoOpen);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isServoOpen ? Colors.red : Colors.green,
                  ),
                  child: Text(isServoOpen ? 'Close' : 'Open'),
                ),
              ],
            ),

            Divider(height: 30),

            // Bluetooth
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Bluetooth Receiver', style: TextStyle(fontSize: 18)),
                Switch(
                  value: isBluetoothActive,
                  onChanged: (bool value) {
                    setState(() => isBluetoothActive = value);
                    if (value) {
                      sendCommand("start_bluetooth");
                    } else {
                      sendCommand("stop_bluetooth");
                    }
                  },
                ),
              ],
            ),

            if (isBluetoothActive) ...[
              TextField(
                decoration: InputDecoration(labelText: 'Wi-Fi SSID'),
                onChanged: (val) => ssid = val,
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Wi-Fi Password'),
                obscureText: true,
                onChanged: (val) => password = val,
              ),
              TextField(
                decoration: InputDecoration(labelText: 'User ID'),
                onChanged: (val) => userId = val,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: sendCredentials,
                child: Text('Send Wi-Fi Credentials'),
              ),
            ],

            SizedBox(height: 20),
            Text(status, style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
