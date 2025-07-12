import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProductDetailState {
  final bool loading;
  final Map<String, dynamic>? product;
  final String? error;

  ProductDetailState({required this.loading, this.product, this.error});

  factory ProductDetailState.initial() => ProductDetailState(loading: true);
  factory ProductDetailState.success(Map<String, dynamic> product) =>
      ProductDetailState(loading: false, product: product);
  factory ProductDetailState.failure(String error) =>
      ProductDetailState(loading: false, error: error);
}

class ProductDetailCubit extends Cubit<ProductDetailState> {
  ProductDetailCubit() : super(ProductDetailState.initial());

  Future<void> fetchProduct(String id) async {
    emit(ProductDetailState(loading: true));
    try {
      final doc =
          await FirebaseFirestore.instance.collection('products').doc(id).get();

      if (doc.exists) {
        final data = doc.data()!;
        data['id'] = doc.id;
        emit(ProductDetailState.success(data));
      } else {
        emit(ProductDetailState.failure("Product not found"));
      }
    } catch (e) {
      emit(ProductDetailState.failure("Error fetching product: $e"));
    }
  }
}

class ImageCarouselCubit extends Cubit<int> {
  ImageCarouselCubit() : super(0);

  void updatePage(int index) => emit(index);
}
