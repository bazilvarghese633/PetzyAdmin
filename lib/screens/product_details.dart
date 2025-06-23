import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:petzyadmin/core/colors.dart';
import 'package:petzyadmin/screens/edit_product.dart';

class ProductDetailPage extends StatefulWidget {
  final Map<String, dynamic> productData;

  const ProductDetailPage({super.key, required this.productData});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late Map<String, dynamic> productData;

  @override
  void initState() {
    super.initState();
    productData = widget.productData;
  }

  Future<void> _refreshProductData() async {
    final doc =
        await FirebaseFirestore.instance
            .collection('products')
            .doc(productData['id'])
            .get();

    if (doc.exists) {
      setState(() {
        productData = doc.data()!;
        productData['id'] = doc.id; // ✅ Add this line to avoid red screen
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> images = List<String>.from(productData['images'] ?? []);
    final String name = productData['name'] ?? 'No Name';
    final String description = productData['description'] ?? 'No Description';
    final String category = productData['category'] ?? 'Unknown';
    final int price = productData['price'] ?? 0;
    final int quantity = productData['quantity'] ?? 0;
    final String rawUnit = productData['unit'] ?? '';
    final String productId = productData['id'];

    final String unit = rawUnit.replaceFirst(
      RegExp(r'^per\s*', caseSensitive: false),
      '',
    );

    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        title: Text(name),
        backgroundColor: primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final updated = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => EditProductScreen(
                        productId: productId,
                        initialData: productData,
                      ),
                ),
              );

              if (updated == true) {
                await _refreshProductData();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                builder:
                    (ctx) => AlertDialog(
                      title: const Text("Confirm Delete"),
                      content: const Text(
                        "Are you sure you want to delete this product?",
                      ),
                      actions: [
                        TextButton(
                          child: const Text("Cancel"),
                          onPressed: () => Navigator.of(ctx).pop(),
                        ),
                        TextButton(
                          child: const Text(
                            "Delete",
                            style: TextStyle(color: Colors.red),
                          ),
                          onPressed: () async {
                            await FirebaseFirestore.instance
                                .collection('products')
                                .doc(productId)
                                .delete();
                            Navigator.of(ctx).pop(); // Close dialog
                            Navigator.of(context).pop(); // Go back to list
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Product deleted')),
                            );
                          },
                        ),
                      ],
                    ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            if (images.isNotEmpty)
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    return Container(
                      width: 200,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: greyColor.withOpacity(0.3)),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(images[index], fit: BoxFit.cover),
                      ),
                    );
                  },
                ),
              )
            else
              const Center(child: Text("No images available")),

            const SizedBox(height: 20),

            Text(
              name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            Text(
              'Description:',
              style: TextStyle(fontWeight: FontWeight.bold, color: greyColor),
            ),
            Text(description),
            const SizedBox(height: 10),

            Text('Category: $category', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),

            Text(
              'Price: ₹$price',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 10),

            Text(
              'Available Quantity: $quantity $unit',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
