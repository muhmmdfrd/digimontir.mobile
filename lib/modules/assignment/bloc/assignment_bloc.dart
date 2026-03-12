import 'package:flutter_bloc/flutter_bloc.dart';
import 'assignment_event.dart';
import 'assignment_state.dart';
import '../service/assignment_service.dart';

class AssignmentBloc extends Bloc<AssignmentEvent, AssignmentState> {
  final AssignmentService _service;

  AssignmentBloc({required AssignmentService service})
      : _service = service,
        super(const AssignmentInitial()) {
    on<AssignmentLoadRequested>(_onLoad);
    on<AssignmentRefreshRequested>(_onLoad);
  }

  Future<void> _onLoad(
    AssignmentEvent event,
    Emitter<AssignmentState> emit,
  ) async {
    emit(const AssignmentLoading());
    try {
      final assignments = await _service.getAssignments();
      emit(AssignmentLoaded(assignments));
    } catch (e) {
      emit(AssignmentError(e.toString()));
    }
  }
}
