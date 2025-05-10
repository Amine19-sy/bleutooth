import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:bleutooth/services/item_service.dart';
import 'package:bleutooth/widgets/input_field.dart';

class AddItemScreen extends StatefulWidget {
  final int boxId;
  final String userId;
  const AddItemScreen({Key? key, required this.boxId, required this.userId})
    : super(key: key);

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _imageCtrl = TextEditingController();
  bool _isLoading = false;
  String? _error;
  File? _pickedImage;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _imageCtrl.dispose();
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
            'Add an Item!',
            textAlign: TextAlign.start,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w900,
              fontFamily: 'Popins',
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 16),
                CustomTextField(labelText: "Name", controller: _nameCtrl),
                const SizedBox(height: 16),
                CustomTextField(
                  labelText: "Description",
                  controller: _descCtrl,
                  maxLines: 6,
                ),
                const SizedBox(height: 16),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ],
                const SizedBox(height: 24),
                _pickedImage != null
                    ? Container(
                      height: 100,
                      width: 100,
                      child: Image.file(_pickedImage!),
                    )
                    : Container(),
                const Spacer(),
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _pickImageFromCamera,
                    style: ElevatedButton.styleFrom(
                      side: BorderSide(color: Colors.blue, width: 2),
                      // foregroundColor: Colors.blue,
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Add Picture",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child:
                        _isLoading
                            ? const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            )
                            : const Text(
                              "Add Item",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                  ),
                ),
                // ElevatedButton(
                //   onPressed: () {
                //     _pickImageFromCamera();
                //   },
                //   child: Text("Take picture"),
                // ),
                // _isLoading
                //     ? const CircularProgressIndicator()
                //     : ElevatedButton(
                //       onPressed: _submit,
                //       child: const Text("Add Item"),
                //     ),
              ],
            ),
          ),
        ),
        // ),
      ),
    );
  }

  // Future _pickImageFromCamera() async {
  //   final returnedImage = await ImagePicker().pickImage(
  //     source: ImageSource.camera,
  //   );
  //   if (returnedImage == null) return;
  // }

  Future _pickImageFromCamera() async {
    final returnedImage = await ImagePicker().pickImage(
      source: ImageSource.camera,
    );
    if (returnedImage == null) return;

    setState(() => _pickedImage = File(returnedImage.path));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await ItemService().addItem(
        boxId: widget.boxId,
        name: _nameCtrl.text,
        userId: int.parse(widget.userId),
        imageFile: _pickedImage,
      );
      Navigator.pop(context, true);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
