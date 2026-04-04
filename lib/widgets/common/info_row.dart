import 'package:flutter/material.dart';
import 'package:petzyadmin/core/colors.dart';
import 'detail_card.dart';

class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color labelColor;
  final Color valueColor;

  const InfoRow({
    super.key,
    required this.label,
    required this.value,
    required this.labelColor,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: DetailCard(
            color: labelColor,
            child: Text(label, style: const TextStyle(color: whiteColor)),
          ),
        ),
        const SizedBox(width: 6),
        const Text(
          "=",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: DetailCard(
            color: valueColor,
            child: Text(value, style: const TextStyle(color: whiteColor)),
          ),
        ),
      ],
    );
  }
}
