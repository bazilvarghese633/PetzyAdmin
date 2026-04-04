import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petzyadmin/bloc/product_bloc.dart';
import 'package:petzyadmin/bloc/product_event.dart';
import 'package:petzyadmin/bloc/product_form/product_form_cubit.dart';
import 'package:petzyadmin/core/colors.dart';
import 'package:petzyadmin/widgets/common/custom_text_field.dart';
import 'package:petzyadmin/bloc/product_state.dart';
import 'image_picker_section.dart';
import 'category_dropdown.dart';

class ProductForm extends StatefulWidget {
  const ProductForm({super.key});

  @override
  State<ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final quantityController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    quantityController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    return BlocListener<AddProductBloc, AddProductState>(
      listener: (context, state) {
        if (state is AddProductSuccess) {
          nameController.clear();
          descriptionController.clear();
          priceController.clear();
          quantityController.clear();
        }
      },
      child: BlocBuilder<ProductFormCubit, ProductFormState>(
        builder: (context, formState) {
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
                        color: Colors.black.withOpacity(0.03),
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
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Enter product name';
                          }
                          if (v.trim().length < 3) {
                            return 'Name too short (min 3)';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: descriptionController,
                        label: 'Description',
                        maxLines: 3,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty)
                            return 'Enter description';
                          if (v.trim().length < 10)
                            return 'Description too short (min 10)';
                          return null;
                        },
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
                                final price = int.tryParse(v);
                                if (price == null || price <= 0)
                                  return 'Must be > 0';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CustomTextField(
                              controller: quantityController,
                              keyboardType: TextInputType.number,
                              label: 'Quantity',
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Required';
                                final qty = int.tryParse(v);
                                if (qty == null || qty < 0)
                                  return 'Cannot be negative';
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: formState.selectedUnit,
                        decoration: _decoration("Unit"),
                        hint: const Text("Select Unit",
                            style: TextStyle(color: grey600)),
                        validator: (v) => v == null ? 'Select unit' : null,
                        onChanged: (v) =>
                            context.read<ProductFormCubit>().setUnit(v),
                        items: [
                          'per gram',
                          'per packet',
                          'per pair',
                          'per item'
                        ]
                            .map((u) =>
                                DropdownMenuItem(value: u, child: Text(u)))
                            .toList(),
                      ),
                      const SizedBox(height: 16),
                      const CategoryDropdown(),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const ImagePickerSection(),
                const SizedBox(height: 32),
                BlocBuilder<AddProductBloc, AddProductState>(
                  builder: (context, addState) {
                    final isLoading = addState is AddProductLoading;
                    return ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () => _submitProduct(context, formState),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: whiteColor,
                        disabledBackgroundColor: primaryColor.withOpacity(0.6),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: whiteColor,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              "Add Product",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                    );
                  },
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  InputDecoration _decoration(String label) => InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: grey600, fontSize: 13),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
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
