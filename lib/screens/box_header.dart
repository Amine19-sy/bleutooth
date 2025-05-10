import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

import 'package:bleutooth/models/box.dart';
import 'package:bleutooth/bloc/cubits/collab_cubit.dart';
import 'package:bleutooth/bloc/states/collab_states.dart';

class BoxHeader extends StatefulWidget {
  final Box box;
  const BoxHeader({Key? key, required this.box}) : super(key: key);

  @override
  _BoxHeaderState createState() => _BoxHeaderState();
}

class _BoxHeaderState extends State<BoxHeader> {
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CollaboratorsCubit>().fetchCollaborators(widget.box.id);
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
    return Column(
      children: [
        // Header and Collaborators
        ...[
          Stack(
            children: [
              Container(height: 180, color: Colors.blueAccent),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, size: 60, color: Colors.white),
                    const SizedBox(height: 8),
                    Text(widget.box.name,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(widget.box.description, style: const TextStyle(fontSize: 16, height: 1.5)),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text('Collaborators',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 80,
            child: BlocBuilder<CollaboratorsCubit, CollaboratorsState>(
              builder: (_, state) {
                if (state is CollaboratorsLoading) return const Center(child: CircularProgressIndicator());
                if (state is CollaboratorsError) return Text('Error: ${state.message}');
                if (state is CollaboratorsLoaded) {
                  final users = state.users;
                  if (users.isEmpty) return const Text('No collaborators yet.');
                  return ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: users.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (_, i) => Column(
                      children: [
                        CircleAvatar(radius: 24, child: Text(users[i].username[0].toUpperCase())),
                        const SizedBox(height: 4),
                        Text(users[i].username, style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          const Divider(),
        ],

        // Hardware controls
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(children: [
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
              ElevatedButton(onPressed: sendCredentials, child: const Text("Send Wi-Fi Credentials")),
            ]),
          ),
        ],

        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(status, style: const TextStyle(fontSize: 16)),
        ),
      ],
    );
  }
}
