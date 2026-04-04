import 'package:flutter/material.dart';
import 'detail_card.dart';

class PriceCard extends StatelessWidget {
  final int price;
  const PriceCard({super.key, required this.price});

  @override
  Widget build(BuildContext context) {
    return DetailCard(
      color: const Color.fromARGB(255, 177, 233, 37),
      child: Column(
        children: [
          const Icon(Icons.money, color: Colors.black),
          const SizedBox(height: 6),
          const Text("Price", style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(
            "₹ $price",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
