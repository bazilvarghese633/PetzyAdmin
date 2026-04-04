import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:petzyadmin/core/colors.dart';
import 'package:petzyadmin/screens/product_details/product_details_screen.dart';
import 'package:shimmer/shimmer.dart';

class ProductListItem extends StatelessWidget {
  final QueryDocumentSnapshot doc;
  final Function(BuildContext, String) onDelete;

  const ProductListItem({
    super.key,
    required this.doc,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final data = doc.data() as Map<String, dynamic>;
    final images = List<String>.from(data['images'] ?? []);
    final firstImage = images.isNotEmpty ? images[0] : '';

    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              ProductDetailPage(productData: {...data, 'id': doc.id}),
        ),
      ),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // 🖼 Image with shimmer effect
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 70,
                  height: 70,
                  color: Colors.grey.shade50,
                  child: firstImage.isNotEmpty
                      ? Stack(
                          children: [
                            Shimmer.fromColors(
                              baseColor: Colors.grey[200]!,
                              highlightColor: Colors.grey[50]!,
                              child: Container(
                                width: 70,
                                height: 70,
                                color: Colors.white,
                              ),
                            ),
                            Image.network(
                              firstImage,
                              width: 70,
                              height: 70,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.broken_image_outlined,
                                size: 30,
                                color: greyColor,
                              ),
                            ),
                          ],
                        )
                      : const Icon(Icons.image_outlined,
                          size: 30, color: greyColor),
                ),
              ),
              const SizedBox(width: 12),

              // 📑 Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      data['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: secondaryColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${data['category']}',
                      style: const TextStyle(color: grey600, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₹${data['price']} | ${data['quantity']} ${(data['unit'] ?? '').replaceFirst(RegExp(r'^per\s*', caseSensitive: false), '')}',
                      style: const TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              // Actions
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        color: redColor, size: 20),
                    onPressed: () => onDelete(context, doc.id),
                    tooltip: 'Delete',
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(4),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
