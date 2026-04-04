import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petzyadmin/bloc/category_bloc.dart';
import 'package:petzyadmin/bloc/category_event.dart';
import 'package:petzyadmin/bloc/category_state.dart';
import 'package:petzyadmin/core/colors.dart';

class CategoryInputField extends StatefulWidget {
  const CategoryInputField({super.key});

  @override
  State<CategoryInputField> createState() => _CategoryInputFieldState();
}

class _CategoryInputFieldState extends State<CategoryInputField> {
  final TextEditingController _controller = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: "Enter category name",
                  hintStyle: const TextStyle(color: greyColor),
                  filled: true,
                  fillColor: whiteColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: greyColor.withOpacity(0.3)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: greyColor.withOpacity(0.2)),
                  ),
                  errorText: _errorText,
                ),
                onChanged: (value) {
                  if (_errorText != null) {
                    setState(() => _errorText = null);
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  final rawName = _controller.text;
                  final name = rawName.trim();

                  if (name.isEmpty) {
                    setState(() => _errorText = "Category name cannot be empty");
                    return;
                  }

                  if (rawName.startsWith(' ') || rawName.endsWith(' ')) {
                    setState(() => _errorText = "Name cannot start or end with spaces");
                    return;
                  }

                  if (RegExp(r'\d').hasMatch(name)) {
                    setState(() => _errorText = "Name cannot contain numbers");
                    return;
                  }

                  if (state is CategoryLoadedState) {
                    final exists = state.categories.any(
                      (doc) =>
                          doc['name'].toString().toLowerCase() ==
                          name.toLowerCase(),
                    );

                    if (exists) {
                      setState(() => _errorText = "Category already exists");
                      return;
                    }
                  }

                  context.read<CategoryBloc>().add(AddCategoryEvent(name));
                  _controller.clear();
                  setState(() => _errorText = null);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: whiteColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("Add", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        );
      },
    );
  }
}
