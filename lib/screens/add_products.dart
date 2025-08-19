import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petzyadmin/bloc/product_bloc.dart';
import 'package:petzyadmin/bloc/product_event.dart';
import 'package:petzyadmin/bloc/product_form/product_form_cubit.dart';
import 'package:petzyadmin/bloc/product_state.dart';
import 'package:petzyadmin/core/colors.dart';
import 'package:petzyadmin/widgets/responsive.dart';

class AddProductPage extends StatelessWidget {
  AddProductPage({super.key});

  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final quantityController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickMultipleImages(BuildContext context) async {
    final pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      final imageBytes = await Future.wait(
        pickedFiles.map((f) => f.readAsBytes()),
      );
      final imageNames = pickedFiles.map((f) => f.name).toList();
      context.read<ProductFormCubit>().setImageBytes(imageBytes, imageNames);
    }
  }

  void _submitProduct(BuildContext context, ProductFormState formState) {
    if (!_formKey.currentState!.validate() || formState.imageBytes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields and add images'),
        ),
      );
      return;
    }
    context.read<AddProductBloc>().add(
      AddProductSubmitted(
        name: nameController.text.trim(),
        description: descriptionController.text.trim(),
        price: int.tryParse(priceController.text) ?? 0,
        quantity: int.tryParse(quantityController.text) ?? 0,
        unit: formState.selectedUnit!,
        category: formState.selectedCategory!,
        imageBytes: formState.imageBytes,
        imageNames: formState.imageNames,
      ),
    );
  }

  InputDecoration _decoration(String label) => InputDecoration(
    labelText: label,
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    enabledBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: primaryColor, width: 1.5),
      borderRadius: BorderRadius.circular(10),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: primaryColor, width: 2),
      borderRadius: BorderRadius.circular(10),
    ),
  );

  Widget _buildForm(BuildContext context, ProductFormState formState) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: nameController,
            decoration: _decoration('Product Name'),
            validator: (v) => v!.isEmpty ? 'Enter product name' : null,
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: descriptionController,
            decoration: _decoration('Description'),
            maxLines: 3,
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: priceController,
            keyboardType: TextInputType.number,
            decoration: _decoration('Price'),
            validator: (v) => v!.isEmpty ? 'Enter price' : null,
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: quantityController,
            keyboardType: TextInputType.number,
            decoration: _decoration('Available Quantity'),
            validator: (v) => v!.isEmpty ? 'Enter quantity' : null,
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: formState.selectedUnit,
            decoration: _decoration("Unit"),
            hint: const Text("Select Unit"),
            validator: (v) => v == null ? 'Select unit' : null,
            onChanged: (v) => context.read<ProductFormCubit>().setUnit(v),
            items:
                ['per gram', 'per packet', 'per pair', 'per item']
                    .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                    .toList(),
          ),
          const SizedBox(height: 10),
          StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance.collection('categories').snapshots(),
            builder: (_, snapshot) {
              if (!snapshot.hasData) return const CircularProgressIndicator();
              final categories =
                  snapshot.data!.docs.map((d) => d['name'] as String).toList();
              return DropdownButtonFormField<String>(
                value: formState.selectedCategory,
                decoration: _decoration("Category"),
                hint: const Text("Select Category"),
                validator: (v) => v == null ? 'Select category' : null,
                onChanged:
                    (v) => context.read<ProductFormCubit>().setCategory(v),
                items:
                    categories
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
              );
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _pickMultipleImages(context),
            icon: const Icon(Icons.image),
            label: const Text("Select Images"),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: whiteColor,
            ),
          ),
          const SizedBox(height: 10),
          formState.imageBytes.isNotEmpty
              ? SizedBox(
                height: 100,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: formState.imageBytes.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder:
                      (_, i) => Image.memory(
                        formState.imageBytes[i],
                        width: 100,
                        fit: BoxFit.cover,
                      ),
                ),
              )
              : const Text(
                "No images selected",
                style: TextStyle(color: greyColor),
              ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _submitProduct(context, formState),
            child: const Text("Add Product"),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProductFormCubit(),
      child: BlocListener<AddProductBloc, AddProductState>(
        listener: (context, state) {
          if (state is AddProductSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Product added successfully')),
            );
            nameController.clear();
            descriptionController.clear();
            priceController.clear();
            quantityController.clear();
            context.read<ProductFormCubit>().resetForm();
          } else if (state is AddProductFailure) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: Scaffold(
          backgroundColor: whiteColor,
          body: BlocBuilder<AddProductBloc, AddProductState>(
            builder: (context, addState) {
              if (addState is AddProductLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: primaryColor),
                );
              }
              return BlocBuilder<ProductFormCubit, ProductFormState>(
                builder: (context, formState) {
                  return ResponsiveLayout(
                    mobile:
                        (_) => SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: _buildForm(context, formState),
                        ),
                    tablet:
                        (_) => Center(
                          child: SizedBox(
                            width: 500,
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.all(24),
                              child: _buildForm(context, formState),
                            ),
                          ),
                        ),
                    desktop:
                        (_) => Center(
                          child: SizedBox(
                            width: 700,
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.all(32),
                              child: _buildForm(context, formState),
                            ),
                          ),
                        ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
