import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bleutooth/bloc/cubits/req_rec.dart';
import 'package:bleutooth/bloc/states/req_rec.dart';
import 'package:bleutooth/services/box_service.dart';


class RequestsReceivedScreen extends StatelessWidget {
  final int userId;
  const RequestsReceivedScreen({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RequestsReceivedCubit(BoxService())..fetch(userId),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(title: const Text('Invitations Received'),backgroundColor: Colors.white,),
        body: BlocBuilder<RequestsReceivedCubit, RequestsReceivedState>(
          builder: (c, s) {
            if (s is RequestsReceivedLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (s is RequestsReceivedError) {
              return Center(child: Text('Error: ${s.message}'));
            } else if (s is RequestsReceivedLoaded) {
              if (s.requests.isEmpty) {
                return const Center(child: Text('No Request.'));
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
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${req.id} invited you to manage "${req.boxId}"',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.green),
                          onPressed: () => c
                              .read<RequestsReceivedCubit>()
                              .respond(req.id, true, userId),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () => c
                              .read<RequestsReceivedCubit>()
                              .respond(req.id, false, userId),
                        ),
                      ],
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
