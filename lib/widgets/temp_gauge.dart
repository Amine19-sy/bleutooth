// import 'package:flutter/material.dart';
// import 'package:syncfusion_flutter_gauges/gauges.dart';

// class TemperatureGauge extends StatelessWidget {
//   final double temperature; // e.g., 35.0

//   const TemperatureGauge({Key? key, required this.temperature}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return SfRadialGauge(
//       axes: <RadialAxis>[
//         RadialAxis(
//           minimum: 0,
//           maximum: 100,
//           ranges: <GaugeRange>[
//             GaugeRange(startValue: 0, endValue: 35, color: Colors.green),
//             GaugeRange(startValue: 35, endValue: 70, color: Colors.orange),
//             GaugeRange(startValue: 70, endValue: 100, color: Colors.red),
//           ],
//           pointers: <GaugePointer>[
//             NeedlePointer(value: temperature),
//           ],
//           annotations: <GaugeAnnotation>[
//             GaugeAnnotation(
//               widget: Text(
//                 '${temperature.toStringAsFixed(1)}°C',
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//               ),
//               angle: 90,
//               positionFactor: 0.5,
//             )
//           ],
//         )
//       ],
//     );
//   }
// }
