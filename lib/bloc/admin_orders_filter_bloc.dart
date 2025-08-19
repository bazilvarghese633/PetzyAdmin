import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// Events
abstract class AdminOrdersFilterEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class UpdateFilterEvent extends AdminOrdersFilterEvent {
  final String filter;

  UpdateFilterEvent(this.filter);

  @override
  List<Object?> get props => [filter];
}

class UpdateSearchQueryEvent extends AdminOrdersFilterEvent {
  final String query;

  UpdateSearchQueryEvent(this.query);

  @override
  List<Object?> get props => [query];
}

// States
abstract class AdminOrdersFilterState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AdminOrdersFilterInitial extends AdminOrdersFilterState {
  final String selectedFilter;
  final String searchQuery;

  AdminOrdersFilterInitial({
    this.selectedFilter = 'all',
    this.searchQuery = '',
  });

  @override
  List<Object?> get props => [selectedFilter, searchQuery];
}

// BLoC
class AdminOrdersFilterBloc
    extends Bloc<AdminOrdersFilterEvent, AdminOrdersFilterState> {
  AdminOrdersFilterBloc() : super(AdminOrdersFilterInitial()) {
    on<UpdateFilterEvent>(_onUpdateFilter);
    on<UpdateSearchQueryEvent>(_onUpdateSearchQuery);
  }

  void _onUpdateFilter(
    UpdateFilterEvent event,
    Emitter<AdminOrdersFilterState> emit,
  ) {
    final currentState = state as AdminOrdersFilterInitial;
    emit(
      AdminOrdersFilterInitial(
        selectedFilter: event.filter,
        searchQuery: currentState.searchQuery,
      ),
    );
  }

  void _onUpdateSearchQuery(
    UpdateSearchQueryEvent event,
    Emitter<AdminOrdersFilterState> emit,
  ) {
    final currentState = state as AdminOrdersFilterInitial;
    emit(
      AdminOrdersFilterInitial(
        selectedFilter: currentState.selectedFilter,
        searchQuery: event.query,
      ),
    );
  }
}
