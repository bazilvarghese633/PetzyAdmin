import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:petzyadmin/bloc/edit_product_cubit.dart';
import 'package:petzyadmin/core/colors.dart';

class EditImagePicker extends StatelessWidget {
  const EditImagePicker({super.key});

  Future<void> _pickImages(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      final files = pickedFiles.map((e) => File(e.path)).toList();
      if (context.mounted) {
        context.read<EditProductCubit>().addImages(files);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditProductCubit, EditProductState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Product Images",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: secondaryColor,
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () => _pickImages(context),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: greyColor.withOpacity(0.2)),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.add_photo_alternate_rounded,
                        color: primaryColor, size: 32),
                    SizedBox(height: 8),
                    Text("Add more images",
                        style: TextStyle(
                            color: greyColor, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (state.imageUrls.isNotEmpty)
              SizedBox(
                height: 90,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: state.imageUrls.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) => Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          state.imageUrls[index],
                          width: 90,
                          height: 90,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: InkWell(
                          onTap: () => context
                              .read<EditProductCubit>()
                              .removeImage(index),
                          child: CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.black.withOpacity(0.5),
                            child: const Icon(Icons.close,
                                size: 14, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              const Center(
                  child: Text("No images selected",
                      style: TextStyle(color: grey600))),
          ],
        );
      },
    );
  }
}
