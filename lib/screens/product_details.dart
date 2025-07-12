import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petzyadmin/core/colors.dart';
import 'package:petzyadmin/screens/edit_product.dart';
import 'package:petzyadmin/bloc/product_detail_cubit.dart';
import 'package:shimmer/shimmer.dart';

class ProductDetailPage extends StatelessWidget {
  final Map<String, dynamic> productData;

  const ProductDetailPage({super.key, required this.productData});

  @override
  Widget build(BuildContext context) {
    final productId = productData['id'];
    final screenHeight = MediaQuery.of(context).size.height;

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
                                      Navigator.of(ctx).pop();
                                      Navigator.of(context).pop();
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('Product deleted'),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                        );
                      },
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
            final String name = data['name'] ?? 'No Name';
            final String description = data['description'] ?? 'No Description';
            final String category = data['category'] ?? 'Unknown';
            final int price = data['price'] ?? 0;
            final int quantity = data['quantity'] ?? 0;
            final String rawUnit = data['unit'] ?? '';
            final String unit = rawUnit.replaceFirst(
              RegExp(r'^per\s*', caseSensitive: false),
              '',
            );

            final PageController pageController = PageController();

            if (images.length > 1) {
              Timer.periodic(const Duration(seconds: 3), (timer) {
                final currentIndex = context.read<ImageCarouselCubit>().state;
                final nextIndex = (currentIndex + 1) % images.length;
                if (pageController.hasClients) {
                  pageController.animateToPage(
                    nextIndex,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                  context.read<ImageCarouselCubit>().updatePage(nextIndex);
                }
              });
            }

            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                // ---------- Image Section ----------
                if (images.isNotEmpty)
                  SizedBox(
                    height: screenHeight * 0.4,
                    child: PageView.builder(
                      controller: pageController,
                      itemCount: images.length,
                      onPageChanged:
                          (index) => context
                              .read<ImageCarouselCubit>()
                              .updatePage(index),
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              images[index],
                              fit: BoxFit.cover,
                              width: double.infinity,
                              loadingBuilder: (
                                context,
                                child,
                                loadingProgress,
                              ) {
                                if (loadingProgress == null) return child;
                                return Shimmer.fromColors(
                                  baseColor: Colors.grey[300]!,
                                  highlightColor: Colors.grey[100]!,
                                  child: Container(
                                    height: screenHeight * 0.4,
                                    width: double.infinity,
                                    color: Colors.white,
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                const SizedBox(height: 16),

                // ---------- Name Card ----------
                Card(
                  color: const Color.fromARGB(255, 233, 183, 84),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // ---------- Category Cards ----------
                Row(
                  children: [
                    Expanded(
                      child: Card(
                        color: brownColr,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: Text(
                              "Category",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: whiteColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      "=",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Card(
                        color: primaryColor,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: Text(
                              category,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: whiteColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ---------- Price & Quantity Cards ----------
                Row(
                  children: [
                    Expanded(
                      child: Card(
                        color: const Color.fromARGB(255, 177, 233, 37),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Column(
                            children: [
                              const Icon(Icons.money, color: Colors.black),
                              const SizedBox(height: 6),
                              const Text(
                                "Price",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "₹ $price",
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Card(
                        color: Colors.indigo,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Column(
                            children: [
                              const Icon(Icons.inventory, color: whiteColor),
                              const SizedBox(height: 6),
                              const Text(
                                "Quantity",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: whiteColor,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "$quantity $unit",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: whiteColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ---------- Description Card ----------
                Card(
                  elevation: 2,
                  color: const Color.fromARGB(255, 90, 177, 248),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
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
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          description,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            );
          },
        ),
      ),
    );
  }
}
