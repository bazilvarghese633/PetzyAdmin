import 'package:flutter/material.dart';

class DetailCard extends StatelessWidget {
  final Widget child;
  final Color color;

  const DetailCard({super.key, required this.child, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(child: child),
      ),
    );
  }
}
