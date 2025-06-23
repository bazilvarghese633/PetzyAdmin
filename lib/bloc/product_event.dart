import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class AddProductEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AddProductSubmitted extends AddProductEvent {
  final String name;
  final String description;
  final int price;
  final int quantity;
  final String unit;
  final String category;
  final List<File> images;

  AddProductSubmitted({
    required this.name,
    required this.description,
    required this.price,
    required this.quantity,
    required this.unit,
    required this.category,
    required this.images,
  });

  @override
  List<Object?> get props => [
    name,
    description,
    price,
    quantity,
    unit,
    category,
    images,
  ];
}
