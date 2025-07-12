import 'dart:io';

class ProductFormState {
  final String? selectedCategory;
  final String? selectedUnit;
  final List<File> imageFiles;

  ProductFormState({
    required this.selectedCategory,
    required this.selectedUnit,
    required this.imageFiles,
  });

  factory ProductFormState.initial() {
    return ProductFormState(
      selectedCategory: null,
      selectedUnit: null,
      imageFiles: [],
    );
  }

  ProductFormState copyWith({
    String? selectedCategory,
    String? selectedUnit,
    List<File>? imageFiles,
  }) {
    return ProductFormState(
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedUnit: selectedUnit ?? this.selectedUnit,
      imageFiles: imageFiles ?? this.imageFiles,
    );
  }

  @override
  String toString() {
    return 'ProductFormState(category: $selectedCategory, unit: $selectedUnit, images: ${imageFiles.length})';
  }
}
