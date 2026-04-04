import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petzyadmin/core/colors.dart';
import 'package:petzyadmin/screens/edit_product/edit_product_screen.dart';
import 'package:petzyadmin/bloc/product_detail_cubit.dart';
import 'widgets/product_image_carousel.dart';
import 'widgets/product_primary_info.dart';
import 'widgets/product_description.dart';

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
                            builder: (_) => EditProductScreen(
                              productId: productId,
                              initialData: updatedData,
                            ),
                          ),
                        );
                        if (updated == true) {
                          context
                              .read<ProductDetailCubit>()
                              .fetchProduct(productId);
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
                child: Text(state.error!,
                    style: const TextStyle(color: redColor)),
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
                    ProductImageCarousel(images: images, isWide: isWide),
                    const SizedBox(height: 20),
                    ProductPrimaryInfo(data: data),
                    const SizedBox(height: 16),
                    ProductDescription(
                      description: data['description'] ?? 'No Description',
                    ),
                    const SizedBox(height: 40),
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
      builder: (ctx) => AlertDialog(
        backgroundColor: whiteColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Delete Product",
            style:
                TextStyle(color: secondaryColor, fontWeight: FontWeight.bold)),
        content: const Text("Are you sure you want to delete this product?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("No", style: TextStyle(color: greyColor)),
          ),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('products')
                  .doc(productId)
                  .delete();
              if (context.mounted) {
                Navigator.pop(ctx);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Product deleted')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: redColor,
              foregroundColor: whiteColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text("Yes, Delete"),
          ),
        ],
      ),
    );
  }
}
