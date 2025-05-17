import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:bleutooth/services/box_service.dart';
import 'package:bleutooth/widgets/input_field.dart';

class AddBoxForm extends StatefulWidget {
  final String userId;

  const AddBoxForm({Key? key, required this.userId}) : super(key: key);

  @override
  State<AddBoxForm> createState() => _AddBoxFormState();
}

class _AddBoxFormState extends State<AddBoxForm> {
  final _formKey = GlobalKey<FormState>();
  final _customNameCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _ssidCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  String? bluetoothName;
  String? bluetoothAddress;
  bool _isLoading = false;

  final BoxService _boxService = BoxService();

  @override
  void initState() {
    super.initState();
    requestPermissions().then((_) => detectBluetoothBox());
  }

  Future<void> requestPermissions() async {
    await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();
  }

  Future<void> detectBluetoothBox() async {
    try {
      await FlutterBluetoothSerial.instance.requestEnable();
      final devices = await FlutterBluetoothSerial.instance.getBondedDevices();
      for (var d in devices) {
        if ((d.name?.toLowerCase().contains("raspberry") ?? false)) {
          setState(() {
            bluetoothName = d.name;
            bluetoothAddress = d.address;
            _customNameCtrl.text = d.name ?? '';
          });
          break;
        }
      }
    } catch (e) {
      print('Bluetooth error: $e');
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() || bluetoothName == null || bluetoothAddress == null) return;

    setState(() => _isLoading = true);

    try {
      await _boxService.claimBox(
        userId: widget.userId,
        userBoxName: _customNameCtrl.text,
        originalName: bluetoothName!,
        description: _descriptionCtrl.text,
      );

      await _boxService.sendWifiCredentialsViaBluetooth(
        bluetoothAddress!,
        _ssidCtrl.text,
        _passwordCtrl.text,
        widget.userId,
      );

      Navigator.of(context).pop(true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _customNameCtrl.dispose();
    _descriptionCtrl.dispose();
    _ssidCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text(
            'Add a box!',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              fontFamily: 'Popins',
            ),
          ),
        ),
        body: bluetoothName == null
            ? const Center(child: Text("🔍 Searching for box..."))
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      CustomTextField(
                        labelText: "Bluetooth Name",
                        controller: TextEditingController(text: bluetoothName),
                        enabled: false,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        labelText: "Custom Name",
                        controller: _customNameCtrl,
                        validator: (v) => v!.isEmpty ? "Required" : null,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        labelText: "Description",
                        controller: _descriptionCtrl,
                        maxLines: 6,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        labelText: "Wi-Fi SSID",
                        controller: _ssidCtrl,
                        validator: (v) => v!.isEmpty ? "Required" : null,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        labelText: "Wi-Fi Password",
                        controller: _passwordCtrl,
                        obscureText: true,
                        validator: (v) => v!.isEmpty ? "Required" : null,
                      ),
                      const SizedBox(height: 24),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(color: Colors.grey, fontSize: 16),
                          children: [
                            const TextSpan(text: "Or Use "),
                            TextSpan(
                              text: "QR Code!",
                              style: const TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  // TODO: implement QR code logic
                                },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                )
                              : const Text(
                                  "Claim & Connect",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
