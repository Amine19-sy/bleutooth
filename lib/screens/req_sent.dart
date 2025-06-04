// lib/screens/requests_sent_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bleutooth/bloc/cubits/req_sent.dart';
import 'package:bleutooth/bloc/states/req_sent.dart';
import 'package:bleutooth/services/box_service.dart';


class RequestsSentScreen extends StatelessWidget {
  final int ownerId;
  const RequestsSentScreen({Key? key, required this.ownerId}) : super(key: key);

  @override
  Widget build(BuildContext ctx) {
    return BlocProvider(
      create: (_) => RequestsSentCubit(BoxService())..fetch(ownerId),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(title: const Text('Sent Invitations'),backgroundColor: Colors.white,),
        body: BlocBuilder<RequestsSentCubit, RequestsSentState>(
          builder: (c, s) {
            if (s is RequestsSentLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (s is RequestsSentError) {
              return Center(child: Text('Error: ${s.message}'));
            } else if (s is RequestsSentLoaded) {
              if (s.requests.isEmpty) {
                return const Center(child: Text('No invitations sent.'));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: s.requests.length,
                itemBuilder: (_, i) {
                  final req = s.requests[i];
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'You invited "Test" to manage "RaspBerryPi243"',
                      style: const TextStyle(fontSize: 16),
                    ),
                  );
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
