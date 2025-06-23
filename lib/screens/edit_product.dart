import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:petzyadmin/core/colors.dart';

class EditProductScreen extends StatefulWidget {
  final String productId;
  final Map<String, dynamic> initialData;

  const EditProductScreen({
    super.key,
    required this.productId,
    required this.initialData,
  });

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  late TextEditingController nameController;
  late TextEditingController descriptionController;
  late TextEditingController priceController;
  late TextEditingController quantityController;
  late TextEditingController unitController;
  late TextEditingController categoryController;
  List<String> imageUrls = [];

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final data = widget.initialData;
    nameController = TextEditingController(text: data['name']);
    descriptionController = TextEditingController(text: data['description']);
    priceController = TextEditingController(text: data['price'].toString());
    quantityController = TextEditingController(
      text: data['quantity'].toString(),
    );
    unitController = TextEditingController(text: data['unit']);
    categoryController = TextEditingController(text: data['category']);
    imageUrls = List<String>.from(data['images'] ?? []);
  }

  Future<List<String>> uploadImagesToCloudinary(List<File> files) async {
    const cloudName = 'dravgdklo';
    const uploadPreset = 'petzyprofile';
    final url = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
    );

    List<String> uploadedUrls = [];

    for (var file in files) {
      final request =
          http.MultipartRequest('POST', url)
            ..fields['upload_preset'] = uploadPreset
            ..files.add(await http.MultipartFile.fromPath('file', file.path));

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final data = json.decode(responseBody);
        uploadedUrls.add(data['secure_url']);
      } else {
        debugPrint('Image upload failed: ${response.statusCode}');
      }
    }

    return uploadedUrls;
  }

  void updateProduct() async {
    debugPrint("Updating product with images: $imageUrls");

    await FirebaseFirestore.instance
        .collection('products')
        .doc(widget.productId)
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

  void _replaceImages() async {
    try {
      final pickedFiles = await _picker.pickMultiImage();
      if (pickedFiles.isNotEmpty) {
        final files = pickedFiles.map((e) => File(e.path)).toList();

        // Show loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const Center(child: CircularProgressIndicator()),
        );

        final newUrls = await uploadImagesToCloudinary(files);

        Navigator.of(context).pop(); // Close loading

        if (newUrls.isNotEmpty) {
          setState(() {
            imageUrls = newUrls;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to upload images.")),
          );
        }
      }
    } catch (e) {
      Navigator.of(context).pop(); // Close loading if open
      debugPrint("Image pick/upload error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Product"),
        backgroundColor: primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (imageUrls.isNotEmpty)
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: imageUrls.length,
                  itemBuilder:
                      (context, index) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Image.network(
                          imageUrls[index],
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
              onPressed: _replaceImages,
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
              onPressed: updateProduct,
              icon: const Icon(Icons.save),
              label: const Text("Save Changes"),
              style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
            ),
          ],
        ),
      ),
    );
  }
}
