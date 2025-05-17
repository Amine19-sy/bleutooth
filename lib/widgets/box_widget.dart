import 'package:flutter/material.dart';
import 'package:bleutooth/models/box.dart';
import 'package:bleutooth/services/box_control.dart';

class StyledBoxCard extends StatefulWidget {
  final Box box;
  const StyledBoxCard({Key? key, required this.box}) : super(key: key);

  @override
  State<StyledBoxCard> createState() => _StyledBoxCardState();
}

class _StyledBoxCardState extends State<StyledBoxCard> {
  bool isOpen = false;
  double? temperature;
  int? humidity;
  final BoxControlService _control = BoxControlService();

  @override
  void initState() {
    super.initState();
    loadTemperature();
  }

  Future<void> loadTemperature() async {
    final result = await _control.fetchLastTemperature(widget.box.id);
    if (result != null) {
      setState(() {
        temperature = (result['temperature'] as num?)?.toDouble();
        humidity = result['humidity'] as int?;
      });
    }
  }

  Future<void> toggleServo() async {
    final command = isOpen ? 'close_servo' : 'open_servo';
    await _control.sendCommand(command, widget.box.id);
    setState(() {
      isOpen = !isOpen;
    });
  }

  Future<void> locateBox() async {
    await _control.sendCommand('buzzer', widget.box.id);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.asset(
                "assets/img/boxes.png",
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.box.name,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(widget.box.description,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  if (temperature != null && humidity != null)
                    Text("🌡 ${temperature!.toStringAsFixed(1)}°C | 💧 $humidity%",
                        style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Column(
              children: [
                ElevatedButton(
                  onPressed: toggleServo,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isOpen ? Colors.red : Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    isOpen ? 'Close' : 'Open',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: locateBox,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow[800],
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Locate',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
