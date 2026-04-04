import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petzyadmin/bloc/product_search_cubit.dart';
import 'package:petzyadmin/core/colors.dart';

class ProductSearchBar extends StatefulWidget {
  final TextEditingController controller;

  const ProductSearchBar({super.key, required this.controller});

  @override
  State<ProductSearchBar> createState() => _ProductSearchBarState();
}

class _ProductSearchBarState extends State<ProductSearchBar> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: BlocBuilder<ProductSearchCubit, String>(
        builder: (context, query) {
          return TextField(
            controller: widget.controller,
            decoration: InputDecoration(
              hintText: 'Search products...',
              hintStyle: const TextStyle(color: grey600, fontSize: 14),
              prefixIcon: const Icon(Icons.search, color: primaryColor),
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
            onChanged: (value) =>
                context.read<ProductSearchCubit>().updateQuery(value),
          );
        },
      ),
    );
  }
}
