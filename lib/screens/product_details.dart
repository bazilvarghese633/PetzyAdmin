import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petzyadmin/core/colors.dart';
import 'package:petzyadmin/screens/edit_product.dart';
import 'package:petzyadmin/bloc/product_detail_cubit.dart';
import 'package:petzyadmin/widgets/cards_widgets.dart';

class ProductDetailPage extends StatelessWidget {
  final Map<String, dynamic> productData;

  const ProductDetailPage({super.key, required this.productData});

  @override
  Widget build(BuildContext context) {
    final productId = productData['id'];

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => ProductDetailCubit()..fetchProduct(productId),
        ),
        BlocProvider(create: (_) => ImageCarouselCubit()),
      ],
      child: Scaffold(
        backgroundColor: whiteColor,
        appBar: AppBar(
          title: Text(productData['name']),
          backgroundColor: primaryColor,
          actions: [
            BlocBuilder<ProductDetailCubit, ProductDetailState>(
              builder: (context, state) {
                if (state.product == null) return const SizedBox();
                final updatedData = state.product!;
                return Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () async {
                        final updated = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => EditProductScreen(
                                  productId: productId,
                                  initialData: updatedData,
                                ),
                          ),
                        );
                        if (updated == true) {
                          context.read<ProductDetailCubit>().fetchProduct(
                            productId,
                          );
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _confirmDelete(context, productId),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<ProductDetailCubit, ProductDetailState>(
          builder: (context, state) {
            if (state.loading) {
              return const Center(
                child: CircularProgressIndicator(color: primaryColor),
              );
            }

            if (state.error != null) {
              return Center(
                child: Text(state.error!, style: TextStyle(color: redColor)),
              );
            }

            final data = state.product!;
            final List<String> images = List<String>.from(data['images'] ?? []);

            return LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 600;
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (images.isNotEmpty)
                      ImageCarousel(images: images, height: isWide ? 300 : 220),
                    const SizedBox(height: 16),

                    // Name
                    DetailCard(
                      color: const Color.fromARGB(255, 233, 183, 84),
                      child: Text(
                        data['name'] ?? 'No Name',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Category
                    InfoRow(
                      label: "Category",
                      value: data['category'] ?? 'Unknown',
                      labelColor: brownColr,
                      valueColor: primaryColor,
                    ),

                    const SizedBox(height: 16),

                    // Price & Quantity
                    isWide
                        ? Row(
                          children: [
                            Expanded(
                              child: PriceCard(price: data['price'] ?? 0),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: QuantityCard(
                                qty: data['quantity'] ?? 0,
                                unit: data['unit'] ?? "",
                              ),
                            ),
                          ],
                        )
                        : Column(
                          children: [
                            PriceCard(price: data['price'] ?? 0),
                            const SizedBox(height: 12),
                            QuantityCard(
                              qty: data['quantity'] ?? 0,
                              unit: data['unit'] ?? "",
                            ),
                          ],
                        ),

                    const SizedBox(height: 16),

                    // Description
                    DetailCard(
                      color: const Color.fromARGB(255, 90, 177, 248),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.description, color: whiteColor),
                              SizedBox(width: 8),
                              Text(
                                "Description",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(data['description'] ?? 'No Description'),
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, String productId) {
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
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () async {
                  await FirebaseFirestore.instance
                      .collection('products')
                      .doc(productId)
                      .delete();
                  Navigator.of(ctx).pop();
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Product deleted')),
                  );
                },
                child: const Text(
                  "Delete",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }
}
