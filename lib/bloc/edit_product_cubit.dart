import 'dart:io';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class EditProductState {
  final List<String> imageUrls;
  final bool isLoading;
  final String? error;

  EditProductState({
    required this.imageUrls,
    required this.isLoading,
    this.error,
  });

  factory EditProductState.initial(List<String> initialImages) {
    return EditProductState(imageUrls: initialImages, isLoading: false);
  }

  EditProductState copyWith({
    List<String>? imageUrls,
    bool? isLoading,
    String? error,
  }) {
    return EditProductState(
      imageUrls: imageUrls ?? this.imageUrls,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class EditProductCubit extends Cubit<EditProductState> {
  EditProductCubit(List<String> initialImages)
    : super(EditProductState.initial(initialImages));

  Future<void> replaceImages(List<File> files) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final urls = await _uploadImagesToCloudinary(files);
      emit(state.copyWith(imageUrls: urls, isLoading: false));
    } catch (e) {
      emit(
        state.copyWith(isLoading: false, error: "Failed to upload images: $e"),
      );
    }
  }

  Future<List<String>> _uploadImagesToCloudinary(List<File> files) async {
    const cloudName = 'dravgdklo';
    const uploadPreset = 'petzyprofile';
    final url = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
    );

    List<String> uploadedUrls = [];

    for (var file in files) {
      final request =
          http.MultipartRequest('POST', url)
            ..fields['upload_preset'] = uploadPreset
            ..files.add(await http.MultipartFile.fromPath('file', file.path));

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final data = json.decode(responseBody);
        uploadedUrls.add(data['secure_url']);
      } else {
        throw Exception('Image upload failed: ${response.statusCode}');
      }
    }

    return uploadedUrls;
  }
}
