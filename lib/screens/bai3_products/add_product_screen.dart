import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../models/product.dart';
import '../../services/firestore_service.dart';
import '../../services/storage_service.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descController = TextEditingController();

  Uint8List? _selectedImageBytes;
  String? _selectedImageName;
  File? _selectedImageFile;
  String _selectedPresetUrl = 'https://images.unsplash.com/photo-1485965120184-e220f721d03e?w=500';
  bool _isLoading = false;

  final List<String> _presetBikeImages = [
    'https://images.unsplash.com/photo-1485965120184-e220f721d03e?w=500',
    'https://images.unsplash.com/photo-1576435728678-68d0fbf94e91?w=500',
    'https://images.unsplash.com/photo-1532298229144-0ec0c57515c7?w=500',
    'https://images.unsplash.com/photo-1507035895480-2b3156c31fc8?w=500',
    'https://images.unsplash.com/photo-1511994298241-608e28f14fde?w=500',
    'https://images.unsplash.com/photo-1571068316344-75bc76f77890?w=500',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final platformFile = result.files.first;
        setState(() {
          _selectedImageName = platformFile.name;
          _selectedImageBytes = platformFile.bytes;
          if (!kIsWeb && platformFile.path != null) {
            _selectedImageFile = File(platformFile.path!);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi chọn ảnh: $e')),
        );
      }
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      String finalImageUrl = _selectedPresetUrl;

      // Nếu người dùng chọn ảnh từ thiết bị -> Upload lên Firebase Storage
      if (_selectedImageBytes != null && _selectedImageName != null) {
        final uploadItem = await StorageService().uploadFile(
          fileName: _selectedImageName!,
          bytes: _selectedImageBytes!,
          file: _selectedImageFile,
        );
        finalImageUrl = uploadItem.downloadUrl ?? _selectedPresetUrl;
      }

      final newProduct = Product(
        id: 'bike-${DateTime.now().millisecondsSinceEpoch}',
        name: _nameController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        imageUrl: finalImageUrl,
        description: _descController.text.trim(),
        createdAt: DateTime.now(),
      );

      await FirestoreService().addProduct(newProduct);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã thêm sản phẩm thành công vào Firestore & Storage!')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi thêm sản phẩm: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const brandPurple = Color(0xFF7E22CE);
    const lightPurple = Color(0xFF9333EA);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Thêm sản phẩm mới'),
        backgroundColor: lightPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Chọn ảnh sản phẩm
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Hình ảnh xe đạp (Firebase Storage)',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Xem trước ảnh
                    Center(
                      child: Container(
                        width: 160,
                        height: 120,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3E8FF),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: brandPurple.withOpacity(0.3)),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: _selectedImageBytes != null
                              ? Image.memory(_selectedImageBytes!, fit: BoxFit.cover)
                              : Image.network(
                                  _selectedPresetUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (ctx, err, stack) => const Icon(
                                    Icons.directions_bike,
                                    size: 50,
                                    color: brandPurple,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        OutlinedButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.upload_file, size: 18),
                          label: const Text('Tải ảnh từ máy'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: brandPurple,
                            side: const BorderSide(color: brandPurple),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Hoặc chọn nhanh từ preset
                    const Text(
                      'Hoặc chọn nhanh ảnh mẫu có sẵn:',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 50,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _presetBikeImages.length,
                        separatorBuilder: (_, index) => const SizedBox(width: 8),
                        itemBuilder: (context, i) {
                          final url = _presetBikeImages[i];
                          final isSelected = _selectedPresetUrl == url && _selectedImageBytes == null;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedPresetUrl = url;
                                _selectedImageBytes = null;
                                _selectedImageName = null;
                              });
                            },
                            child: Container(
                              width: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected ? brandPurple : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Image.network(url, fit: BoxFit.cover),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Thông tin sản phẩm
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Thông tin chi tiết (Firestore)',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Tên xe đạp
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Tên sản phẩm *',
                        hintText: 'Ví dụ: Trek Slash 9.8, Stumpjumper...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập tên sản phẩm';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    // Giá sản phẩm
                    TextFormField(
                      controller: _priceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Giá sản phẩm (USD) *',
                        hintText: 'Ví dụ: 4999.00',
                        prefixText: '\$ ',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập giá sản phẩm';
                        }
                        if (double.tryParse(value.trim()) == null) {
                          return 'Giá phải là số hợp lệ';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    // Mô tả
                    TextFormField(
                      controller: _descController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Mô tả tóm tắt',
                        hintText: 'Thông số khung, dòng xe địa hình, xuất xứ...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Nút Submit
              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _saveProduct,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.cloud_upload_outlined, color: Colors.white),
                  label: Text(
                    _isLoading ? 'Đang lưu vào Firestore...' : 'Lưu sản phẩm',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: lightPurple,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
