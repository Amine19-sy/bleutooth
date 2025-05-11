// lib/screens/search_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bleutooth/bloc/cubits/items_cubits.dart';
import 'package:bleutooth/bloc/cubits/search_cubit.dart';
import 'package:bleutooth/bloc/states/search_states.dart';
import 'package:bleutooth/screens/item_details.dart';
import 'package:bleutooth/screens/items.dart';
import 'package:bleutooth/services/item_service.dart';
import '../services/search_service.dart';
import '../models/item.dart';

class SearchScreen extends StatefulWidget {
  final String userId;
  const SearchScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final SearchCubit _cubit;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cubit = SearchCubit(SearchService());
    _cubit.loadBoxes(widget.userId);
  }

  @override
  void dispose() {
    _controller.dispose();
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SearchCubit>.value(
      value: _cubit,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Type to search...',
                suffixIcon: Icon(Icons.search),
              ),
              onChanged: (query) => _cubit.search(query),
            ),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16),
              Container(
                margin: EdgeInsets.only(left: 8),
                child: Text(
                  'Search',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Popins',
                  ),
                ),
              ),
              SizedBox(height: 16),
              BlocBuilder<SearchCubit, SearchState>(
                builder: (context, state) {
                  if (state is SearchLoading) {
                    return SizedBox(
                      height: 180,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  } else if (state is SearchError) {
                    return Center(child: Text(state.message));
                  } else if (state is SearchLoaded) {
                    final results =
                        state.filteredBoxes.expand((box) {
                          final boxName = box['box_name']?.toString() ?? 'Unknown Box';
                          return (box['items'] as List).map(
                            (j) => {
                              'item': Item.fromJson(j),
                              'boxName': boxName,
                            },
                          );
                        }).toList();
                    if (results.isEmpty) {
                      return SizedBox(
                        height: 180,
                        child: Center(child: Text("Item Not Found")),
                      );
                    }

                    return SizedBox(
                      height: 180,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: results.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (ctx, index) {
                          final entry = results[index];
                          final it = entry['item'] as Item;
                          final boxName = entry['boxName'] as String;
                          return Column(
                            children: [
                              // if (it.imagePath != null)
                              GestureDetector(
                                child: Container(
                                  width: 100,
                                  height: 100,
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 5,
                                        offset: const Offset(2, 2),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child:
                                      it.decodedImage != null
                                          ? Image.memory(
                                              it.decodedImage!,
                                              fit: BoxFit.contain,
                                            )
                                          : const Icon(
                                              Icons.image_not_supported,
                                              size: 60,
                                              color: Colors.grey,
                                            ),

                                  ),
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ItemDetails(item: it),
                                    ),
                                  );
                                },
                              ),

                              SizedBox(height: 4),
                              SizedBox(
                                // width: 100,
                                child: Text(
                                  boxName,
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),

              // const Divider(thickness: 1),
              Container(
                margin: EdgeInsets.only(left: 8),
                child: Text(
                  'All Items',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Popins',
                  ),
                ),
              ),
              // All Items Section
              Expanded(
                child: BlocBuilder<SearchCubit, SearchState>(
                  builder: (context, state) {
                    if (state is SearchLoaded) {
                      final all = state.allBoxes;
                      return ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: all.length,
                        itemBuilder: (ctx, i) {
                          final box = all[i];
                          final items =
                              (box['items'] as List)
                                  .map((j) => Item.fromJson(j))
                                  .toList();
                          return Container(
                            // padding: const EdgeInsets.only(bottom: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      box['box_name'] ?? 'Unknown Box',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (routeCtx) => BlocProvider(
                                                  create:
                                                      (_) => ItemsCubit(
                                                        ItemService(),
                                                      )..getItems(
                                                        box['box_id'] ?? -1,
                                                      ),
                                                  child: Items(
                                                    boxId: box['box_id'] ?? -1,
                                                    userId: int.parse(
                                                      widget.userId,
                                                    ),
                                                  ),
                                                ),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        "See All",
                                        style: const TextStyle(
                                          color: Colors.blue,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                SizedBox(
                                  height: 100,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: items.length,
                                    itemBuilder: (c, j) {
                                      final it = items[j];
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          right: 8,
                                        ),
                                        child: Column(
                                          children: [
                                            if (it.decodedImage != null)
                                              Image.memory(
                                                it.decodedImage!,
                                                width: 60,
                                                height: 60,
                                                fit: BoxFit.cover,
                                              ),
                                            const SizedBox(height: 4),
                                            SizedBox(
                                              width: 60,
                                              child: Text(
                                                it.name,
                                                overflow: TextOverflow.ellipsis,
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
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
            ],
          ),
        ),
      ),
    );
  }
}
