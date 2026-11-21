import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../models/upload_item.dart';
import '../../services/storage_service.dart';

class FileUploadScreen extends StatefulWidget {
  const FileUploadScreen({super.key});

  @override
  State<FileUploadScreen> createState() => _FileUploadScreenState();
}

class _FileUploadScreenState extends State<FileUploadScreen> {
  final StorageService _storageService = StorageService();

  @override
  void initState() {
    super.initState();
    _storageService.addListener(_onStorageUpdate);
  }

  @override
  void dispose() {
    _storageService.removeListener(_onStorageUpdate);
    super.dispose();
  }

  void _onStorageUpdate() {
    if (mounted) setState(() {});
  }

  // Chọn file từ máy để upload
  Future<void> _pickAndUploadFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        for (final platformFile in result.files) {
          final fileName = platformFile.name;
          final Uint8List? bytes = platformFile.bytes;
          File? file;
          if (!kIsWeb && platformFile.path != null) {
            file = File(platformFile.path!);
          }

          final uploadBytes = bytes ?? (file != null ? await file.readAsBytes() : Uint8List(1024 * 500));

          await _storageService.uploadFile(
            fileName: fileName,
            bytes: uploadBytes,
            file: file,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi chọn file: $e')),
        );
      }
    }
  }

  // Nạp 3 file mẫu theo đúng đề bài minh họa (Dribbble.aep, Homepage.psd, Outline icon.ai)
  void _loadSampleLabFiles() {
    _storageService.clearItems();

    // 1. Dribbble.aep (đã hoàn thành)
    final item1 = UploadItem(
      id: 'sample-1',
      name: 'Dribbble.aep',
      totalBytes: 234 * 1024,
      bytesTransferred: 234 * 1024,
      progress: 1.0,
      status: UploadStatus.completed,
    );
    _storageService.addSampleItem(item1);

    // 2. Homepage.psd (đang tạm dừng / play)
    final item2 = UploadItem(
      id: 'sample-2',
      name: 'Homepage.psd',
      totalBytes: 23 * 1024 * 1024,
      bytesTransferred: (23 * 1024 * 1024 * 0.45).toInt(),
      progress: 0.45,
      status: UploadStatus.paused,
    );
    _storageService.addSampleItem(item2);

    // 3. Outline icon.ai (đang upload / có thể pause)
    _storageService.uploadFile(
      fileName: 'Outline icon.ai',
      bytes: Uint8List((1.2 * 1024 * 1024).toInt()),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF38B6FF);
    final items = _storageService.items;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: primaryBlue, size: 24),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Upload',
          style: TextStyle(
            color: Color(0xFF64748B),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              if (items.isNotEmpty) {
                _storageService.clearItems();
              } else {
                _loadSampleLabFiles();
              }
            },
            child: Text(
              items.isNotEmpty ? 'Clear' : 'Edit',
              style: const TextStyle(
                color: primaryBlue,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: items.isEmpty
                  ? _buildEmptyState(primaryBlue)
                  : _buildUploadList(items, primaryBlue),
            ),

            // Nút "Choose File" dưới cùng theo đúng thiết kế
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _pickAndUploadFile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Choose File',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Màn hình rỗng khi chưa có file (Hình đám mây Upload như mẫu trong PDF)
  Widget _buildEmptyState(Color primaryBlue) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Cloud upload illustration
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primaryBlue.withOpacity(0.12),
            ),
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Lớp nền hiệu ứng các tệp bay lên
                  Positioned(
                    top: 25,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Transform.rotate(
                          angle: -0.2,
                          child: Container(
                            width: 24,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.pink.shade200,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Transform.rotate(
                          angle: 0.2,
                          child: Container(
                            width: 24,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.amber.shade200,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Đám mây tròn với mũi tên lên
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: primaryBlue,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: primaryBlue.withOpacity(0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_upward_rounded,
                      color: Colors.white,
                      size: 38,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'Chưa có tệp nào được tải lên',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Nhấn nút bên dưới để chọn file từ máy',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _loadSampleLabFiles,
            icon: const Icon(Icons.playlist_add, size: 18),
            label: const Text('Nạp 3 file mẫu đề bài'),
            style: OutlinedButton.styleFrom(
              foregroundColor: primaryBlue,
              side: BorderSide(color: primaryBlue.withOpacity(0.5)),
            ),
          ),
        ],
      ),
    );
  }

  // Danh sách các file upload theo đúng hình chụp Bài tập 2 (AE, PS, AI)
  Widget _buildUploadList(List<UploadItem> items, Color primaryBlue) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      itemCount: items.length,
      separatorBuilder: (_, index) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildUploadCard(item, primaryBlue);
      },
    );
  }

  Widget _buildUploadCard(UploadItem item, Color primaryBlue) {
    final (badgeColor, badgeText) = _getFileBadgeInfo(item.name);
    final percent = (item.progress * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Badge icon định dạng file (AE, PS, AI, PDF, etc.)
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  badgeText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Tên file và kích thước
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item.formattedSize} • $percent%',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),

              // Nút hành động theo trạng thái (Checkmark, Play/Resume, Pause)
              _buildActionControl(item, primaryBlue),
            ],
          ),

          // Thanh tiến trình tải lên (Progress bar)
          if (item.status != UploadStatus.completed) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: item.progress,
                minHeight: 4,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  item.status == UploadStatus.paused
                      ? Colors.amber
                      : (item.status == UploadStatus.error
                          ? Colors.redAccent
                          : primaryBlue),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionControl(UploadItem item, Color primaryBlue) {
    if (item.status == UploadStatus.completed) {
      // Dấu tick xanh lá hoàn thành
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.check,
          color: Color(0xFF10B981),
          size: 20,
        ),
      );
    } else if (item.status == UploadStatus.uploading) {
      // Nút Pause (||)
      return IconButton(
        icon: const Icon(Icons.pause, color: Color(0xFF64748B), size: 22),
        tooltip: 'Tạm dừng',
        onPressed: () => _storageService.pause(item),
      );
    } else if (item.status == UploadStatus.paused) {
      // Nút Play / Resume (▶) màu vàng cam như trong ảnh đề bài
      return IconButton(
        icon: const Icon(Icons.play_arrow, color: Color(0xFFF59E0B), size: 22),
        tooltip: 'Tiếp tục tải',
        onPressed: () => _storageService.resume(item),
      );
    } else {
      // Canceled or Error
      return IconButton(
        icon: const Icon(Icons.refresh, color: Colors.redAccent, size: 20),
        tooltip: 'Thử lại',
        onPressed: () => _storageService.resume(item),
      );
    }
  }

  (Color, String) _getFileBadgeInfo(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    switch (ext) {
      case 'aep':
        return (const Color(0xFF8B5CF6), 'AE'); // After Effects tím
      case 'psd':
        return (const Color(0xFF3B82F6), 'PS'); // Photoshop xanh dương
      case 'ai':
        return (const Color(0xFFF97316), 'AI'); // Illustrator cam
      case 'pdf':
        return (const Color(0xFFEF4444), 'PDF');
      case 'jpg':
      case 'jpeg':
      case 'png':
        return (const Color(0xFF10B981), 'IMG');
      default:
        return (const Color(0xFF64748B), ext.toUpperCase().take(3));
    }
  }
}

extension on String {
  String take(int n) {
    return length > n ? substring(0, n) : this;
  }
}
