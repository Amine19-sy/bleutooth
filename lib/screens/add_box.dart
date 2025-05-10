import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:bleutooth/widgets/input_field.dart';
import 'package:bleutooth/services/box_service.dart';

class AddBoxForm extends StatefulWidget {
  final String userId;

  const AddBoxForm({Key? key, required this.userId}) : super(key: key);

  @override
  State<AddBoxForm> createState() => _AddBoxFormState();
}

class _AddBoxFormState extends State<AddBoxForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  // A flag to indicate that the submission is in progress.
  bool _isLoading = false;

  // Create an instance of your BoxService.
  final BoxService _boxService = BoxService();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Handles the form submission
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Call your BoxService to add a box. The service should be implemented to
      // create a new box using provided parameters.
      await _boxService.addBox(
        userId: widget.userId,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
      );

      // Once box has been created, return to the previous screen (pop)
      // You may pass the newBox back to refresh your list.
      Navigator.of(context).pop(true);
    } catch (error) {
      // Show an error message if something goes wrong.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding box: ${error.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
            textAlign: TextAlign.start,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w900,
              fontFamily: 'Popins',
            ),
          ),
        ),
        body:  Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  CustomTextField(
                    labelText: "Name",
                    controller: _nameController,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    labelText: "Description",
                    controller: _descriptionController,
                    maxLines: 6,
                  ),
                  const SizedBox(height: 16),
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
                          recognizer:
                              TapGestureRecognizer()
                                ..onTap = () {
                                  // Implement your QR code logic here.
                                },
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
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
                      child:
                          _isLoading
                              ? const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              )
                              : const Text(
                                "Add",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        // ),
      ),
    );
  }
}
