import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petzyadmin/bloc/category_bloc.dart';
import 'package:petzyadmin/bloc/category_event.dart';
import 'package:petzyadmin/bloc/category_state.dart';
import 'package:petzyadmin/core/colors.dart';

class AddCategoryPage extends StatelessWidget {
  AddCategoryPage({super.key});

  final TextEditingController _controller = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  void _showEditDialog(BuildContext context, DocumentSnapshot doc) {
    final TextEditingController editController = TextEditingController(
      text: doc['name'],
    );

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Edit Category"),
            content: TextField(
              controller: editController,
              decoration: const InputDecoration(hintText: "Enter new name"),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  final newName = editController.text.trim();
                  if (newName.isNotEmpty) {
                    context.read<CategoryBloc>().add(
                      EditCategoryEvent(doc.id, newName),
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text("Update"),
              ),
            ],
          ),
    );
  }

  void _showDeleteDialog(BuildContext context, DocumentSnapshot doc) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Delete Category"),
            content: const Text(
              "Are you sure you want to delete this category?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  context.read<CategoryBloc>().add(DeleteCategoryEvent(doc.id));
                  Navigator.pop(context);
                },
                child: const Text(
                  "Delete",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Dispatch LoadCategories only once
    context.read<CategoryBloc>().add(LoadCategoriesEvent());

    return Scaffold(
      backgroundColor: whiteColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            /// Add New Category
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Enter category name",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    final name = _controller.text.trim();
                    if (name.isNotEmpty) {
                      context.read<CategoryBloc>().add(AddCategoryEvent(name));
                      _controller.clear();
                    }
                  },
                  child: const Text("Add"),
                ),
              ],
            ),

            const SizedBox(height: 20),

            /// Search Field
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search categories...',
              ),
              onChanged: (value) {
                context.read<CategoryBloc>().add(
                  SearchCategoryEvent(value.trim()),
                );
              },
            ),

            const SizedBox(height: 20),

            /// Category List
            Expanded(
              child: BlocBuilder<CategoryBloc, CategoryState>(
                builder: (context, state) {
                  if (state is CategoryLoadingState) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is CategoryLoadedState) {
                    if (state.categories.isEmpty) {
                      return Center(
                        child: Text(
                          'No categories found.',
                          style: TextStyle(color: greyColor),
                        ),
                      );
                    }

                    return ListView.separated(
                      itemCount: state.categories.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final doc = state.categories[index];
                        return ListTile(
                          tileColor: whiteColor,
                          title: Text(doc['name']),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: greyColor.withOpacity(0.2)),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.orange,
                                ),
                                onPressed: () => _showEditDialog(context, doc),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed:
                                    () => _showDeleteDialog(context, doc),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
