import 'package:flutter/material.dart';
import 'package:petzyadmin/core/colors.dart';
import 'detail_card.dart';

class QuantityCard extends StatelessWidget {
  final int qty;
  final String unit;

  const QuantityCard({super.key, required this.qty, required this.unit});

  @override
  Widget build(BuildContext context) {
    return DetailCard(
      color: Colors.indigo,
      child: Column(
        children: [
          const Icon(Icons.inventory, color: whiteColor),
          const SizedBox(height: 6),
          const Text(
            "Quantity",
            style: TextStyle(fontWeight: FontWeight.w600, color: whiteColor),
          ),
          const SizedBox(height: 6),
          Text(
            "$qty $unit",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: whiteColor,
            ),
          ),
        ],
      ),
    );
  }
}
