abstract class AdminOrdersEvent {}

class LoadAllOrdersEvent extends AdminOrdersEvent {}

class UpdateOrderStatusEvent extends AdminOrdersEvent {
  final String userId;
  final String orderId;
  final String newStatus;

  UpdateOrderStatusEvent({
    required this.userId,
    required this.orderId,
    required this.newStatus,
  });
}

class SearchOrdersEvent extends AdminOrdersEvent {
  final String query;
  SearchOrdersEvent(this.query);
}

class FilterOrdersByStatusEvent extends AdminOrdersEvent {
  final String status;
  FilterOrdersByStatusEvent(this.status);
}
