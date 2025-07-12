import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';

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
}

class ProductFormCubit extends Cubit<ProductFormState> {
  ProductFormCubit() : super(ProductFormState.initial());

  void setCategory(String? category) {
    emit(state.copyWith(selectedCategory: category));
  }

  void setUnit(String? unit) {
    emit(state.copyWith(selectedUnit: unit));
  }

  void setImages(List<File> images) {
    emit(state.copyWith(imageFiles: images));
  }

  void resetForm() {
    emit(ProductFormState.initial());
  }
}
