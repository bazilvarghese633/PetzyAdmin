import 'package:cloud_firestore/cloud_firestore.dart';

abstract class CategoryState {}

class CategoryLoadingState extends CategoryState {}

class CategoryLoadedState extends CategoryState {
  final List<DocumentSnapshot> categories;
  CategoryLoadedState(this.categories);
}
