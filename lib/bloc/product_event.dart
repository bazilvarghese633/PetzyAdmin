import 'dart:typed_data';
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
  final List<Uint8List> imageBytes;
  final List<String> imageNames;

  AddProductSubmitted({
    required this.name,
    required this.description,
    required this.price,
    required this.quantity,
    required this.unit,
    required this.category,
    required this.imageBytes,
    required this.imageNames,
  });

  @override
  List<Object?> get props => [
    name,
    description,
    price,
    quantity,
    unit,
    category,
    imageBytes,
    imageNames,
  ];
}
