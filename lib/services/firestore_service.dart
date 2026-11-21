import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';
import '../models/wallet_transaction.dart';
import 'firebase_service.dart';

class FirestoreService extends ChangeNotifier {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal() {
    _initSampleData();
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Local storage for demo / offline fallback
  final List<Product> _localProducts = [];
  final List<WalletTransaction> _localTransactions = [];
  double _walletBalance = 2108.22;
  int _walletPoints = 6350;

  double get walletBalance => _walletBalance;
  int get walletPoints => _walletPoints;

  void _initSampleData() {
    // 6 sản phẩm xe đạp chuẩn theo hình ảnh Bài tập 3 trong tài liệu thực hành
    _localProducts.addAll([
      Product(
        id: 'bike-1',
        name: 'Instinct',
        price: 6999.99,
        imageUrl: 'https://images.unsplash.com/photo-1485965120184-e220f721d03e?w=500',
        description: 'Rocky Mountain Instinct Carbon 70 - Dòng xe trail vượt địa hình cao cấp.',
        createdAt: DateTime.now().subtract(const Duration(days: 6)),
      ),
      Product(
        id: 'bike-2',
        name: 'Stumpjumper',
        price: 3178.99,
        imageUrl: 'https://images.unsplash.com/photo-1576435728678-68d0fbf94e91?w=500',
        description: 'Specialized Stumpjumper Alloy - Khung hợp kim nhẹ siêu bền.',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Product(
        id: 'bike-3',
        name: 'Trek Fuel',
        price: 4999.00,
        imageUrl: 'https://images.unsplash.com/photo-1532298229144-0ec0c57515c7?w=500',
        description: 'Trek Fuel EX Gen 6 - Thiết kế đa dụng thích ứng mọi cung đường leo núi.',
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
      ),
      Product(
        id: 'bike-4',
        name: 'Devinci Troy',
        price: 5599.00,
        imageUrl: 'https://images.unsplash.com/photo-1507035895480-2b3156c31fc8?w=500',
        description: 'Devinci Troy Carbon GX 12S - Xe đạp All-Mountain sản xuất tại Canada.',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      Product(
        id: 'bike-5',
        name: 'Slayer',
        price: 4699.99,
        imageUrl: 'https://images.unsplash.com/photo-1511994298241-608e28f14fde?w=500',
        description: 'Rocky Mountain Slayer 50 - Sẵn sàng cho mọi cuộc đua Enduro đổ dốc.',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Product(
        id: 'bike-6',
        name: 'Trek Slash 8',
        price: 6999.99,
        imageUrl: 'https://images.unsplash.com/photo-1571068316344-75bc76f77890?w=500',
        description: 'Trek Slash 8 Gen 6 - Cỗ máy Enduro hành trình dài đỉnh cao.',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ]);

    // Lịch sử giao dịch ví zhippay theo đề bài Bài tập về nhà
    _localTransactions.addAll([
      WalletTransaction(
        id: 'tx-1',
        title: 'Withdraw',
        recipientOrSender: 'Cardless withdraw',
        amount: 232.80,
        timestamp: DateTime(2022, 8, 21),
        type: TransactionType.withdraw,
      ),
      WalletTransaction(
        id: 'tx-2',
        title: 'Bank transfer',
        recipientOrSender: 'to Greg Stan',
        amount: 170.09,
        timestamp: DateTime(2022, 8, 23),
        type: TransactionType.transfer,
      ),
      WalletTransaction(
        id: 'tx-3',
        title: 'Deposit',
        recipientOrSender: 'Top-up from Visa',
        amount: 32.65,
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        type: TransactionType.deposit,
      ),
    ]);
  }

  // ==================== BÀI TẬP 3: PRODUCTS (FIRESTORE) ====================

  Stream<List<Product>> getProductsStream() {
    if (FirebaseService.isInitialized && FirebaseService.hasRealCredentials) {
      try {
        return _firestore
            .collection('products')
            .orderBy('createdAt', descending: true)
            .snapshots()
            .map((snapshot) {
          if (snapshot.docs.isEmpty) {
            return List<Product>.from(_localProducts);
          }
          return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
        });
      } catch (e) {
        debugPrint("Firestore getProductsStream error: $e");
      }
    }
    // Stream controller local
    return Stream.value(List<Product>.from(_localProducts));
  }

  Future<List<Product>> getProducts() async {
    if (FirebaseService.isInitialized && FirebaseService.hasRealCredentials) {
      try {
        final querySnapshot = await _firestore
            .collection('products')
            .orderBy('createdAt', descending: true)
            .get();
        if (querySnapshot.docs.isNotEmpty) {
          return querySnapshot.docs.map((d) => Product.fromFirestore(d)).toList();
        }
      } catch (e) {
        debugPrint("Firestore getProducts exception: $e");
      }
    }
    return List<Product>.from(_localProducts);
  }

  Future<void> addProduct(Product product) async {
    if (FirebaseService.isInitialized && FirebaseService.hasRealCredentials) {
      try {
        await _firestore.collection('products').add(product.toMap());
      } catch (e) {
        debugPrint("Firestore addProduct error: $e");
      }
    }
    _localProducts.insert(0, product);
    notifyListeners();
  }

  Future<void> deleteProduct(String id) async {
    if (FirebaseService.isInitialized && FirebaseService.hasRealCredentials) {
      try {
        await _firestore.collection('products').doc(id).delete();
      } catch (e) {
        debugPrint("Firestore deleteProduct error: $e");
      }
    }
    _localProducts.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  // ==================== BÀI TẬP VỀ NHÀ: ZHIP PAYS WALLET ====================

  List<WalletTransaction> get transactions => List.unmodifiable(_localTransactions);

  Future<void> topUp(double amount) async {
    _walletBalance += amount;
    _walletPoints += (amount * 2).toInt();
    final tx = WalletTransaction(
      id: 'tx-${DateTime.now().millisecondsSinceEpoch}',
      title: 'Top Up',
      recipientOrSender: 'Nạp tiền vào ví',
      amount: amount,
      timestamp: DateTime.now(),
      type: TransactionType.deposit,
    );
    _localTransactions.insert(0, tx);
    notifyListeners();
  }

  Future<bool> withdraw(double amount) async {
    if (_walletBalance < amount) return false;
    _walletBalance -= amount;
    final tx = WalletTransaction(
      id: 'tx-${DateTime.now().millisecondsSinceEpoch}',
      title: 'Withdraw',
      recipientOrSender: 'Rút tiền về thẻ ATM',
      amount: amount,
      timestamp: DateTime.now(),
      type: TransactionType.withdraw,
    );
    _localTransactions.insert(0, tx);
    notifyListeners();
    return true;
  }

  Future<bool> transfer(double amount, String recipient, {String? note}) async {
    if (_walletBalance < amount) return false;
    _walletBalance -= amount;
    final tx = WalletTransaction(
      id: 'tx-${DateTime.now().millisecondsSinceEpoch}',
      title: 'Bank transfer',
      recipientOrSender: 'to $recipient',
      amount: amount,
      timestamp: DateTime.now(),
      type: TransactionType.transfer,
      note: note,
    );
    _localTransactions.insert(0, tx);
    notifyListeners();
    return true;
  }
}
