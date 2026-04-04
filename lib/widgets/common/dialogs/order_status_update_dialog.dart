import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petzyadmin/bloc/admin_orders_bloc.dart';
import 'package:petzyadmin/bloc/admin_orders_event.dart';
import 'package:petzyadmin/core/colors.dart';
import 'package:petzyadmin/core/utils/order_status_helper.dart';

class OrderStatusUpdateDialog extends StatelessWidget {
  final Map<String, dynamic> order;

  const OrderStatusUpdateDialog({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final currentStatus = order['status'].toString().toLowerCase();
    final progression = OrderStatusHelper.getProgressionStatuses();
    final statusOrder = progression.map((e) => e['value']!).toList();
    final currentIndex = statusOrder.indexOf(currentStatus);

    return AlertDialog(
      backgroundColor: whiteColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      contentPadding: EdgeInsets.zero,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// Header
          Container(
            padding: const EdgeInsets.fromLTRB(24, 20, 16, 20),
            decoration: BoxDecoration(
              color: whiteColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Order status',
                      style: TextStyle(
                        color: secondaryColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Order #${(order['id'] as String).substring((order['id'] as String).length - 6)}',
                      style: const TextStyle(
                        color: grey600,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: grey600, size: 20),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          /// Stepper Body
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                children:
                    progression.asMap().entries.map((entry) {
                      final index = entry.key;
                      final status = entry.value;
                      final isLast = index == progression.length - 1;
                      final isCompleted = index < currentIndex;
                      final isCurrent = index == currentIndex;
                      // ignore: unused_local_variable
                      final isFuture = index > currentIndex;

                      final updateOptions =
                          OrderStatusHelper.getUpdateStatusOptions(
                            currentStatus,
                          );
                      final isUpdateable = updateOptions.any(
                        (opt) => opt['value'] == status['value'],
                      );

                      return _buildStatusItem(
                        context: context,
                        statusValue: status['value']!,
                        label: status['label']!,
                        isCompleted: isCompleted,
                        isCurrent: isCurrent,
                        isLast: isLast,
                        isUpdateable: isUpdateable,
                        onTap:
                            isUpdateable
                                ? () => _updateStatus(context, status['value']!)
                                : null,
                      );
                    }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildStatusItem({
    required BuildContext context,
    required String statusValue,
    required String label,
    required bool isCompleted,
    required bool isCurrent,
    required bool isLast,
    required bool isUpdateable,
    VoidCallback? onTap,
  }) {
    // ignore: unused_local_variable
    final statusColor =
        isCompleted
            ? Colors.green
            : isCurrent
            ? primaryColor
            : isUpdateable
            ? secondaryColor.withOpacity(0.8)
            : Colors.grey.shade300;

    final icon = OrderStatusHelper.getStatusIcon(statusValue);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Timeline Visualization
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color:
                      isCompleted
                          ? Colors.green.withOpacity(0.1)
                          : isCurrent
                          ? primaryColor.withOpacity(0.1)
                          : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color:
                        isCompleted
                            ? Colors.green
                            : isCurrent
                            ? primaryColor
                            : Colors.grey.shade200,
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Icon(
                    isCompleted ? Icons.check : icon,
                    size: 16,
                    color:
                        isCompleted
                            ? Colors.green
                            : isCurrent
                            ? primaryColor
                            : Colors.grey.shade400,
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color:
                          isCompleted
                              ? Colors.green.withOpacity(0.5)
                              : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),

          /// Label Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 28),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight:
                                  (isCurrent || isUpdateable)
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                              color:
                                  isCurrent
                                      ? primaryColor
                                      : (isCompleted || isUpdateable)
                                      ? secondaryColor
                                      : Colors.grey.shade400,
                            ),
                          ),
                          if (isCurrent)
                            const Padding(
                              padding: EdgeInsets.only(top: 2),
                              child: Text(
                                'Current Stage',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (isUpdateable)
                        GestureDetector(
                          onTap: onTap,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryColor.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Text(
                              'UPDATE',
                              style: TextStyle(
                                color: whiteColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
