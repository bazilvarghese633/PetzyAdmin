import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petzyadmin/bloc/product_form/product_form_cubit.dart';
import 'package:petzyadmin/core/colors.dart';

class CategoryDropdown extends StatelessWidget {
  const CategoryDropdown({super.key});

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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductFormCubit, ProductFormState>(
      builder: (context, formState) {
        return StreamBuilder<QuerySnapshot>(
          stream:
              FirebaseFirestore.instance.collection('categories').snapshots(),
          builder: (_, snapshot) {
            if (!snapshot.hasData) return const LinearProgressIndicator();
            final categories =
                snapshot.data!.docs.map((d) => d['name'] as String).toList();
            return DropdownButtonFormField<String>(
              value: formState.selectedCategory,
              isExpanded: true,
              decoration: _decoration("Category"),
              hint: const Text("Select Category",
                  style: TextStyle(color: grey600)),
              validator: (v) => v == null ? 'Select category' : null,
              onChanged: (v) => context.read<ProductFormCubit>().setCategory(v),
              items: categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
            );
          },
        );
      },
    );
  }
}
