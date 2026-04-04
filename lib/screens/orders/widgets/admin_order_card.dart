import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petzyadmin/bloc/admin_orders_bloc.dart';
import 'package:petzyadmin/core/colors.dart';
import 'package:petzyadmin/core/utils/order_status_helper.dart';
import 'package:petzyadmin/widgets/common/dialogs/order_status_update_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminOrderCard extends StatelessWidget {
  final Map<String, dynamic> order;

  const AdminOrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 800) {
          // Tablet/Desktop layout
          return _buildHorizontalLayout(context);
        } else {
          // Mobile layout
          return _buildVerticalLayout(context);
        }
      },
    );
  }

  // 📱 Mobile layout (your original design)
  Widget _buildVerticalLayout(BuildContext context) {
    return Card(
      color: whiteColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOrderHeader(),
            const SizedBox(height: 12),
            _buildUserInfo(),
            const SizedBox(height: 12),
            _buildProductInfo(),
            const SizedBox(height: 12),
            _buildOrderFooter(context),
          ],
        ),
      ),
    );
  }

  // 💻 Tablet/Desktop layout
  Widget _buildHorizontalLayout(BuildContext context) {
    return Card(
      color: whiteColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProductImage(),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildOrderHeader(),
                  const SizedBox(height: 12),
                  _buildUserInfo(),
                  const SizedBox(height: 12),
                  _buildProductDetails(),
                  const SizedBox(height: 12),
                  _buildOrderFooter(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Order #${(order['id'] as String).substring((order['id'] as String).length - 6)}',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: secondaryColor,
          ),
        ),
        _buildStatusBadge(),
      ],
    );
  }

  Widget _buildStatusBadge() {
    final status = order['status'] as String;
    final color = OrderStatusHelper.getStatusColor(status);
    final icon = OrderStatusHelper.getStatusIcon(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfo() {
    return Column(
      children: [
        Row(
          children: [
            const Icon(Icons.person, size: 16, color: grey600),
            const SizedBox(width: 8),
            Text(
              order['userName'] ?? 'Unknown User',
              style: const TextStyle(color: secondaryColor, fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(Icons.email, size: 16, color: grey600),
            const SizedBox(width: 8),
            Text(
              order['userEmail'] ?? 'No Email',
              style: const TextStyle(color: grey600, fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProductInfo() {
    return Row(
      children: [
        _buildProductImage(),
        const SizedBox(width: 12),
        Expanded(child: _buildProductDetails()),
      ],
    );
  }

  Widget _buildProductImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        order['productImage'] ?? '',
        width: 70,
        height: 70,
        fit: BoxFit.cover,
        errorBuilder:
            (_, __, ___) => Container(
              width: 70,
              height: 70,
              color: grey200,
              child: const Icon(Icons.image_not_supported, color: grey600),
            ),
      ),
    );
  }

  Widget _buildProductDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          order['productName'] ?? 'Unknown Product',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: secondaryColor,
          ),
        ),
        Text(
          'Category: ${order['productCategory'] ?? 'Unknown'}',
          style: const TextStyle(fontSize: 12, color: grey600),
        ),
        Text(
          'Qty: ${order['quantity'] ?? 0}',
          style: const TextStyle(fontSize: 12, color: grey600),
        ),
        Text(
          '₹${(order['totalAmount'] as num?)?.toStringAsFixed(2) ?? '0.00'}',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildOrderFooter(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Placed: ${OrderStatusHelper.formatDate(order['createdAt'] as Timestamp?)}',
          style: const TextStyle(fontSize: 12, color: grey600),
        ),
        ElevatedButton(
          onPressed: () => _showStatusUpdateDialog(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: whiteColor,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: const Text('Update Status', style: TextStyle(fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  void _showStatusUpdateDialog(BuildContext context) {
    final adminOrdersBloc = BlocProvider.of<AdminOrdersBloc>(context);

    showDialog(
      context: context,
      builder:
          (dialogContext) => BlocProvider.value(
            value: adminOrdersBloc,
            child: OrderStatusUpdateDialog(order: order),
          ),
    );
  }
}
