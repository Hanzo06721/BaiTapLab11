import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/upload_item.dart';
import 'firebase_service.dart';

class StorageService extends ChangeNotifier {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  final List<UploadItem> _items = [];
  List<UploadItem> get items => List.unmodifiable(_items);

  void clearItems() {
    _items.clear();
    notifyListeners();
  }

  void addSampleItem(UploadItem item) {
    _items.add(item);
    notifyListeners();
  }

  // Upload file từ bytes hoặc file path
  Future<UploadItem> uploadFile({
    required String fileName,
    required Uint8List bytes,
    File? file,
  }) async {
    final itemId = 'upload-${DateTime.now().millisecondsSinceEpoch}-${_items.length}';
    final uploadItem = UploadItem(
      id: itemId,
      name: fileName,
      totalBytes: bytes.length,
      bytesTransferred: 0,
      progress: 0.0,
      status: UploadStatus.uploading,
    );

    _items.insert(0, uploadItem);
    notifyListeners();

    if (FirebaseService.isInitialized && FirebaseService.hasRealCredentials) {
      try {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('uploads/${DateTime.now().millisecondsSinceEpoch}_$fileName');

        SettableMetadata? metadata;
        if (fileName.endsWith('.jpg') || fileName.endsWith('.jpeg')) {
          metadata = SettableMetadata(contentType: 'image/jpeg');
        } else if (fileName.endsWith('.png')) {
          metadata = SettableMetadata(contentType: 'image/png');
        } else if (fileName.endsWith('.pdf')) {
          metadata = SettableMetadata(contentType: 'application/pdf');
        }

        final UploadTask task;
        if (file != null && !kIsWeb) {
          task = storageRef.putFile(file, metadata);
        } else {
          task = storageRef.putData(bytes, metadata);
        }

        uploadItem.uploadTask = task;

        uploadItem.subscription = task.snapshotEvents.listen(
          (TaskSnapshot snapshot) async {
            uploadItem.bytesTransferred = snapshot.bytesTransferred;
            uploadItem.progress = snapshot.totalBytes > 0
                ? snapshot.bytesTransferred / snapshot.totalBytes
                : 0.0;

            switch (snapshot.state) {
              case TaskState.running:
                uploadItem.status = UploadStatus.uploading;
                break;
              case TaskState.paused:
                uploadItem.status = UploadStatus.paused;
                break;
              case TaskState.success:
                uploadItem.status = UploadStatus.completed;
                uploadItem.progress = 1.0;
                uploadItem.downloadUrl = await storageRef.getDownloadURL();
                break;
              case TaskState.canceled:
                uploadItem.status = UploadStatus.canceled;
                break;
              case TaskState.error:
                uploadItem.status = UploadStatus.error;
                uploadItem.errorMessage = 'Upload error';
                break;
            }
            notifyListeners();
          },
          onError: (error) {
            uploadItem.status = UploadStatus.error;
            uploadItem.errorMessage = error.toString();
            notifyListeners();
          },
        );

        return uploadItem;
      } catch (e) {
        debugPrint("Firebase Storage putFile/putData error: $e");
        // Fallback to simulated upload
        _startSimulatedUpload(uploadItem, bytes.length);
        return uploadItem;
      }
    } else {
      _startSimulatedUpload(uploadItem, bytes.length);
      return uploadItem;
    }
  }

  // Mô phỏng tiến trình upload chân thực cho chế độ demo / offline
  void _startSimulatedUpload(UploadItem item, int total) {
    const step = 0.03; // ~3% per tick

    Timer.periodic(const Duration(milliseconds: 150), (t) {
      if (item.status == UploadStatus.paused) {
        return;
      }
      if (item.status == UploadStatus.canceled || item.status == UploadStatus.error) {
        t.cancel();
        return;
      }

      item.progress += step;
      if (item.progress >= 1.0) {
        item.progress = 1.0;
        item.bytesTransferred = total;
        item.status = UploadStatus.completed;
        item.downloadUrl = 'https://firebasestorage.googleapis.com/demo/${item.name}';
        t.cancel();
      } else {
        item.bytesTransferred = (item.progress * total).toInt();
      }
      notifyListeners();
    });
  }

  // Tạm dừng upload
  Future<void> pause(UploadItem item) async {
    if (item.uploadTask != null) {
      try {
        await item.uploadTask!.pause();
      } catch (_) {}
    }
    item.status = UploadStatus.paused;
    notifyListeners();
  }

  // Tiếp tục upload
  Future<void> resume(UploadItem item) async {
    if (item.uploadTask != null) {
      try {
        await item.uploadTask!.resume();
      } catch (_) {}
    }
    item.status = UploadStatus.uploading;
    notifyListeners();
  }

  // Hủy upload
  Future<void> cancel(UploadItem item) async {
    if (item.uploadTask != null) {
      try {
        await item.uploadTask!.cancel();
      } catch (_) {}
    }
    item.status = UploadStatus.canceled;
    await item.subscription?.cancel();
    notifyListeners();
  }

  // Xóa khỏi danh sách hiển thị
  void remove(UploadItem item) {
    cancel(item);
    _items.removeWhere((element) => element.id == item.id);
    notifyListeners();
  }
}
