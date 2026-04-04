import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petzyadmin/bloc/category_bloc.dart';
import 'package:petzyadmin/bloc/category_event.dart';
import 'package:petzyadmin/bloc/category_state.dart';
import 'package:petzyadmin/core/colors.dart';

class CategoryListItem extends StatelessWidget {
  final DocumentSnapshot doc;

  const CategoryListItem({super.key, required this.doc});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: Text(
          doc['name'],
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: secondaryColor,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: Colors.orange),
              onPressed: () => _showEditDialog(context, doc),
              tooltip: 'Edit',
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: redColor),
              onPressed: () => _showDeleteDialog(context, doc),
              tooltip: 'Delete',
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, DocumentSnapshot doc) {
    final TextEditingController editController = TextEditingController(
      text: doc['name'],
    );
    String? editErrorText;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: whiteColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: const Text(
                "Edit Category",
                style: TextStyle(
                    color: secondaryColor, fontWeight: FontWeight.bold),
              ),
              content: TextField(
                controller: editController,
                decoration: InputDecoration(
                  hintText: "Enter new name",
                  hintStyle: const TextStyle(color: greyColor),
                  errorText: editErrorText,
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: greyColor.withOpacity(0.3)),
                  ),
                ),
                onChanged: (_) {
                  if (editErrorText != null) {
                    setState(() => editErrorText = null);
                  }
                },
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel", style: TextStyle(color: grey600)),
                ),
                ElevatedButton(
                  onPressed: () {
                    final rawName = editController.text;
                    final name = rawName.trim();

                    if (name.isEmpty) {
                      setState(
                          () => editErrorText = "Category name cannot be empty");
                      return;
                    }

                    if (rawName.startsWith(' ') || rawName.endsWith(' ')) {
                      setState(() =>
                          editErrorText = "Name cannot start or end with spaces");
                      return;
                    }

                    if (RegExp(r'\d').hasMatch(name)) {
                      setState(() => editErrorText = "Name cannot contain numbers");
                      return;
                    }

                    final state = dialogContext.read<CategoryBloc>().state;
                    if (state is CategoryLoadedState) {
                      final exists = state.categories.any(
                        (category) =>
                            category.id != doc.id &&
                            category['name'].toString().toLowerCase() ==
                                name.toLowerCase(),
                      );

                      if (exists) {
                        setState(() => editErrorText = "Category already exists");
                        return;
                      }
                    }

                    dialogContext.read<CategoryBloc>().add(
                          EditCategoryEvent(doc.id, name),
                        );
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: whiteColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text("Update"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, DocumentSnapshot doc) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: whiteColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Delete Category",
          style: TextStyle(color: secondaryColor, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "Are you sure you want to delete this category?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("No", style: TextStyle(color: grey600)),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<CategoryBloc>().add(DeleteCategoryEvent(doc.id));
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: redColor,
              foregroundColor: whiteColor,
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text("Yes, Delete"),
          ),
        ],
      ),
    );
  }
}
