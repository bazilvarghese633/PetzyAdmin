import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petzyadmin/bloc/product_bloc.dart';
import 'package:petzyadmin/bloc/product_form/product_form_cubit.dart';
import 'package:petzyadmin/bloc/product_state.dart';
import 'package:petzyadmin/core/colors.dart';
import 'package:petzyadmin/widgets/common/responsive_layout.dart';
import 'widgets/product_form.dart';

class AddProductPage extends StatelessWidget {
  const AddProductPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProductFormCubit(),
      child: Scaffold(
        backgroundColor: whiteColor,
        body: BlocListener<AddProductBloc, AddProductState>(
          listener: (context, state) {
            if (state is AddProductSuccess) {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (ctx) => AlertDialog(
                  backgroundColor: whiteColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  title: Row(
                    children: const [
                      Icon(Icons.check_circle, color: primaryColor, size: 28),
                      SizedBox(width: 12),
                      Text("Success",
                          style: TextStyle(
                              color: secondaryColor,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  content:
                      const Text("The product has been added successfully!"),
                  actions: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        // The form reset logic will be moved to the ProductForm itself via a key or similar
                        // For now, we rely on the state reset which clears the images
                        context.read<ProductFormCubit>().resetForm();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: whiteColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text("Great!"),
                    ),
                  ],
                ),
              );
            }
          },
          child: ResponsiveLayout(
            mobile: (_) => const SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: ProductForm(),
            ),
            tablet: (_) => const Center(
              child: SizedBox(
                width: 500,
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(24),
                  child: ProductForm(),
                ),
              ),
            ),
            desktop: (_) => const Center(
              child: SizedBox(
                width: 700,
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(32),
                  child: ProductForm(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
