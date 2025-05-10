// import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';
// import 'package:syncfusion_flutter_gauges/gauges.dart';

// class TemperatureScreen extends StatefulWidget {
//   const TemperatureScreen({super.key});

//   @override
//   State<TemperatureScreen> createState() => _TemperatureScreenState();
// }

// class _TemperatureScreenState extends State<TemperatureScreen> {
//   double temperature = 30.0;
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             SizedBox(
//               height: 300,
//               child: SfRadialGauge(
//                 title: const GaugeTitle(
//                   text: 'Temperature',
//                   textStyle: TextStyle(
//                     fontSize: 20.0,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 axes: <RadialAxis>[
//                   RadialAxis(
//                     minimum: 0,
//                     maximum: 50,
//                     ranges: <GaugeRange>[
//                       GaugeRange(
//                         startValue: 0,
//                         endValue: 15,
//                         color: Colors.blue,
//                         startWidth: 10,
//                         endWidth: 10,
//                       ),
//                       GaugeRange(
//                         startValue: 15,
//                         endValue: 30,
//                         color: Colors.green,
//                         startWidth: 10,
//                         endWidth: 10,
//                       ),
//                       GaugeRange(
//                         startValue: 30,
//                         endValue: 50,
//                         color: Colors.red,
//                         startWidth: 10,
//                         endWidth: 10,
//                       ),
//                     ],
//                     pointers: <GaugePointer>[
//                       NeedlePointer(
//                         value: temperature,
//                         enableAnimation: true,
//                         animationDuration: 1000,
//                         needleStartWidth: 1,
//                         needleEndWidth: 5,
//                         needleColor: Colors.black,
//                         knobStyle: const KnobStyle(
//                           knobRadius: 10,
//                           sizeUnit: GaugeSizeUnit.logicalPixel,
//                           color: Colors.black,
//                         ),
//                       ),
//                     ],
//                     annotations: <GaugeAnnotation>[
//                       GaugeAnnotation(
//                         widget: Container(
//                           child: Text(
//                             '${temperature.toStringAsFixed(1)}°C',
//                             style: const TextStyle(
//                               fontSize: 20,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                         angle: 90,
//                         positionFactor: 0.5,
//                       ),
//                     ],
//                     axisLabelStyle: const GaugeTextStyle(
//                       fontSize: 12,
//                     ),
//                     majorTickStyle: const MajorTickStyle(
//                       length: 10,
//                       thickness: 2,
//                     ),
//                     minorTickStyle: const MinorTickStyle(
//                       length: 5,
//                       thickness: 1,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 30),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 ElevatedButton(
//                   onPressed: () {
//                     setState(() {
//                       if (temperature > 0) {
//                         temperature -= 1.0;
//                       }
//                     });
//                   },
//                   child: const Text('Decrease'),
//                 ),
//                 const SizedBox(width: 20),
//                 ElevatedButton(
//                   onPressed: () {
//                     setState(() {
//                       if (temperature < 50) {
//                         temperature += 1.0;
//                       }
//                     });
//                   },
//                   child: const Text('Increase'),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }