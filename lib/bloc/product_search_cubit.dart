import 'package:flutter_bloc/flutter_bloc.dart';

class ProductSearchCubit extends Cubit<String> {
  ProductSearchCubit() : super('');

  void updateQuery(String query) {
    emit(query.toLowerCase());
  }

  void clearQuery() {
    emit('');
  }
}
