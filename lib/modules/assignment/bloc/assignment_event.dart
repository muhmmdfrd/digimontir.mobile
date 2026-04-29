import 'package:equatable/equatable.dart';

abstract class AssignmentEvent extends Equatable {
  const AssignmentEvent();
  @override
  List<Object?> get props => [];
}

class AssignmentLoadRequested extends AssignmentEvent {
  final String? tab;
  const AssignmentLoadRequested({this.tab});
  @override
  List<Object?> get props => [tab];
}

class AssignmentRefreshRequested extends AssignmentEvent {
  final String? tab;
  const AssignmentRefreshRequested({this.tab});
  @override
  List<Object?> get props => [tab];
}
