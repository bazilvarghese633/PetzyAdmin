import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petzyadmin/bloc/admin_orders_bloc.dart';
import 'package:petzyadmin/bloc/admin_orders_event.dart';
import 'package:petzyadmin/bloc/admin_orders_filter_bloc.dart';
import 'package:petzyadmin/core/colors.dart';
import 'package:petzyadmin/core/utils/order_status_helper.dart';

class AdminOrdersFilterWidget extends StatelessWidget {
  const AdminOrdersFilterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: primaryColor.withOpacity(0.1),
      child: Column(
        children: [
          _buildSearchBar(context),
          const SizedBox(height: 12),
          _buildStatusFilter(context),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search by order ID, product, or user...',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: whiteColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
      onChanged: (query) {
        context.read<AdminOrdersFilterBloc>().add(
          UpdateSearchQueryEvent(query),
        );
        context.read<AdminOrdersBloc>().add(SearchOrdersEvent(query));
      },
    );
  }

  Widget _buildStatusFilter(BuildContext context) {
    return BlocBuilder<AdminOrdersFilterBloc, AdminOrdersFilterState>(
      builder: (context, filterState) {
        final currentState = filterState as AdminOrdersFilterInitial;

        return Row(
          children: [
            const Text('Filter by Status: '),
            Expanded(
              child: DropdownButton<String>(
                dropdownColor: whiteColor,
                value: currentState.selectedFilter,
                isExpanded: true,
                items:
                    OrderStatusHelper.getStatusOptions()
                        .map(
                          (status) => DropdownMenuItem(
                            value: status['value']!,
                            child: Text(status['label']!),
                          ),
                        )
                        .toList(),
                onChanged: (value) {
                  if (value != null) {
                    context.read<AdminOrdersFilterBloc>().add(
                      UpdateFilterEvent(value),
                    );
                    context.read<AdminOrdersBloc>().add(
                      FilterOrdersByStatusEvent(value),
                    );
                  }
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
