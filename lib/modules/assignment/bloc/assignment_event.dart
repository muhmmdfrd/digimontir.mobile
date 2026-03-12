import 'package:equatable/equatable.dart';

abstract class AssignmentEvent extends Equatable {
  const AssignmentEvent();
  @override
  List<Object?> get props => [];
}

class AssignmentLoadRequested extends AssignmentEvent {
  const AssignmentLoadRequested();
}

class AssignmentRefreshRequested extends AssignmentEvent {
  const AssignmentRefreshRequested();
}
