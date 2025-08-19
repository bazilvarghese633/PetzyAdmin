abstract class AdminOrdersState {}

class AdminOrdersLoadingState extends AdminOrdersState {}

class AdminOrdersLoadedState extends AdminOrdersState {
  final List<Map<String, dynamic>> orders;
  AdminOrdersLoadedState(this.orders);
}

class AdminOrdersErrorState extends AdminOrdersState {
  final String message;
  AdminOrdersErrorState(this.message);
}
