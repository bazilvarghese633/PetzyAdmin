// dashboard_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';

/// Events
abstract class DashboardEvent {}

class DashboardTabChanged extends DashboardEvent {
  final int index;
  DashboardTabChanged(this.index);
}

/// State
class DashboardState {
  final int selectedIndex;
  final bool isLoading;

  DashboardState({required this.selectedIndex, this.isLoading = false});

  DashboardState copyWith({int? selectedIndex, bool? isLoading}) {
    return DashboardState(
      selectedIndex: selectedIndex ?? this.selectedIndex,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Bloc
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc() : super(DashboardState(selectedIndex: 0)) {
    on<DashboardTabChanged>(_onTabChanged);
  }

  Future<void> _onTabChanged(
    DashboardTabChanged event,
    Emitter<DashboardState> emit,
  ) async {
    emit(state.copyWith(isLoading: true)); // Show shimmer
    await Future.delayed(const Duration(milliseconds: 600)); // Simulated delay
    emit(state.copyWith(selectedIndex: event.index, isLoading: false));
  }
}
