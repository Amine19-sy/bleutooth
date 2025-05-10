// import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';

// class History extends StatefulWidget {
//   const History({super.key});

//   @override
//   State<History> createState() => _HistoryState();
// }

// class _HistoryState extends State<History> {
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//         child: Column(
//       children: [
//         Image.asset("assets/img/out-of-stock.png", height: 60, width: 60),
//         SizedBox(height: 16),
//         Text(
//           "No History",
//           style: TextStyle(color: Colors.grey),
//         )
//       ],
//       mainAxisAlignment: MainAxisAlignment.center,
//       crossAxisAlignment: CrossAxisAlignment.center,
//     ));
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bleutooth/bloc/cubits/history_cubit.dart';
import 'package:bleutooth/bloc/states/history_states.dart';
import 'package:bleutooth/services/history_service.dart';
// import 'package:bleutooth/models/history.dart';

class HistoryPage extends StatefulWidget {
  final int boxId;

  const HistoryPage({Key? key, required this.boxId}) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late HistoryCubit _historyCubit;

  @override
  void initState() {
    super.initState();
    _historyCubit = HistoryCubit(HistoryService());
    _historyCubit.fetchHistory(widget.boxId);
  }

  void _refreshHistory() {
    _historyCubit.fetchHistory(widget.boxId);
  }

  @override
  void dispose() {
    _historyCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _historyCubit,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          body: BlocBuilder<HistoryCubit, HistoryState>(
            builder: (context, state) {
              if (state is HistoryLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is HistoryLoaded) {
                final items = state.histories;
                if (items.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/img/out-of-stock.png",
                          height: 60,
                          width: 60,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "No History",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    _refreshHistory();
                  },
                  child: ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final h = items[index];
                      return ListTile(
                        leading: Icon(
                          h.actionType.toLowerCase() == 'item added'
                              ? Icons.add_circle
                              : Icons.remove_circle,
                          color:
                              h.actionType.toLowerCase() == 'item added'
                                  ? Colors.green
                                  : Colors.red,
                        ),
                        title: Text(
                          h.actionType,
                          style: TextStyle(
                            color:
                                h.actionType.toLowerCase() == 'item added'
                                    ? Colors.green
                                    : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(h.details ?? ''),
                        trailing: Text(
                          h.actionTime.toLocal().toString().split('.')[0],
                          style: const TextStyle(fontSize: 12),
                        ),
                      );
                    },
                  ),
                );
              } else if (state is HistoryError) {
                return Center(child: Text('Error: ${state.message}'));
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}
