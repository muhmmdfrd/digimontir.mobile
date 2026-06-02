import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../assignment/bloc/assignment_bloc.dart';
import '../../assignment/bloc/assignment_event.dart';
import '../../assignment/bloc/assignment_state.dart';
import '../../assignment/model/assignment_model.dart';
import 'assignment_detail_screen.dart';

class AssignmentListScreen extends StatefulWidget {
  const AssignmentListScreen({super.key});

  @override
  State<AssignmentListScreen> createState() => _AssignmentListScreenState();
}

class _AssignmentListScreenState extends State<AssignmentListScreen> {
  String? _selectedTab;

  void _onTabChanged(String? tab) {
    setState(() {
      _selectedTab = tab;
    });
    context.read<AssignmentBloc>().add(AssignmentLoadRequested(tab: tab));
  }

  Widget _buildFilterTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildChip('Semua', null),
          const SizedBox(width: 8),
          _buildChip('Hari Ini', 'today'),
          const SizedBox(width: 8),
          _buildChip('Akan Datang', 'upcoming'),
          const SizedBox(width: 8),
          _buildChip('Selesai', 'past'),
        ],
      ),
    );
  }

  Widget _buildChip(String label, String? value) {
    final isSelected = _selectedTab == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => _onTabChanged(value),
      selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.primaryColor : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Semua Pekerjaan',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: AppTheme.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          _buildFilterTabs(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                context.read<AssignmentBloc>().add(
                  AssignmentRefreshRequested(tab: _selectedTab),
                );
                await Future.delayed(const Duration(milliseconds: 600));
              },
              child: BlocBuilder<AssignmentBloc, AssignmentState>(
                builder: (context, state) {
                  if (state is AssignmentLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is AssignmentError) {
                    // Scrollable agar RefreshIndicator tetap bisa di-trigger saat error
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
                                  const Icon(
                                    Icons.wifi_off_rounded,
                                    size: 56,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Gagal memuat data',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    'Tarik ke bawah untuk mencoba lagi',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                  if (state is AssignmentLoaded) {
                    if (state.assignments.isEmpty) {
                      return ListView(
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.75,
                            child: const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.assignment_outlined,
                                    size: 64,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    'Belum ada pekerjaan',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.assignments.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) =>
                          _AssignmentCard(assignment: state.assignments[i]),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AssignmentCard extends StatelessWidget {
  final Assignment assignment;

  const _AssignmentCard({required this.assignment});

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

  IconData get _statusIcon {
    switch (assignment.statusName) {
      case 'assigned':
        return Icons.assignment_ind_outlined;
      case 'in_progress':
      case 'in progress':
        return Icons.autorenew;
      case 'completed':
        return Icons.check_circle_outline;
      case 'closed':
        return Icons.lock_outline;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        final assignmentBloc = context.read<AssignmentBloc>();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BlocProvider.value(
              value: assignmentBloc,
              child: AssignmentDetailScreen(assignment: assignment),
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: customer name + status chip
              Row(
                children: [
                  Expanded(
                    child: Text(
                      assignment.customer?.name ??
                          'Customer #${assignment.customerId}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_statusIcon, size: 12, color: _statusColor),
                        const SizedBox(width: 4),
                        Text(
                          assignment.status?.name ?? '-',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Deskripsi
              Text(
                assignment.descriptionByAdmin ?? "",
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, color: Color(0xFF5F6368)),
              ),
              const SizedBox(height: 10),
              const Divider(height: 1),
              const SizedBox(height: 10),

              // Footer info
              Row(
                children: [
                  Icon(
                    assignment.scheduledDate == null
                        ? Icons.person_outline
                        : Icons.event_outlined,
                    size: 14,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      assignment.scheduledDate == null
                          ? (assignment.technician?.name ??
                                'Teknisi #${assignment.technicianId}')
                          : 'Jadwal ${_formatDate(assignment.scheduledDate!)}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                  if (assignment.rating != null) ...[
                    const Icon(Icons.star, size: 14, color: Color(0xFFF9AB00)),
                    const SizedBox(width: 2),
                    Text(
                      '${assignment.rating}/5',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                  if (assignment.completedAt != null) ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.check, size: 14, color: Color(0xFF34A853)),
                    const SizedBox(width: 2),
                    Text(
                      _formatDate(assignment.completedAt!),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF34A853),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String raw) {
    try {
      final dt = DateTime.parse(raw).toLocal();
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return raw;
    }
  }
}
