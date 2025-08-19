import 'dart:async';

import 'package:flutter/material.dart';
import 'package:petzyadmin/core/colors.dart';
import 'package:shimmer/shimmer.dart';

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

class ImageCarousel extends StatefulWidget {
  final List<String> images;
  final double height;

  const ImageCarousel({super.key, required this.images, required this.height});

  @override
  State<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  late final PageController _controller;
  int currentIndex = 0;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    if (widget.images.length > 1) {
      timer = Timer.periodic(const Duration(seconds: 3), (t) {
        final next = (currentIndex + 1) % widget.images.length;
        if (_controller.hasClients) {
          _controller.animateToPage(
            next,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
          setState(() => currentIndex = next);
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: PageView.builder(
        controller: _controller,
        itemCount: widget.images.length,
        itemBuilder: (_, index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              color: Colors.black12, // background in case of empty space
              child: Image.network(
                widget.images[index],
                fit: BoxFit.contain, // 👈 show full image without stretching

                height: widget.height,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(color: Colors.white),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
