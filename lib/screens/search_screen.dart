// lib/screens/search_screen.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:bleutooth/bloc/cubits/items_cubits.dart';
// import 'package:bleutooth/bloc/cubits/search_cubit.dart';
// import 'package:bleutooth/bloc/states/search_states.dart';
// import 'package:bleutooth/screens/item_details.dart';
// import 'package:bleutooth/screens/items.dart';
// import 'package:bleutooth/services/item_service.dart';
// import '../services/search_service.dart';
// import '../models/item.dart';

// class SearchScreen extends StatefulWidget {
//   final String userId;
//   const SearchScreen({Key? key, required this.userId}) : super(key: key);

//   @override
//   _SearchScreenState createState() => _SearchScreenState();
// }

// class _SearchScreenState extends State<SearchScreen> {
//   late final SearchCubit _cubit;
//   final TextEditingController _controller = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _cubit = SearchCubit(SearchService());
//     _cubit.loadBoxes(widget.userId);
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     _cubit.close();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider<SearchCubit>.value(
//       value: _cubit,
//       child: SafeArea(
//         child: Scaffold(
//           backgroundColor: Colors.white,
//           appBar: AppBar(
//             backgroundColor: Colors.white,
//             title: TextField(
//               controller: _controller,
//               decoration: const InputDecoration(
//                 hintText: 'Type to search...',
//                 suffixIcon: Icon(Icons.search),
//               ),
//               onChanged: (query) => _cubit.search(query),
//             ),
//           ),
//           body: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               SizedBox(height: 16),
//               Container(
//                 margin: EdgeInsets.only(left: 8),
//                 child: Text(
//                   'Search',
//                   textAlign: TextAlign.left,
//                   style: TextStyle(
//                     fontSize: 30,
//                     fontWeight: FontWeight.w900,
//                     fontFamily: 'Popins',
//                   ),
//                 ),
//               ),
//               SizedBox(height: 16),
//               BlocBuilder<SearchCubit, SearchState>(
//                 builder: (context, state) {
//                   if (state is SearchLoading) {
//                     return SizedBox(
//                       height: 180,
//                       child: Center(child: CircularProgressIndicator()),
//                     );
//                   } else if (state is SearchError) {
//                     return Center(child: Text(state.message));
//                   } else if (state is SearchLoaded) {
//                     final results =
//                         state.filteredBoxes.expand((box) {
//                           final boxName = box['box_name']?.toString() ?? 'Unknown Box';
//                           return (box['items'] as List).map(
//                             (j) => {
//                               'item': Item.fromJson(j),
//                               'boxName': boxName,
//                             },
//                           );
//                         }).toList();
//                     if (results.isEmpty) {
//                       return SizedBox(
//                         height: 180,
//                         child: Center(child: Text("Item Not Found")),
//                       );
//                     }

//                     return SizedBox(
//                       height: 180,
//                       child: ListView.separated(
//                         scrollDirection: Axis.horizontal,
//                         padding: const EdgeInsets.symmetric(horizontal: 12),
//                         itemCount: results.length,
//                         separatorBuilder: (_, __) => const SizedBox(width: 12),
//                         itemBuilder: (ctx, index) {
//                           final entry = results[index];
//                           final it = entry['item'] as Item;
//                           final boxName = entry['boxName'] as String;
//                           return Column(
//                             children: [
//                               // if (it.imagePath != null)
//                               GestureDetector(
//                                 child: Container(
//                                   width: 100,
//                                   height: 100,
//                                   padding: const EdgeInsets.all(8),
//                                   decoration: BoxDecoration(
//                                     color: Colors.grey[200],
//                                     borderRadius: BorderRadius.circular(16),
//                                     boxShadow: [
//                                       BoxShadow(
//                                         color: Colors.black.withOpacity(0.05),
//                                         blurRadius: 5,
//                                         offset: const Offset(2, 2),
//                                       ),
//                                     ],
//                                   ),
//                                   child: ClipRRect(
//                                     borderRadius: BorderRadius.circular(12),
//                                     child:
//                                       it.decodedImage != null
//                                           ? Image.memory(
//                                               it.decodedImage!,
//                                               fit: BoxFit.contain,
//                                             )
//                                           : const Icon(
//                                               Icons.image_not_supported,
//                                               size: 60,
//                                               color: Colors.grey,
//                                             ),

//                                   ),
//                                 ),
//                                 onTap: () {
//                                   Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                       builder: (_) => ItemDetails(item: it),
//                                     ),
//                                   );
//                                 },
//                               ),

//                               SizedBox(height: 4),
//                               SizedBox(
//                                 // width: 100,
//                                 child: Text(
//                                   boxName,
//                                   textAlign: TextAlign.center,
//                                   overflow: TextOverflow.ellipsis,
//                                   maxLines: 2,
//                                 ),
//                               ),
//                             ],
//                           );
//                         },
//                       ),
//                     );
//                   }
//                   return const SizedBox.shrink();
//                 },
//               ),

//               // const Divider(thickness: 1),
//               Container(
//                 margin: EdgeInsets.only(left: 8),
//                 child: Text(
//                   'All Items',
//                   textAlign: TextAlign.left,
//                   style: TextStyle(
//                     fontSize: 30,
//                     fontWeight: FontWeight.w900,
//                     fontFamily: 'Popins',
//                   ),
//                 ),
//               ),
//               // All Items Section
//               Expanded(
//                 child: BlocBuilder<SearchCubit, SearchState>(
//                   builder: (context, state) {
//                     if (state is SearchLoaded) {
//                       final all = state.allBoxes;
//                       return ListView.builder(
//                         padding: const EdgeInsets.all(12),
//                         itemCount: all.length,
//                         itemBuilder: (ctx, i) {
//                           final box = all[i];
//                           final items =
//                               (box['items'] as List)
//                                   .map((j) => Item.fromJson(j))
//                                   .toList();
//                           return Container(
//                             // padding: const EdgeInsets.only(bottom: 16),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Row(
//                                   mainAxisAlignment:
//                                       MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Text(
//                                       box['box_name'] ?? 'Unknown Box',
//                                       style: const TextStyle(
//                                         fontSize: 18,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                     GestureDetector(
//                                       onTap: () {
//                                         Navigator.push(
//                                           context,
//                                           MaterialPageRoute(
//                                             builder:
//                                                 (routeCtx) => BlocProvider(
//                                                   create:
//                                                       (_) => ItemsCubit(
//                                                         ItemService(),
//                                                       )..getItems(
//                                                         box['box_id'] ?? -1,
//                                                       ),
//                                                   child: Items(
//                                                     boxId: box['box_id'] ?? -1,
//                                                     userId: int.parse(
//                                                       widget.userId,
//                                                     ),
//                                                   ),
//                                                 ),
//                                           ),
//                                         );
//                                       },
//                                       child: Text(
//                                         "See All",
//                                         style: const TextStyle(
//                                           color: Colors.blue,
//                                           fontSize: 16,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 const SizedBox(height: 6),
//                                 SizedBox(
//                                   height: 100,
//                                   child: ListView.builder(
//                                     scrollDirection: Axis.horizontal,
//                                     itemCount: items.length,
//                                     itemBuilder: (c, j) {
//                                       final it = items[j];
//                                       return Padding(
//                                         padding: const EdgeInsets.only(
//                                           right: 8,
//                                         ),
//                                         child: Column(
//                                           children: [
//                                             if (it.decodedImage != null)
//                                               Image.memory(
//                                                 it.decodedImage!,
//                                                 width: 60,
//                                                 height: 60,
//                                                 fit: BoxFit.cover,
//                                               ),
//                                             const SizedBox(height: 4),
//                                             SizedBox(
//                                               width: 60,
//                                               child: Text(
//                                                 it.name,
//                                                 overflow: TextOverflow.ellipsis,
//                                                 textAlign: TextAlign.center,
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       );
//                                     },
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           );
//                         },
//                       );
//                     }
//                     return const SizedBox.shrink();
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

