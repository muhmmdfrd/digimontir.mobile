class DashboardStatistic {
  final int totalAssignments;
  final int completedAssignments;
  final int pendingAssignments;
  final double averageRating;
  final Map<String, int> statusBreakdown;

  const DashboardStatistic({
    required this.totalAssignments,
    required this.completedAssignments,
    required this.pendingAssignments,
    required this.averageRating,
    required this.statusBreakdown,
  });

  factory DashboardStatistic.fromJson(Map<String, dynamic> json) {
    return DashboardStatistic(
      totalAssignments: json['total_assignments'] as int? ?? 0,
      completedAssignments: json['completed_assignments'] as int? ?? 0,
      pendingAssignments: json['pending_assignments'] as int? ?? 0,
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
      statusBreakdown: (json['status_breakdown'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, v as int),
          ) ?? {},
    );
  }
}
