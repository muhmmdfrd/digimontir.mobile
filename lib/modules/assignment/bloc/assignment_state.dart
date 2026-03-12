import 'package:equatable/equatable.dart';
import '../model/assignment_model.dart';

abstract class AssignmentState extends Equatable {
  const AssignmentState();
  @override
  List<Object?> get props => [];
}

class AssignmentInitial extends AssignmentState {
  const AssignmentInitial();
}

class AssignmentLoading extends AssignmentState {
  const AssignmentLoading();
}

class AssignmentLoaded extends AssignmentState {
  final List<Assignment> assignments;
  const AssignmentLoaded(this.assignments);

  @override
  List<Object?> get props => [assignments];

  int get assignedCount =>
      assignments.where((a) => a.statusName == 'assigned').length;
  int get inProgressCount =>
      assignments.where((a) => a.statusName == 'in_progress' || a.statusName == 'in progress').length;
  int get completedCount =>
      assignments.where((a) => a.statusName == 'completed').length;
  int get closedCount =>
      assignments.where((a) => a.statusName == 'closed').length;

  List<Assignment> get recentActivity {
    final sorted = [...assignments]..sort((a, b) => b.id.compareTo(a.id));
    return sorted.take(5).toList();
  }
}

class AssignmentError extends AssignmentState {
  final String message;
  const AssignmentError(this.message);
  @override
  List<Object?> get props => [message];
}
