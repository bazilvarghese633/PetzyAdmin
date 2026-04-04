import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petzyadmin/bloc/category_bloc.dart';
import 'package:petzyadmin/bloc/category_event.dart';
import 'package:petzyadmin/bloc/category_state.dart';
import 'package:petzyadmin/core/colors.dart';
import 'category_list_item.dart';

class CategoryList extends StatefulWidget {
  const CategoryList({super.key});

  @override
  State<CategoryList> createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search, color: primaryColor),
            hintText: 'Search categories...',
            filled: true,
            fillColor: whiteColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          onChanged: (value) {
            context.read<CategoryBloc>().add(
                  SearchCategoryEvent(value.trim()),
                );
          },
        ),
        const SizedBox(height: 24),
        Expanded(
          child: BlocBuilder<CategoryBloc, CategoryState>(
            builder: (context, state) {
              if (state is CategoryLoadingState) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is CategoryLoadedState) {
                if (state.categories.isEmpty) {
                  return const Center(
                    child: Text(
                      'No categories found.',
                      style: TextStyle(color: grey600),
                    ),
                  );
                }

                return ListView.separated(
                  itemCount: state.categories.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final doc = state.categories[index];
                    return CategoryListItem(doc: doc);
                  },
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }
}
