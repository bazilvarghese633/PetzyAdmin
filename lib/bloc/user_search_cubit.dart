import 'package:flutter_bloc/flutter_bloc.dart';

class UserSearchCubit extends Cubit<String> {
  UserSearchCubit() : super('');

  void updateSearchQuery(String query) => emit(query.toLowerCase());
}
