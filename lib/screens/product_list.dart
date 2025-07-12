import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petzyadmin/core/colors.dart';
import 'package:petzyadmin/screens/product_details.dart';
import 'package:petzyadmin/bloc/product_search_cubit.dart';
import 'package:shimmer/shimmer.dart';

class ProductListPage extends StatelessWidget {
  ProductListPage({super.key});

  final TextEditingController _searchController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  Future<List<String>> uploadImagesToCloudinary(List<File> files) async {
    const cloudName = 'dravgdklo';
    const uploadPreset = 'petzyprofile';
    final url = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
    );

    List<String> imageUrls = [];

    for (var file in files) {
      final request =
          http.MultipartRequest('POST', url)
            ..fields['upload_preset'] = uploadPreset
            ..files.add(await http.MultipartFile.fromPath('file', file.path));

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final data = json.decode(responseBody);
        imageUrls.add(data['secure_url']);
      }
    }

    return imageUrls;
  }

  void _deleteProduct(BuildContext context, String productId) async {
    await FirebaseFirestore.instance
        .collection('products')
        .doc(productId)
        .delete();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Product deleted')));
  }

  @override
  Widget build(BuildContext context) {
    final productsRef = FirebaseFirestore.instance.collection('products');

    return BlocProvider(
      create: (_) => ProductSearchCubit(),
      child: Scaffold(
        backgroundColor: whiteColor,
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: BlocBuilder<ProductSearchCubit, String>(
                builder: (context, query) {
                  return TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by name or category',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: whiteColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged:
                        (value) => context
                            .read<ProductSearchCubit>()
                            .updateQuery(value),
                  );
                },
              ),
            ),
            Expanded(
              child: BlocBuilder<ProductSearchCubit, String>(
                builder: (context, searchQuery) {
                  return StreamBuilder<QuerySnapshot>(
                    stream:
                        productsRef
                            .orderBy('timestamp', descending: true)
                            .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Error: ${snapshot.error}',
                            style: TextStyle(color: redColor),
                          ),
                        );
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(color: primaryColor),
                        );
                      }

                      final docs = snapshot.data?.docs ?? [];
                      final filteredDocs =
                          docs.where((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            final name = (data['name'] ?? '').toLowerCase();
                            final category =
                                (data['category'] ?? '').toLowerCase();
                            return name.contains(searchQuery) ||
                                category.contains(searchQuery);
                          }).toList();

                      if (filteredDocs.isEmpty) {
                        return Center(
                          child: Text(
                            'No products found.',
                            style: TextStyle(color: greyColor),
                          ),
                        );
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredDocs.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final doc = filteredDocs[index];
                          final data = doc.data() as Map<String, dynamic>;
                          final images = List<String>.from(
                            data['images'] ?? [],
                          );
                          final firstImage = images.isNotEmpty ? images[0] : '';

                          return InkWell(
                            onTap:
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => ProductDetailPage(
                                          productData: {...data, 'id': doc.id},
                                        ),
                                  ),
                                ),
                            child: Card(
                              color: whiteColor,
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: ListTile(
                                leading:
                                    firstImage.isNotEmpty
                                        ? ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: SizedBox(
                                            width: 60,
                                            height: 60,
                                            child: Stack(
                                              children: [
                                                // Shimmer background
                                                Shimmer.fromColors(
                                                  baseColor: Colors.grey[300]!,
                                                  highlightColor:
                                                      Colors.grey[100]!,
                                                  child: Container(
                                                    width: 60,
                                                    height: 60,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                // Network image
                                                Image.network(
                                                  firstImage,
                                                  width: 60,
                                                  height: 60,
                                                  fit: BoxFit.cover,
                                                  loadingBuilder: (
                                                    context,
                                                    child,
                                                    loadingProgress,
                                                  ) {
                                                    if (loadingProgress == null)
                                                      return child;
                                                    return const SizedBox(); // Keep shimmer until fully loaded
                                                  },
                                                  errorBuilder:
                                                      (
                                                        context,
                                                        error,
                                                        stackTrace,
                                                      ) => const Icon(
                                                        Icons.broken_image,
                                                        size: 40,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                        : const Icon(Icons.image),

                                title: Text(
                                  data['name'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: secondaryColor,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Category: ${data['category']}',
                                      style: TextStyle(color: greyColor),
                                    ),
                                    Text(
                                      '₹ ${data['price']} | ${data['quantity']} ${(data['unit'] ?? '').replaceFirst(RegExp(r'^per\s*', caseSensitive: false), '')}',

                                      style: TextStyle(color: primaryColor),
                                    ),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed:
                                      () => _deleteProduct(context, doc.id),
                                ),
                              ),
                            ),
                          );
                        },
                      );
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
