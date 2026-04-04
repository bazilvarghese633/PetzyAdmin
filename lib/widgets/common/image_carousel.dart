import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

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
          if (mounted) setState(() => currentIndex = next);
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
              color: Colors.black12,
              child: Image.network(
                widget.images[index],
                fit: BoxFit.contain,
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
