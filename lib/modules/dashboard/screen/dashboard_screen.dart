import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../assignment/bloc/assignment_bloc.dart';
import '../../assignment/bloc/assignment_event.dart';
import '../../assignment/bloc/assignment_state.dart';
import '../../assignment/model/assignment_model.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: AppTheme.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<AssignmentBloc>().add(const AssignmentRefreshRequested());
          await Future.delayed(const Duration(milliseconds: 600));
        },
        child: BlocBuilder<AssignmentBloc, AssignmentState>(
          builder: (context, state) {
            if (state is AssignmentLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is AssignmentError) {
              return ListView(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.75,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.wifi_off_rounded, size: 56, color: Colors.grey),
                            const SizedBox(height: 16),
                            const Text(
                              'Gagal memuat data',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 6),
                            const Text('Tarik ke bawah untuk mencoba lagi', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
            if (state is AssignmentLoaded) {
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildStatSection(state),
                  const SizedBox(height: 24),
                  _buildRecentSection(state.recentActivity),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildStatSection(AssignmentLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Statistik Pekerjaan',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.onSurfaceColor),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.4,
          children: [
            _StatCard(
              label: 'Di-assign',
              count: state.assignedCount,
              icon: Icons.assignment_ind_outlined,
              color: const Color(0xFF1A73E8),
              bgColor: const Color(0xFFE8F0FE),
            ),
            _StatCard(
              label: 'Proses',
              count: state.inProgressCount,
              icon: Icons.autorenew,
              color: const Color(0xFFF9AB00),
              bgColor: const Color(0xFFFEF8E1),
            ),
            _StatCard(
              label: 'Selesai',
              count: state.completedCount,
              icon: Icons.check_circle_outline,
              color: const Color(0xFF34A853),
              bgColor: const Color(0xFFE6F4EA),
            ),
            _StatCard(
              label: 'Closed',
              count: state.closedCount,
              icon: Icons.lock_outline,
              color: const Color(0xFF9AA0A6),
              bgColor: const Color(0xFFF1F3F4),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentSection(List<Assignment> recent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Aktivitas Terbaru',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.onSurfaceColor),
        ),
        const SizedBox(height: 12),
        if (recent.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text('Belum ada aktivitas', style: TextStyle(color: Colors.grey)),
            ),
          )
        else
          ...recent.map((a) => _RecentActivityCard(assignment: a)),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int count;
  final IconData icon;
  final Color color;
  final Color bgColor;

  const _StatCard({
    required this.label,
    required this.count,
    required this.icon,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$count',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color),
              ),
              Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecentActivityCard extends StatelessWidget {
  final Assignment assignment;

  const _RecentActivityCard({required this.assignment});

  Color get _statusColor {
    switch (assignment.statusName) {
      case 'assigned':
        return const Color(0xFF1A73E8);
      case 'in_progress':
      case 'in progress':
        return const Color(0xFFF9AB00);
      case 'completed':
        return const Color(0xFF34A853);
      case 'closed':
        return const Color(0xFF9AA0A6);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: _statusColor.withValues(alpha: 0.12),
          child: Icon(Icons.build_circle_outlined, color: _statusColor, size: 22),
        ),
        title: Text(
          assignment.customer?.name ?? 'Customer #${assignment.customerId}',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle: Text(
          assignment.descriptionByAdmin,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: _statusColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            assignment.status?.name ?? '-',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _statusColor),
          ),
        ),
      ),
    );
  }
}
