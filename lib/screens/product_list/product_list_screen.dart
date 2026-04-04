import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petzyadmin/core/colors.dart';
import 'package:petzyadmin/bloc/product_search_cubit.dart';
import 'package:petzyadmin/widgets/common/shimmer_widget.dart';
import 'widgets/product_list_item.dart';
import 'widgets/product_search_bar.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _deleteProduct(BuildContext context, String productId) {
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
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Product deleted')));
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

  @override
  Widget build(BuildContext context) {
    final productsRef = FirebaseFirestore.instance.collection('products');
    final isMobile = MediaQuery.of(context).size.width < 600;
    final isTablet = MediaQuery.of(context).size.width >= 600 &&
        MediaQuery.of(context).size.width < 1024;

    return BlocProvider(
      create: (_) => ProductSearchCubit(),
      child: Scaffold(
        backgroundColor: whiteColor,
        body: Column(
          children: [
            ProductSearchBar(controller: _searchController),
            Expanded(
              child: BlocBuilder<ProductSearchCubit, String>(
                builder: (context, searchQuery) {
                  return StreamBuilder<QuerySnapshot>(
                    stream: productsRef
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Error: ${snapshot.error}',
                            style: const TextStyle(color: redColor),
                          ),
                        );
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const ShimmerPlaceholder();
                      }

                      final docs = snapshot.data?.docs ?? [];
                      final filteredDocs = docs.where((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final name = (data['name'] ?? '').toLowerCase();
                        final category = (data['category'] ?? '').toLowerCase();
                        return name.contains(searchQuery.toLowerCase()) ||
                            category.contains(searchQuery.toLowerCase());
                      }).toList();

                      if (filteredDocs.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.inventory_2_outlined,
                                  size: 64,
                                  color: greyColor.withOpacity(0.5)),
                              const SizedBox(height: 16),
                              const Text(
                                'No products found.',
                                style: TextStyle(
                                    color: grey600,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        );
                      }

                      if (isMobile) {
                        return ListView.separated(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          itemCount: filteredDocs.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) => ProductListItem(
                            doc: filteredDocs[index],
                            onDelete: _deleteProduct,
                          ),
                        );
                      } else {
                        return GridView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredDocs.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: isTablet ? 2 : 3,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 2.8,
                          ),
                          itemBuilder: (context, index) => ProductListItem(
                            doc: filteredDocs[index],
                            onDelete: _deleteProduct,
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
