import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petzyadmin/bloc/admin_orders_bloc.dart';
import 'package:petzyadmin/bloc/admin_orders_event.dart';
import 'package:petzyadmin/core/utils/order_status_helper.dart';

class OrderStatusUpdateDialog extends StatelessWidget {
  final Map<String, dynamic> order;

  const OrderStatusUpdateDialog({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final currentStatus = OrderStatusHelper.getStatusDisplayText(
      order['status'],
    );

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        'Update Order Status',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order #${(order['id'] as String).substring((order['id'] as String).length - 6)}',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            'Current status: $currentStatus',
            style: TextStyle(color: Colors.grey[700], fontSize: 14),
          ),
          const SizedBox(height: 20),
          const Text(
            'Select new status:',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                OrderStatusHelper.getUpdateStatusOptions()
                    .map(
                      (statusOption) => ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed:
                            () =>
                                _updateStatus(context, statusOption['value']!),
                        child: Text(statusOption['label']!),
                      ),
                    )
                    .toList(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

  void _updateStatus(BuildContext context, String newStatus) {
    Navigator.pop(context);
    context.read<AdminOrdersBloc>().add(
      UpdateOrderStatusEvent(
        userId: order['userId'],
        orderId: order['id'],
        newStatus: newStatus,
      ),
    );
  }
}
