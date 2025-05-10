import 'package:flutter/material.dart';
import 'package:bleutooth/models/box.dart';
import 'package:bleutooth/services/box_service.dart';
import 'package:bleutooth/widgets/input_field.dart';

class SendRequestScreen extends StatefulWidget {
  final Box box;
  final int ownerId;

  const SendRequestScreen({Key? key, required this.box, required this.ownerId})
    : super(key: key);

  @override
  _SendRequestScreenState createState() => _SendRequestScreenState();
}

class _SendRequestScreenState extends State<SendRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  final _service = BoxService();

  Future<void> _sendInvite() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      await _service.requestBoxAccess(
        boxId: widget.box.id,
        inviteeEmail: _emailController.text.trim(),
        ownerId: widget.ownerId,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invitation sent to ${_emailController.text.trim()}'),
        ),
      );
      _emailController.clear();
    } catch (err) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${err.toString()}')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(title: Text('Invite to "${widget.box.name}"'),backgroundColor: Colors.white,),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text('Send an invitation to collaborate on:'),
              const SizedBox(height: 8),
              Text(widget.box.name),
              const SizedBox(height: 24),
              Form(
                key: _formKey,
                child: CustomTextField(
                  labelText: "invitee@example.com",
                  controller: _emailController,
                ),
                // TextFormField(
                //   controller: _emailController,
                //   decoration: const InputDecoration(
                //     labelText: 'User Email',
                //     border: OutlineInputBorder(),
                //     hintText: 'invitee@example.com',
                //   ),
                //   keyboardType: TextInputType.emailAddress,
                //   validator: (val) {
                //     if (val == null || val.isEmpty) return 'Email cannot be empty';
                //     final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                //     if (!emailRegex.hasMatch(val.trim())) return 'Enter a valid email';
                //     return null;
                //   },
                // ),
              ),
              const SizedBox(height: 24),
              const Spacer(),
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _sendInvite,
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
              // SizedBox(
              //   width: double.infinity,
              //   child: ElevatedButton.icon(
              //     icon: _isLoading
              //         ? SizedBox(
              //             width: 16,
              //             height: 16,
              //             child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              //           )
              //         : const Icon(Icons.send),
              //     label: Text(_isLoading ? 'Sending...' : 'Send Invitation'),
              //     onPressed: _isLoading ? null : _sendInvite,
              //     style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
