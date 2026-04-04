import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderStatusHelper {
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Colors.indigo;
      case 'accepted':
        return Colors.teal;
      case 'shipped':
        return Colors.blue;
      case 'outfordelivery':
        return Colors.deepOrange;
      case 'delivered':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.blueGrey;
    }
  }

  static IconData getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return Icons.task_alt;
      case 'shipped':
        return Icons.local_shipping;
      case 'outfordelivery':
        return Icons.directions_bike;
      case 'delivered':
        return Icons.home_filled;
      case 'pending':
        return Icons.access_time;
      case 'paid':
        return Icons.check_circle;
      case 'failed':
        return Icons.error;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  static String getStatusDisplayText(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return 'Payment Completed';
      case 'accepted':
        return 'Accepted';
      case 'shipped':
        return 'Shipped';
      case 'outfordelivery':
        return 'Out for Delivery';
      case 'delivered':
        return 'Delivered';
      case 'pending':
        return 'Pending';
      case 'failed':
        return 'Failed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status.toUpperCase();
    }
  }

  static String formatDate(Timestamp? timestamp) {
    if (timestamp == null) return 'Unknown';
    final date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  static List<Map<String, String>> getStatusOptions() {
    return [
      {'value': 'all', 'label': 'All Orders'},
      {'value': 'paid', 'label': 'Payment Completed'},
      {'value': 'accepted', 'label': 'Accepted'},
      {'value': 'shipped', 'label': 'Shipped'},
      {'value': 'outfordelivery', 'label': 'Out for Delivery'},
      {'value': 'delivered', 'label': 'Delivered'},
      {'value': 'pending', 'label': 'Pending'},
      {'value': 'completed', 'label': 'Completed'},
      {'value': 'failed', 'label': 'Failed'},
      {'value': 'cancelled', 'label': 'Cancelled'},
    ];
  }

  static List<Map<String, String>> getUpdateStatusOptions(String currentStatus) {
    const statusOrder = ['pending', 'paid', 'accepted', 'shipped', 'outfordelivery', 'delivered'];
    final currentIndex = statusOrder.indexOf(currentStatus.toLowerCase());

    // If terminal status or not in sequence, return empty or limit to forward moves
    final availableOptions = [
      {'value': 'accepted', 'label': 'Accepted'},
      {'value': 'shipped', 'label': 'Shipped'},
      {'value': 'outfordelivery', 'label': 'Out for Delivery'},
      {'value': 'delivered', 'label': 'Delivered'},
    ];

    return availableOptions.where((option) {
      final optionIndex = statusOrder.indexOf(option['value']!.toLowerCase());
      return optionIndex > currentIndex;
    }).toList();
  }

  static List<Map<String, String>> getProgressionStatuses() {
    return [
      {'value': 'pending', 'label': 'Pending'},
      {'value': 'paid', 'label': 'Payment Completed'},
      {'value': 'accepted', 'label': 'Accepted'},
      {'value': 'shipped', 'label': 'Shipped'},
      {'value': 'outfordelivery', 'label': 'Out for Delivery'},
      {'value': 'delivered', 'label': 'Delivered'},
    ];
  }
}
