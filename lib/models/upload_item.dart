import 'dart:async';
import 'package:firebase_storage/firebase_storage.dart';

enum UploadStatus {
  uploading,
  paused,
  completed,
  canceled,
  error,
}

class UploadItem {
  final String id;
  final String name;
  final int totalBytes;
  int bytesTransferred;
  double progress; // 0.0 to 1.0
  UploadStatus status;
  String? downloadUrl;
  String? errorMessage;
  UploadTask? uploadTask;
  StreamSubscription<TaskSnapshot>? subscription;

  UploadItem({
    required this.id,
    required this.name,
    required this.totalBytes,
    this.bytesTransferred = 0,
    this.progress = 0.0,
    this.status = UploadStatus.uploading,
    this.downloadUrl,
    this.errorMessage,
    this.uploadTask,
    this.subscription,
  });

  String get formattedSize {
    if (totalBytes < 1024) {
      return '$totalBytes B';
    } else if (totalBytes < 1024 * 1024) {
      return '${(totalBytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(totalBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  String get fileExtension {
    final dotIndex = name.lastIndexOf('.');
    if (dotIndex != -1 && dotIndex < name.length - 1) {
      return name.substring(dotIndex + 1).toUpperCase();
    }
    return 'FILE';
  }
}
