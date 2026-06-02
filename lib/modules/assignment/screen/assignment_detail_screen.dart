import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/config/app_config.dart';
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Layanan lokasi tidak aktif, harap aktifkan GPS.'),
          ),
        );
      }
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Izin lokasi ditolak, fitur ini butuh akses lokasi.',
              ),
            ),
          );
        }
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Izin lokasi ditolak secara permanen di setting.'),
          ),
        );
      }
      return null;
    }

    return await Geolocator.getCurrentPosition();
  }

  double? get _targetLatitude => _assignment.customer?.latitude;
  double? get _targetLongitude => _assignment.customer?.longitude;

  bool get _hasTargetLocation =>
      _targetLatitude != null && _targetLongitude != null;

  Future<bool> _validateWithinRadius(
    Position position,
    String actionLabel,
  ) async {
    if (!_hasTargetLocation) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Koordinat pelanggan belum tersedia untuk validasi lokasi.',
            ),
          ),
        );
      }
      return false;
    }

    final distance = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      _targetLatitude!,
      _targetLongitude!,
    );

    if (distance > AppConfig.assignmentCheckRadiusMeters) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Anda berada di luar radius ${AppConfig.assignmentCheckRadiusMeters.toStringAsFixed(0)}m '
              '(${distance.toStringAsFixed(1)}m). Silakan kembali ke lokasi pekerjaan untuk $actionLabel.',
            ),
          ),
        );
      }
      return false;
    }

    return true;
  }

  Future<XFile?> _pickSelfiePhoto() {
    return ImagePicker().pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
      maxWidth: AppConfig.assignmentPhotoMaxDimension,
      maxHeight: AppConfig.assignmentPhotoMaxDimension,
      imageQuality: AppConfig.assignmentPhotoQuality,
    );
  }

  Future<bool> _validatePhotoSize(XFile photo) async {
    final size = await photo.length();
    if (size <= AppConfig.assignmentPhotoMaxUploadBytes) return true;

    if (mounted) {
      final sizeMb = size / (1024 * 1024);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Ukuran selfie ${sizeMb.toStringAsFixed(1)} MB, maksimal 5 MB. Silakan ambil foto ulang.',
          ),
        ),
      );
    }
    return false;
  }

  Future<void> _handleCheckIn() async {
    setState(() => _isLoading = true);
    try {
      final position = await _determinePosition();
      if (position == null) return;

      final isWithinRadius = await _validateWithinRadius(position, 'check-in');
      if (!isWithinRadius) return;

      final photo = await _pickSelfiePhoto();
      if (photo == null) return;
      final isValidPhotoSize = await _validatePhotoSize(photo);
      if (!isValidPhotoSize) return;

      final updated = await sl<AssignmentService>().checkIn(
        _assignment.id,
        position.latitude,
        position.longitude,
        photo.path,
      );

      setState(() => _assignment = updated);
      if (mounted) {
        context.read<AssignmentBloc>().add(const AssignmentRefreshRequested());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Berhasil Check-In! Pekerjaan dimulai.'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Check-in Gagal: $e')));
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
                  hintText:
                      'Cth: Kampas rem sudah diganti dan oli sudah ditambah...',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (descController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text('Deskripsi wajib diisi')),
                  );
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

      final isWithinRadius = await _validateWithinRadius(position, 'check-out');
      if (!isWithinRadius) return;

      final photo = await _pickSelfiePhoto();
      if (photo == null) return;
      final isValidPhotoSize = await _validatePhotoSize(photo);
      if (!isValidPhotoSize) return;

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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Berhasil Check-Out! Pekerjaan selesai.'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Check-out Gagal: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasCheckedIn =
        _assignment.latCheckIn != null ||
        _assignment.lngCheckIn != null ||
        _assignment.checkInPhotoPath != null;
    final bool hasCheckedOut =
        _assignment.completedAt != null ||
        _assignment.latCheckOut != null ||
        _assignment.lngCheckOut != null ||
        _assignment.checkOutPhotoPath != null;
    final bool isCompleted =
        _assignment.statusName == 'completed' ||
        _assignment.statusName == 'closed' ||
        _assignment.statusCode == 'WREV' ||
        hasCheckedOut;
    final bool canStartWork =
        !hasCheckedIn &&
        (_assignment.statusName == 'assigned' ||
            _assignment.statusCode == 'ASGN');
    final bool canCompleteWork =
        !hasCheckedOut &&
        (hasCheckedIn ||
            _assignment.statusName == 'in_progress' ||
            _assignment.statusName == 'in progress' ||
            _assignment.statusCode == 'CKIN');

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detail Pekerjaan',
          style: TextStyle(color: Colors.white),
        ),
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
                const SizedBox(height: 16),
                if (_hasTargetLocation)
                  _buildMap(_targetLatitude!, _targetLongitude!)
                else
                  _buildMissingLocationCard(),
                if (_assignment.checkInPhotoPath != null ||
                    _assignment.checkOutPhotoPath != null) ...[
                  const SizedBox(height: 16),
                  _buildPhotoPreviewSection(),
                ],
                const SizedBox(height: 24),
                if (isCompleted) ...[
                  const Center(
                    child: Text(
                      'Pekerjaan ini sudah selesai (View Only)',
                      style: TextStyle(
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
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

  Widget _buildMap(double lat, double lng) {
    final targetPoint = LatLng(lat, lng);
    final checkInPoint =
        _assignment.latCheckIn != null && _assignment.lngCheckIn != null
        ? LatLng(_assignment.latCheckIn!, _assignment.lngCheckIn!)
        : null;
    final checkOutPoint =
        _assignment.latCheckOut != null && _assignment.lngCheckOut != null
        ? LatLng(_assignment.latCheckOut!, _assignment.lngCheckOut!)
        : null;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Lokasi Pekerjaan',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                Text(
                  'Radius ${AppConfig.assignmentCheckRadiusMeters.toStringAsFixed(0)}m',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 250,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(12),
              ),
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: targetPoint,
                  initialZoom: 17.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.digimontir.mobile',
                  ),
                  CircleLayer(
                    circles: [
                      CircleMarker(
                        point: targetPoint,
                        color: Colors.blue.withValues(alpha: 0.2),
                        borderColor: Colors.blue,
                        borderStrokeWidth: 1.5,
                        useRadiusInMeter: true,
                        radius: AppConfig.assignmentCheckRadiusMeters,
                      ),
                    ],
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: targetPoint,
                        width: 40,
                        height: 40,
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                      if (checkInPoint != null)
                        Marker(
                          point: checkInPoint,
                          width: 34,
                          height: 34,
                          child: const Icon(
                            Icons.login,
                            color: AppTheme.primaryColor,
                            size: 30,
                          ),
                        ),
                      if (checkOutPoint != null)
                        Marker(
                          point: checkOutPoint,
                          width: 34,
                          height: 34,
                          child: const Icon(
                            Icons.logout,
                            color: Colors.green,
                            size: 30,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissingLocationCard() {
    return Card(
      color: Colors.orange.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.location_off_outlined, color: Colors.orange),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Koordinat pelanggan belum tersedia. Check-in/check-out membutuhkan lokasi valid.',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoPreviewSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Foto Pekerjaan',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 520;
                final photos = [
                  if (_assignment.checkInPhotoPath != null)
                    _PhotoPreviewData(
                      title: 'Foto Check-in',
                      path: _assignment.checkInPhotoPath!,
                      color: AppTheme.primaryColor,
                    ),
                  if (_assignment.checkOutPhotoPath != null)
                    _PhotoPreviewData(
                      title: 'Foto Check-out',
                      path: _assignment.checkOutPhotoPath!,
                      color: Colors.green,
                    ),
                ];

                if (isWide && photos.length > 1) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final photo in photos) ...[
                        Expanded(child: _buildPhotoPreview(photo)),
                        if (photo != photos.last) const SizedBox(width: 12),
                      ],
                    ],
                  );
                }

                return Column(
                  children: [
                    for (final photo in photos) ...[
                      _buildPhotoPreview(photo),
                      if (photo != photos.last) const SizedBox(height: 12),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoPreview(_PhotoPreviewData photo) {
    final imageUrl = _buildStorageImageUrl(photo.path);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(Icons.photo_camera_outlined, color: photo.color, size: 18),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                photo.title,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: AspectRatio(
            aspectRatio: 4 / 3,
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: Colors.grey.shade100,
                  child: const Center(child: CircularProgressIndicator()),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey.shade100,
                  padding: const EdgeInsets.all(16),
                  child: const Center(
                    child: Text(
                      'Foto belum bisa dimuat',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  String _buildStorageImageUrl(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }

    final apiUri = Uri.parse(AppConfig.baseUrl);
    final origin =
        '${apiUri.scheme}://${apiUri.host}${apiUri.hasPort ? ':${apiUri.port}' : ''}';
    final cleanPath = path.replaceFirst(RegExp(r'^/+'), '');

    if (cleanPath.startsWith('storage/')) {
      return '$origin/$cleanPath';
    }

    return '$origin/storage/$cleanPath';
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
            if (_assignment.scheduledDate != null) ...[
              const SizedBox(height: 8),
              Text(
                'Tanggal Jadwal: ${_formatDate(_assignment.scheduledDate!)}',
              ),
            ],
            const SizedBox(height: 8),
            Text('Alamat: ${_assignment.customer?.address ?? '-'}'),
            const SizedBox(height: 8),
            Text('Deskripsi: ${_assignment.descriptionByAdmin ?? '-'}'),
            if (_assignment.latCheckIn != null &&
                _assignment.lngCheckIn != null) ...[
              const SizedBox(height: 8),
              Text(
                'Check-in: ${_assignment.latCheckIn!.toStringAsFixed(6)}, '
                '${_assignment.lngCheckIn!.toStringAsFixed(6)}',
              ),
            ],
            if (_assignment.latCheckOut != null &&
                _assignment.lngCheckOut != null) ...[
              const SizedBox(height: 8),
              Text(
                'Check-out: ${_assignment.latCheckOut!.toStringAsFixed(6)}, '
                '${_assignment.lngCheckOut!.toStringAsFixed(6)}',
              ),
            ],
            if (_assignment.descriptionByTechnician != null) ...[
              const SizedBox(height: 8),
              Text('Catatan Teknisi: ${_assignment.descriptionByTechnician}'),
            ],
          ],
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

class _PhotoPreviewData {
  final String title;
  final String path;
  final Color color;

  const _PhotoPreviewData({
    required this.title,
    required this.path,
    required this.color,
  });
}
