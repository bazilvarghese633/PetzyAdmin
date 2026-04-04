import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petzyadmin/core/colors.dart';
import 'package:petzyadmin/bloc/edit_product_cubit.dart';
import 'widgets/edit_product_form.dart';

class EditProductScreen extends StatelessWidget {
  final String productId;
  final Map<String, dynamic> initialData;

  const EditProductScreen({
    super.key,
    required this.productId,
    required this.initialData,
  });

  @override
  Widget build(BuildContext context) {
    final initialImages = List<String>.from(initialData['images'] ?? []);

    return BlocProvider(
      create: (_) => EditProductCubit(initialImages),
      child: Scaffold(
        backgroundColor: whiteColor,
        appBar: AppBar(
          title: const Text("Edit Product"),
          backgroundColor: primaryColor,
          elevation: 0,
        ),
        body: BlocBuilder<EditProductCubit, EditProductState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: primaryColor),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: EditProductForm(
                productId: productId,
                initialData: initialData,
              ),
            );
          },
        ),
      ),
    );
  }
}
