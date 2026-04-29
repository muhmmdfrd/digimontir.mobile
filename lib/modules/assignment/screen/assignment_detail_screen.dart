import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/di/injection.dart';
import '../../../core/theme/app_theme.dart';
import '../bloc/assignment_bloc.dart';
import '../bloc/assignment_event.dart';
import '../model/assignment_model.dart';
import '../service/assignment_service.dart';

class AssignmentDetailScreen extends StatefulWidget {
  final Assignment assignment;

  const AssignmentDetailScreen({super.key, required this.assignment});

  @override
  State<AssignmentDetailScreen> createState() => _AssignmentDetailScreenState();
}

class _AssignmentDetailScreenState extends State<AssignmentDetailScreen> {
  bool _isLoading = false;
  late Assignment _assignment;

  @override
  void initState() {
    super.initState();
    _assignment = widget.assignment;
  }

  Future<Position?> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Layanan lokasi tidak aktif, harap aktifkan GPS.')));
      }
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Izin lokasi ditolak, fitur ini butuh akses lokasi.')));
        }
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Izin lokasi ditolak secara permanen di setting.')));
      }
      return null;
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<void> _handleCheckIn() async {
    setState(() => _isLoading = true);
    try {
      final position = await _determinePosition();
      if (position == null) return;

      final picker = ImagePicker();
      final photo = await picker.pickImage(source: ImageSource.camera, imageQuality: 70);
      if (photo == null) return;

      final updated = await sl<AssignmentService>().checkIn(
        _assignment.id,
        position.latitude,
        position.longitude,
        photo.path,
      );

      setState(() => _assignment = updated);
      if (mounted) {
        context.read<AssignmentBloc>().add(const AssignmentRefreshRequested());
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Berhasil Check-In! Pekerjaan dimulai.')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Check-in Gagal: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleCheckOut() async {
    final TextEditingController descController = TextEditingController();
    final bool? proceed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Selesaikan Pekerjaan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Masukkan deskripsi pekerjaan teknisi:'),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                maxLines: 3,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Cth: Kampas rem sudah diganti dan oli sudah ditambah...',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () {
                if (descController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Deskripsi wajib diisi')));
                  return;
                }
                Navigator.pop(ctx, true);
              },
              child: const Text('Lanjut Foto'),
            ),
          ],
        );
      },
    );

    if (proceed != true) return;

    setState(() => _isLoading = true);
    try {
      final position = await _determinePosition();
      if (position == null) return;

      final picker = ImagePicker();
      final photo = await picker.pickImage(source: ImageSource.camera, imageQuality: 70);
      if (photo == null) return;

      final updated = await sl<AssignmentService>().checkOut(
        _assignment.id,
        position.latitude,
        position.longitude,
        descController.text.trim(),
        photo.path,
      );

      setState(() => _assignment = updated);
      if (mounted) {
        context.read<AssignmentBloc>().add(const AssignmentRefreshRequested());
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Berhasil Check-Out! Pekerjaan selesai.')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Check-out Gagal: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isCompleted = _assignment.statusName == 'completed' || _assignment.statusName == 'closed';
    final bool canStartWork = _assignment.statusName == 'assigned';
    final bool canCompleteWork = _assignment.statusName == 'in_progress' || _assignment.statusName == 'in progress';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pekerjaan', style: TextStyle(color: Colors.white)),
        backgroundColor: AppTheme.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildInfoCard(),
                const SizedBox(height: 24),
                if (isCompleted) ...[
                  const Center(
                    child: Text(
                      'Pekerjaan ini sudah selesai (View Only)',
                      style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                    ),
                  ),
                ] else if (canStartWork) ...[
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _handleCheckIn,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Mulai Pekerjaan (Check In)'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ] else if (canCompleteWork) ...[
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _handleCheckOut,
                    icon: const Icon(Icons.check),
                    label: const Text('Selesaikan Pekerjaan (Check Out)'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withValues(alpha: .3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pelanggan: ${_assignment.customer?.name ?? '-'}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text('Status: ${_assignment.status?.name ?? '-'}'),
            const SizedBox(height: 8),
            Text('Deskripsi: ${_assignment.descriptionByAdmin ?? '-'}'),
            if (_assignment.descriptionByTechnician != null) ...[
              const SizedBox(height: 8),
              Text('Catatan Teknisi: ${_assignment.descriptionByTechnician}'),
            ],
          ],
        ),
      ),
    );
  }
}
