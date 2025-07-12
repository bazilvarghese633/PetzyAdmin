import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petzyadmin/core/colors.dart';
import 'package:petzyadmin/bloc/edit_product_cubit.dart';

class EditProductScreen extends StatelessWidget {
  final String productId;
  final Map<String, dynamic> initialData;

  EditProductScreen({
    super.key,
    required this.productId,
    required this.initialData,
  });

  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final quantityController = TextEditingController();
  final unitController = TextEditingController();
  final categoryController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  void initializeControllers() {
    nameController.text = initialData['name'];
    descriptionController.text = initialData['description'];
    priceController.text = initialData['price'].toString();
    quantityController.text = initialData['quantity'].toString();
    unitController.text = initialData['unit'];
    categoryController.text = initialData['category'];
  }

  Future<void> _replaceImages(BuildContext context) async {
    try {
      final pickedFiles = await _picker.pickMultiImage();
      if (pickedFiles.isNotEmpty) {
        final files = pickedFiles.map((e) => File(e.path)).toList();
        context.read<EditProductCubit>().replaceImages(files);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error picking images: $e")));
    }
  }

  void _updateProduct(BuildContext context, List<String> imageUrls) async {
    await FirebaseFirestore.instance
        .collection('products')
        .doc(productId)
        .update({
          'name': nameController.text.trim(),
          'description': descriptionController.text.trim(),
          'price': int.tryParse(priceController.text.trim()) ?? 0,
          'quantity': int.tryParse(quantityController.text.trim()) ?? 0,
          'unit': unitController.text.trim(),
          'category': categoryController.text.trim(),
          'images': imageUrls,
        });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Product updated')));

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    initializeControllers();
    final initialImages = List<String>.from(initialData['images'] ?? []);

    return BlocProvider(
      create: (_) => EditProductCubit(initialImages),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Edit Product"),
          backgroundColor: primaryColor,
        ),
        body: BlocBuilder<EditProductCubit, EditProductState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (state.imageUrls.isNotEmpty)
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: state.imageUrls.length,
                        itemBuilder:
                            (context, index) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Image.network(
                                state.imageUrls[index],
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                      ),
                    )
                  else
                    const Text("No images selected"),
                  TextButton.icon(
                    onPressed: () => _replaceImages(context),
                    icon: const Icon(Icons.image),
                    label: const Text("Replace Images"),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: "Name"),
                  ),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: "Description"),
                  ),
                  TextField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Price"),
                  ),
                  TextField(
                    controller: quantityController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Quantity"),
                  ),
                  TextField(
                    controller: unitController,
                    decoration: const InputDecoration(labelText: "Unit"),
                  ),
                  TextField(
                    controller: categoryController,
                    decoration: const InputDecoration(labelText: "Category"),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () => _updateProduct(context, state.imageUrls),
                    icon: const Icon(Icons.save),
                    label: const Text("Save Changes"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
