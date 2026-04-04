import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProductFormState {
  final String? selectedCategory;
  final String? selectedUnit;
  final List<Uint8List> imageBytes;
  final List<String> imageNames;

  ProductFormState({
    required this.selectedCategory,
    required this.selectedUnit,
    required this.imageBytes,
    required this.imageNames,
  });

  factory ProductFormState.initial() {
    return ProductFormState(
      selectedCategory: null,
      selectedUnit: null,
      imageBytes: [],
      imageNames: [],
    );
  }

  ProductFormState copyWith({
    String? selectedCategory,
    String? selectedUnit,
    List<Uint8List>? imageBytes,
    List<String>? imageNames,
  }) {
    return ProductFormState(
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedUnit: selectedUnit ?? this.selectedUnit,
      imageBytes: imageBytes ?? this.imageBytes,
      imageNames: imageNames ?? this.imageNames,
    );
  }

  @override
  String toString() {
    return 'ProductFormState(category: $selectedCategory, unit: $selectedUnit, images: ${imageBytes.length})';
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

  void setImageBytes(List<Uint8List> imageBytes, List<String> imageNames) {
    // Append instead of replace for better UX
    final List<Uint8List> currentBytes = List.from(state.imageBytes);
    final List<String> currentNames = List.from(state.imageNames);
    currentBytes.addAll(imageBytes);
    currentNames.addAll(imageNames);
    emit(state.copyWith(imageBytes: currentBytes, imageNames: currentNames));
  }

  void removeImage(int index) {
    final List<Uint8List> currentBytes = List.from(state.imageBytes);
    final List<String> currentNames = List.from(state.imageNames);
    if (index >= 0 && index < currentBytes.length) {
      currentBytes.removeAt(index);
      currentNames.removeAt(index);
      emit(state.copyWith(imageBytes: currentBytes, imageNames: currentNames));
    }
  }

  void resetForm() {
    emit(ProductFormState.initial());
  }
}
