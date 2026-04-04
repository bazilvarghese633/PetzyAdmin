import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petzyadmin/bloc/category_bloc.dart';
import 'package:petzyadmin/bloc/category_event.dart';
import 'package:petzyadmin/widgets/common/responsive_layout.dart';
import 'widgets/category_input_field.dart';
import 'widgets/category_list.dart';

class AddCategoryPage extends StatelessWidget {
  const AddCategoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<CategoryBloc>().add(LoadCategoriesEvent());

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: ResponsiveLayout(
        mobile: (context) => _buildContent(context, 16),
        tablet: (context) => Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: _buildContent(context, 24),
          ),
        ),
        desktop: (context) => Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: _buildContent(context, 32),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, double horizontalPadding) {
    return Padding(
      padding: EdgeInsets.all(horizontalPadding),
      child: const Column(
        children: [
          CategoryInputField(),
          SizedBox(height: 24),
          Expanded(child: CategoryList()),
        ],
      ),
    );
  }
}
