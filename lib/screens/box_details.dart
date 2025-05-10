import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bleutooth/bloc/cubits/collab_cubit.dart';
import 'package:bleutooth/bloc/cubits/items_cubits.dart';
import 'package:bleutooth/models/box.dart';
import 'package:bleutooth/screens/add_req.dart';
import 'package:bleutooth/screens/box_header.dart';
import 'package:bleutooth/screens/history.dart';
import 'package:bleutooth/screens/items.dart';
import 'package:bleutooth/services/box_service.dart';
import 'package:bleutooth/services/item_service.dart';
import 'package:fl_chart/fl_chart.dart';

class BoxDetails extends StatefulWidget {
  final Box box;
  final Map<String, dynamic> user;
  const BoxDetails({super.key, required this.box, required this.user});

  @override
  State<BoxDetails> createState() => _BoxDetailsState();
}

class _BoxDetailsState extends State<BoxDetails> {
  int _selectedIndex = 0;
  final List<FlSpot> sampleData = [
    FlSpot(0, 1.5),
    FlSpot(1, 1.7),
    FlSpot(2, 1.4),
    FlSpot(3, 1.8),
    FlSpot(4, 1.6),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = <Widget>[
      // BoxHeader(box: widget.box,),
      BlocProvider(
        create:
            (_) =>
                CollaboratorsCubit(BoxService())
                  ..fetchCollaborators(widget.box.id),
        child: BoxHeader(box: widget.box),
      ),
      BlocProvider(
        create: (_) => ItemsCubit(ItemService())..getItems(widget.box.id),
        child: Items(boxId: widget.box.id, userId: widget.user["id"]),
      ),
      HistoryPage(boxId: widget.box.id),
      MyLineChart(dataPoints: sampleData),
    ];
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Details", textAlign: TextAlign.center),
            GestureDetector(
              child: Text(
                "+ Invite",
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder:
                        (_) => SendRequestScreen(
                          box: widget.box,
                          ownerId: widget.user['id'],
                        ),
                  ),
                );
              },
            ),
          ],
        ),
        backgroundColor: Colors.white,
      ),
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            backgroundColor: Colors.white,
            icon: Icon(Icons.home),
            label: 'Info',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Items'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'History'),
          BottomNavigationBarItem(
            icon: Icon(Icons.fireplace),
            label: 'Temperature',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.black,
        onTap: _onItemTapped,
      ),
    );
  }
}

// class BoxHeader extends StatefulWidget {
//   final Box box;

//   const BoxHeader({Key? key, required this.box})
//     : super(key: key);

//   @override
//   State<BoxHeader> createState() => _BoxHeaderState();
// }

// class _BoxHeaderState extends State<BoxHeader> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Column(
//         children: [
//           Stack(
//             children: [
//               Container(
//                 height: 200,
//                 width: double.infinity,
//                 color: Colors.blueAccent,
//               ),
//               Container(
//                 height: 200,
//                 width: double.infinity,
//                 alignment: Alignment.center,
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     const Icon(Icons.star, size: 60, color: Colors.white),
//                     const SizedBox(height: 12),
//                     Text(
//                       widget.box.name,
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 24,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           Expanded(
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: SingleChildScrollView(
//                 child: Text(
//                   widget.box.description,
//                   style: const TextStyle(fontSize: 16, height: 1.5),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

class MyLineChart extends StatelessWidget {
  final List<FlSpot> dataPoints;

  const MyLineChart({Key? key, required this.dataPoints}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          height: 300,
          width: 300,
          child: LineChart(
            LineChartData(
              lineBarsData: [
                // ... your LineChartBarData here
                LineChartBarData(
                  spots: dataPoints,
                  isCurved: true,
                  barWidth: 3,
                  dotData: FlDotData(show: true),
                ),
              ],
              titlesData: FlTitlesData(
                // Wrap your SideTitles in AxisTitles:
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      // value is the x-position
                      return Text(value.toInt().toString());
                    },
                    reservedSize: 32,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      // value is the y-position
                      return Text(value.toString());
                    },
                    reservedSize: 40,
                  ),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              gridData: FlGridData(show: true),
              borderData: FlBorderData(show: true),
              // ... other properties (e.g. lineTouchData)
            ),
          ),
        ),
      ),
    );
  }
}
