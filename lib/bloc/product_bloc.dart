import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:petzyadmin/bloc/product_event.dart';
import 'package:petzyadmin/bloc/product_state.dart';

class AddProductBloc extends Bloc<AddProductEvent, AddProductState> {
  AddProductBloc() : super(AddProductInitial()) {
    on<AddProductSubmitted>(_onSubmit);
  }

  Future<void> _onSubmit(
    AddProductSubmitted event,
    Emitter<AddProductState> emit,
  ) async {
    emit(AddProductLoading());

    try {
      final imageUrls = await _uploadImagesToCloudinary(event.images);

      await FirebaseFirestore.instance.collection('products').add({
        'name': event.name,
        'description': event.description,
        'price': event.price,
        'quantity': event.quantity,
        'unit': event.unit,
        'category': event.category,
        'images': imageUrls,
        'timestamp': Timestamp.now(),
      });

      emit(AddProductSuccess());
    } catch (e) {
      emit(AddProductFailure("Error: $e"));
    }
  }

  Future<List<String>> _uploadImagesToCloudinary(List<File> files) async {
    const cloudName = 'dravgdklo';
    const uploadPreset = 'petzyprofile';
    final url = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
    );

    List<String> imageUrls = [];

    for (var file in files) {
      final request =
          http.MultipartRequest('POST', url)
            ..fields['upload_preset'] = uploadPreset
            ..files.add(await http.MultipartFile.fromPath('file', file.path));

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final data = json.decode(responseBody);
        imageUrls.add(data['secure_url']);
      }
    }

    return imageUrls;
  }
}
