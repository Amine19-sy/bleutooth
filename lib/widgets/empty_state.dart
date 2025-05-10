import 'package:flutter/material.dart';


class EmptyState extends StatelessWidget {
  final String image;
  final String message;
  final Color? color;

  const EmptyState({
    Key? key,
    required this.image,
    required this.message,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(image, height: 60, width: 60),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: color ?? Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
