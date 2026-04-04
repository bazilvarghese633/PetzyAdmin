import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:petzyadmin/bloc/product_form/product_form_cubit.dart';
import 'package:petzyadmin/core/colors.dart';

class ImagePickerSection extends StatelessWidget {
  const ImagePickerSection({super.key});

  Future<void> _pickMultipleImages(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      final imageBytes = await Future.wait(
        pickedFiles.map((f) => f.readAsBytes()),
      );
      final imageNames = pickedFiles.map((f) => f.name).toList();
      if (context.mounted) {
        context.read<ProductFormCubit>().setImageBytes(imageBytes, imageNames);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductFormCubit, ProductFormState>(
      builder: (context, formState) {
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
              onTap: () => _pickMultipleImages(context),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: greyColor.withOpacity(0.2),
                    style: BorderStyle.solid,
                  ),
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.add_photo_alternate_rounded,
                      color: primaryColor,
                      size: 32,
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Tap to add images",
                      style: TextStyle(
                        color: greyColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            formState.imageBytes.isNotEmpty
                ? SizedBox(
                    height: 90,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: formState.imageBytes.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, i) => Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.memory(
                              formState.imageBytes[i],
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
                                  .read<ProductFormCubit>()
                                  .removeImage(i),
                              child: CircleAvatar(
                                radius: 12,
                                backgroundColor: Colors.black.withOpacity(0.5),
                                child: const Icon(
                                  Icons.close,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : const Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        "No images selected yet",
                        style: TextStyle(color: grey600, fontSize: 13),
                      ),
                    ),
                  ),
          ],
        );
      },
    );
  }
}
