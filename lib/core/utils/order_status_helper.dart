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

  static List<Map<String, String>> getUpdateStatusOptions() {
    return [
      {'value': 'accepted', 'label': 'Accepted'},
      {'value': 'shipped', 'label': 'Shipped'},
      {'value': 'outForDelivery', 'label': 'Out for Delivery'},
      {'value': 'delivered', 'label': 'Delivered'},
    ];
  }
}