//+++++++++===========================

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:smart_box/bloc/cubits/items_cubits.dart';
// import 'package:smart_box/bloc/cubits/search_cubit.dart';
// import 'package:smart_box/bloc/states/search_states.dart';
// import 'package:smart_box/screens/item_details.dart';
// import 'package:smart_box/screens/see_all.dart';
// import 'package:smart_box/services/item_service.dart';
// import 'package:smart_box/widgets/input_field.dart';
// import '../services/search_service.dart';
// import '../models/item.dart';
import 'package:bleutooth/bloc/cubits/items_cubits.dart';
import 'package:bleutooth/bloc/states/search_states.dart';
import 'package:bleutooth/models/item.dart';
import 'package:bleutooth/screens/item_details.dart';
import 'package:bleutooth/screens/see_all.dart';
import 'package:bleutooth/services/item_service.dart';
import 'package:bleutooth/widgets/input_field.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:bleutooth/bloc/cubits/search_cubit.dart';
import 'package:bleutooth/services/search_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SearchScreen extends StatefulWidget {
  final String userId;
  const SearchScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final SearchCubit _cubit;
  final TextEditingController _controller = TextEditingController();

  final TextEditingController _filter1 = TextEditingController();
  final TextEditingController _filter2 = TextEditingController();

  List<Map<String, dynamic>> _collaborators = [];
  String? _selectedUserId;
  DateTime? _fromDate;
  DateTime? _toDate;

  @override
  void initState() {
    super.initState();
    _cubit = SearchCubit(SearchService());
    _cubit.loadBoxes(widget.userId);
    SearchService()
        .users_suggestions(widget.userId)
        .then((list) => setState(() => _collaborators = list))
        .catchError((e) => print(e));
  }

  @override
  void dispose() {
    _controller.dispose();
    _filter1.dispose();
    _filter2.dispose();
    _cubit.close();
    super.dispose();
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (_) => DraggableScrollableSheet(
            expand: false,
            minChildSize: 0.3,
            initialChildSize: 0.6,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  children: [
                    // handle bar
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        controller: scrollController,
                        child: Column(
                          children: [
                            Text(
                              "Filters",
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'Popins',
                              ),
                            ),
                            SizedBox(height: 24),
                            DropdownButtonFormField<String>(
                              isExpanded: true,
                              decoration: InputDecoration(
                                labelText: 'Added by',
                              ),
                              value: _selectedUserId,
                              items: [
                                const DropdownMenuItem(
                                  value: null,
                                  child: Text('Anyone'),
                                ),
                                ..._collaborators.map(
                                  (u) => DropdownMenuItem(
                                    value: u['id'].toString(),
                                    child: Text(u['name']),
                                  ),
                                ),
                              ],
                              onChanged:
                                  (v) => setState(() => _selectedUserId = v),
                            ),
                            const SizedBox(height: 16),

                            // ----- DATE PICKERS -----
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text('From'),
                              subtitle: Text(
                                _fromDate == null
                                    ? 'Any date'
                                    : DateFormat.yMd().format(_fromDate!),
                              ),
                              trailing: Icon(Icons.calendar_today),
                              onTap: () async {
                                final d = await showDatePicker(
                                  context: context,
                                  initialDate: _fromDate ?? DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime.now(),
                                );
                                if (d != null) setState(() => _fromDate = d);
                              },
                            ),
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text('To'),
                              subtitle: Text(
                                _toDate == null
                                    ? DateFormat.yMd().format(DateTime.now())
                                    : DateFormat.yMd().format(_toDate!),
                              ),
                              trailing: Icon(Icons.calendar_today),
                              onTap: () async {
                                final d = await showDatePicker(
                                  context: context,
                                  initialDate: _toDate ?? DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime.now(),
                                );
                                if (d != null) setState(() => _toDate = d);
                              },
                            ),
                            // CustomTextField(
                            //   controller: _filter1,
                            //   labelText: "Added by",
                            // ),
                            // const SizedBox(height: 16),
                            // CustomTextField(
                            //   controller: _filter2,
                            //   labelText: "Date",
                            // ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _selectedUserId = null;
                                    _fromDate = null;
                                    _toDate = null;
                                  });
                                  Navigator.of(context).pop();
                                  _cubit.loadBoxes(widget.userId);
                                },
                                style: ElevatedButton.styleFrom(
                                  side: BorderSide(
                                    color: Colors.blue,
                                    width: 2,
                                  ),
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  "Clean filters",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  _cubit.applyFilters(
                                    userId: widget.userId,
                                    addedBy: _selectedUserId,
                                    dateFilter:
                                        _fromDate != null
                                            ? _fromDate!.toIso8601String()
                                            : null,
                                    toFilter:
                                        _toDate != null
                                            ? _toDate!.toIso8601String()
                                            : null,
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  "Apply Filters",
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
                  ],
                ),
              );
            },
          ),
    );
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
            title:
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            Text(
              "Search",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w900,
                fontFamily: 'Popins',
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.filter, color: Colors.black87),
                onPressed: _showFilterSheet,
              ),
            ],
            // Icon(Icons.filter),
            //   ],
            // ),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 8),
                child: CustomTextField(
                  labelText: "Search for an item",
                  controller: _controller,
                  onChanged: (query) => _cubit.search(query),
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
                          final boxName = box['box_name'] as String;
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
                          return ItemCard(
                            item: it,
                            boxName: boxName, // shows the box name underneath
                            onTap:
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ItemDetails(item: it),
                                  ),
                                ),
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
              // All Items Section +rest of the code
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
                                      box['box_name'],
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
                                                        box['box_id'],
                                                      ),
                                                  child: SeeAllItems(
                                                    boxId: box['box_id'],
                                                    userId: int.parse(
                                                      widget.userId,
                                                    ),
                                                  ),
                                                ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: const Color.fromARGB(
                                              94,
                                              158,
                                              158,
                                              158,
                                            ),
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Text(
                                          "See All",
                                          style: const TextStyle(
                                            color: Colors.blue,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  height: 100,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: items.length,
                                    itemBuilder: (c, j) {
                                      final it = items[j];
                                      return Container(
                                        margin: EdgeInsets.symmetric(
                                          horizontal: 8,
                                        ),
                                        child: ItemCard(
                                          item: it,
                                          onTap:
                                              () => Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (_) =>
                                                          ItemDetails(item: it),
                                                ),
                                              ),
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

class ItemCard extends StatelessWidget {
  final Item item;
  final String? boxName;
  final VoidCallback? onTap;
  const ItemCard({Key? key, required this.item, this.boxName, this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: Offset(2, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // ClipRRect(
                  //             borderRadius: BorderRadius.circular(12),
                  //             child:
                  //                 item.decodedImage != null
                  //                 ? Image.memory(
                  //                     item.decodedImage!,
                  //                     width: 60,
                  //                     height: 60,
                  //                     fit: BoxFit.cover,
                  //                   )
                  //                 : Icon(Icons.image_not_supported, size: 60, color: Colors.grey),
                  //           ),
                 
                  item.decodedImage != null
                  ? Image.memory(
                                      item.decodedImage!,
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                    )
                                  : Icon(Icons.image_not_supported, size: 60, color: Colors.grey),
                      // ? Image.network(item.imagePath!, fit: BoxFit.cover)
                      // : Container(
                      //   color: Colors.grey[200],
                      //   child: Icon(
                      //     Icons.image_not_supported,
                      //     size: 40,
                      //     color: Colors.grey,
                      //   ),
                      // ),

                  // 2) Gradient overlay at bottom
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            // Colors.black.withOpacity(0.6),
                            Colors.blue,
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                  // 3) Item name text
                  Positioned(
                    left: 4,
                    right: 4,
                    bottom: 4,
                    child: Text(
                      item.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        shadows: [Shadow(color: Colors.black45, blurRadius: 4)],
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // 4) Optional box name underneath
        if (boxName != null) ...[
          SizedBox(height: 4),
          SizedBox(
            width: 100,
            child: Text(
              boxName!,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ],
    );
  }
}
