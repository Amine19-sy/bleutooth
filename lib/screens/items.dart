import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bleutooth/bloc/cubits/items_cubits.dart';
import 'package:bleutooth/bloc/states/items_states.dart';
import 'package:bleutooth/screens/add_item.dart';
import 'package:bleutooth/screens/item_details.dart';
import 'package:bleutooth/widgets/empty_state.dart';

class Items extends StatefulWidget {
  final int boxId;
  final int userId;
  const Items({super.key, required this.boxId, required this.userId});

  @override
  State<Items> createState() => _ItemsState();
}

class _ItemsState extends State<Items> {

  @override
  void initState() {
    super.initState();

  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: BlocBuilder<ItemsCubit, ItemsState>(
          builder: (context, state) {
            if (state is ItemsLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ItemsError) {
              return EmptyState(
                image: 'assets/img/error.png',
                message: state.message,
                color: Colors.red,
              );
            } else if (state is ItemsLoaded) {
              final items = state.items;
              if (items.isEmpty) {
                return EmptyState(
                  image: 'assets/img/out-of-stock.png',
                  message: 'Looks a bit empty',
                );
              }
              return ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ItemDetails(item: item),
                        ),
                      );
                    },
                    child: Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child:
                                  item.decodedImage != null
                                  ? Image.memory(
                                      item.decodedImage!,
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                    )
                                  : Icon(Icons.image_not_supported, size: 60, color: Colors.grey),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Added: ${item.addedAt.toString().substring(0, 10)}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            // TESTING
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                final shouldDelete = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) {
                                    return Dialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      insetPadding: const EdgeInsets.symmetric(
                                        horizontal: 40,
                                        vertical: 24,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(24),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.warning_rounded,
                                              size: 48,
                                              color: Colors.red,
                                            ),
                                            const SizedBox(height: 16),
                                            const Text(
                                              'Are you sure you want to delete this item?',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(fontSize: 16),
                                            ),
                                            const SizedBox(height: 24),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                // Cancel button
                                                OutlinedButton(
                                                  style: OutlinedButton.styleFrom(
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 24,
                                                          vertical: 12,
                                                        ),
                                                  ),
                                                  child: const Text('Cancel'),
                                                  onPressed:
                                                      () => Navigator.of(
                                                        ctx,
                                                      ).pop(false),
                                                ),
                                                // Delete button
                                                ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.red,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 24,
                                                          vertical: 12,
                                                        ),
                                                  ),
                                                  child: const Text('Delete'),
                                                  onPressed:
                                                      () => Navigator.of(
                                                        ctx,
                                                      ).pop(true),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );

                                if (shouldDelete == true) {
                                  // user confirmed deletion
                                  context.read<ItemsCubit>().removeItem(
                                    itemId: item.id,
                                    userId: widget.userId,
                                    boxId: widget.boxId,
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }
            // initial state
            return const SizedBox.shrink();
          },
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () async {
            final result = await Navigator.push<bool>(
              context,
              MaterialPageRoute(
                builder: (_) => AddItemScreen(boxId: widget.boxId, userId: widget.userId.toString()),
              ),
            );

            if (result == true) {
              context.read<ItemsCubit>().getItems(widget.boxId);
            }
          },
        ),
      ),
    );
  }
}

