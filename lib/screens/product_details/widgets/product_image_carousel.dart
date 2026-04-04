import 'package:flutter/material.dart';
import 'package:petzyadmin/widgets/common/image_carousel.dart';

class ProductImageCarousel extends StatelessWidget {
  final List<String> images;
  final bool isWide;

  const ProductImageCarousel({
    super.key,
    required this.images,
    required this.isWide,
  });

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      clipBehavior: Clip.antiAlias,
      child: ImageCarousel(
        images: images,
        height: isWide ? 350 : 250,
      ),
    );
  }
}
