import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'admin_orders_event.dart';
import 'admin_orders_state.dart';

class AdminOrdersBloc extends Bloc<AdminOrdersEvent, AdminOrdersState> {
  List<Map<String, dynamic>> _allOrders = [];

  AdminOrdersBloc() : super(AdminOrdersLoadingState()) {
    on<LoadAllOrdersEvent>(_onLoadAllOrders);
    on<UpdateOrderStatusEvent>(_onUpdateOrderStatus);
    on<SearchOrdersEvent>(_onSearchOrders);
    on<FilterOrdersByStatusEvent>(_onFilterOrdersByStatus);
  }

  Future<void> _onLoadAllOrders(
    LoadAllOrdersEvent event,
    Emitter<AdminOrdersState> emit,
  ) async {
    emit(AdminOrdersLoadingState());

    try {
      _allOrders.clear();

      // Get all users
      final usersSnapshot =
          await FirebaseFirestore.instance.collection('users').get();

      // Get orders from each user
      for (var userDoc in usersSnapshot.docs) {
        final ordersSnapshot =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(userDoc.id)
                .collection('orders')
                .orderBy('createdAt', descending: true)
                .get();

        for (var orderDoc in ordersSnapshot.docs) {
          final orderData = orderDoc.data();
          orderData['userId'] = userDoc.id;
          orderData['userName'] = userDoc.data()['name'] ?? 'Unknown User';
          orderData['userEmail'] = userDoc.data()['email'] ?? 'No Email';
          _allOrders.add(orderData);
        }
      }

      // Sort all orders by createdAt descending
      _allOrders.sort((a, b) {
        final aTime = a['createdAt'] as Timestamp?;
        final bTime = b['createdAt'] as Timestamp?;
        if (aTime == null || bTime == null) return 0;
        return bTime.compareTo(aTime);
      });

      emit(AdminOrdersLoadedState(_allOrders));
    } catch (e) {
      emit(AdminOrdersErrorState(e.toString()));
    }
  }

  Future<void> _onUpdateOrderStatus(
    UpdateOrderStatusEvent event,
    Emitter<AdminOrdersState> emit,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(event.userId)
          .collection('orders')
          .doc(event.orderId)
          .update({
            'status': event.newStatus,
            'updatedAt': FieldValue.serverTimestamp(),
          });

      // Reload orders after update
      add(LoadAllOrdersEvent());
    } catch (e) {
      emit(AdminOrdersErrorState('Failed to update order: $e'));
    }
  }

  void _onSearchOrders(
    SearchOrdersEvent event,
    Emitter<AdminOrdersState> emit,
  ) {
    final filtered =
        _allOrders.where((order) {
          final productName =
              (order['productName'] as String? ?? '').toLowerCase();
          final userName = (order['userName'] as String? ?? '').toLowerCase();
          final orderId = (order['id'] as String? ?? '').toLowerCase();
          final query = event.query.toLowerCase();

          return productName.contains(query) ||
              userName.contains(query) ||
              orderId.contains(query);
        }).toList();

    emit(AdminOrdersLoadedState(filtered));
  }

  void _onFilterOrdersByStatus(
    FilterOrdersByStatusEvent event,
    Emitter<AdminOrdersState> emit,
  ) {
    if (event.status.isEmpty || event.status == 'all') {
      emit(AdminOrdersLoadedState(_allOrders));
      return;
    }

    final filtered =
        _allOrders.where((order) {
          return (order['status'] as String).toLowerCase() ==
              event.status.toLowerCase();
        }).toList();

    emit(AdminOrdersLoadedState(filtered));
  }
}
