import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petzyadmin/bloc/edit_product_cubit.dart';
import 'package:petzyadmin/core/colors.dart';
import 'package:petzyadmin/widgets/common/custom_text_field.dart';
import 'edit_image_picker.dart';

class EditProductForm extends StatefulWidget {
  final String productId;
  final Map<String, dynamic> initialData;

  const EditProductForm({
    super.key,
    required this.productId,
    required this.initialData,
  });

  @override
  State<EditProductForm> createState() => _EditProductFormState();
}

class _EditProductFormState extends State<EditProductForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController nameController;
  late final TextEditingController descriptionController;
  late final TextEditingController priceController;
  late final TextEditingController quantityController;

  String? selectedUnit;
  String? selectedCategory;

  @override
  void initState() {
    super.initState();
    nameController =
        TextEditingController(text: widget.initialData['name'] ?? '');
    descriptionController =
        TextEditingController(text: widget.initialData['description'] ?? '');
    priceController =
        TextEditingController(text: (widget.initialData['price'] ?? 0).toString());
    quantityController = TextEditingController(
        text: (widget.initialData['quantity'] ?? 0).toString());
    selectedUnit = widget.initialData['unit'];
    selectedCategory = widget.initialData['category'];
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    quantityController.dispose();
    super.dispose();
  }

  void _submitUpdate(BuildContext context, List<String> imageUrls) async {
    if (!_formKey.currentState!.validate()) return;

    await FirebaseFirestore.instance
        .collection('products')
        .doc(widget.productId)
        .update({
      'name': nameController.text.trim(),
      'description': descriptionController.text.trim(),
      'price': int.tryParse(priceController.text.trim()) ?? 0,
      'quantity': int.tryParse(quantityController.text.trim()) ?? 0,
      'unit': selectedUnit,
      'category': selectedCategory,
      'images': imageUrls,
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product updated successfully')),
      );
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditProductCubit, EditProductState>(
      builder: (context, state) {
        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: whiteColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    CustomTextField(
                      controller: nameController,
                      label: 'Product Name',
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Required'
                          : (v.trim().length < 3 ? 'Min 3 chars' : null),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: descriptionController,
                      label: 'Description',
                      maxLines: 3,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Required'
                          : (v.trim().length < 10 ? 'Min 10 chars' : null),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: priceController,
                            keyboardType: TextInputType.number,
                            label: 'Price (₹)',
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Required';
                              final p = int.tryParse(v);
                              return (p == null || p <= 0) ? '> 0' : null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomTextField(
                            controller: quantityController,
                            keyboardType: TextInputType.number,
                            label: 'Quantity',
                            validator: (v) =>
                                (v == null || v.isEmpty) ? 'Required' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedUnit,
                      decoration: _decoration("Unit"),
                      hint: const Text("Select Unit",
                          style: TextStyle(color: grey600)),
                      validator: (v) => v == null ? 'Select unit' : null,
                      onChanged: (v) => setState(() => selectedUnit = v),
                      items: ['per gram', 'per packet', 'per pair', 'per item']
                          .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('categories')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData)
                          return const LinearProgressIndicator();
                        final categories = snapshot.data!.docs
                            .map((d) => d['name'] as String)
                            .toList();

                        return DropdownButtonFormField<String>(
                          value: selectedCategory,
                          decoration: _decoration("Category"),
                          hint: const Text("Select Category",
                              style: TextStyle(color: grey600)),
                          validator: (v) => v == null ? 'Select category' : null,
                          onChanged: (v) =>
                              setState(() => selectedCategory = v),
                          items: categories
                              .map((c) =>
                                  DropdownMenuItem(value: c, child: Text(c)))
                              .toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const EditImagePicker(),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => _submitUpdate(context, state.imageUrls),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: whiteColor,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Save Changes",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }

  InputDecoration _decoration(String label) => InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: grey600, fontSize: 13),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: greyColor.withOpacity(0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: greyColor.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 1.5),
        ),
        errorStyle: const TextStyle(fontSize: 11),
      );
}
