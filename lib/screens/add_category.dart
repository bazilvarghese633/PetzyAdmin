import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petzyadmin/bloc/category_bloc.dart';
import 'package:petzyadmin/bloc/category_event.dart';
import 'package:petzyadmin/bloc/category_state.dart';
import 'package:petzyadmin/core/colors.dart';

class AddCategoryPage extends StatefulWidget {
  const AddCategoryPage({super.key});

  @override
  State<AddCategoryPage> createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends State<AddCategoryPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    context.read<CategoryBloc>().add(LoadCategoriesEvent());
    super.initState();
  }

  void _editCategory(DocumentSnapshot doc) {
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

  void _deleteCategory(DocumentSnapshot doc) {
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
    return Scaffold(
      backgroundColor: whiteColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Add New Category
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Enter category name",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    if (_controller.text.trim().isNotEmpty) {
                      context.read<CategoryBloc>().add(
                        AddCategoryEvent(_controller.text.trim()),
                      );
                      _controller.clear();
                    }
                  },
                  child: const Text("Add"),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Search Field
            TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search categories...',
              ),
              onChanged: (value) {
                context.read<CategoryBloc>().add(SearchCategoryEvent(value));
              },
            ),
            const SizedBox(height: 20),

            // Category List
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
                                onPressed: () => _editCategory(doc),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => _deleteCategory(doc),
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
