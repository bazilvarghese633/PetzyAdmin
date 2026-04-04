import 'package:flutter/material.dart';
import 'package:petzyadmin/core/colors.dart';

class ProductPrimaryInfo extends StatelessWidget {
  final Map<String, dynamic> data;

  const ProductPrimaryInfo({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  data['name'] ?? 'No Name',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: secondaryColor,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  (data['category'] ?? 'Unknown').toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildInfoIconTile(
                icon: Icons.payments_outlined,
                label: "Price",
                value: "₹${data['price'] ?? 0}",
              ),
              const SizedBox(width: 24),
              _buildInfoIconTile(
                icon: Icons.inventory_2_outlined,
                label: "Stock",
                value: "${data['quantity'] ?? 0} ${data['unit'] ?? ""}",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoIconTile(
      {required IconData icon, required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: grey600),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(color: grey600, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: secondaryColor,
          ),
        ),
      ],
    );
  }
}
