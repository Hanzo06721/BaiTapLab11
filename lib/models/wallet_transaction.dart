enum TransactionType {
  deposit,
  withdraw,
  transfer,
}

class WalletTransaction {
  final String id;
  final String title;
  final String recipientOrSender;
  final double amount;
  final DateTime timestamp;
  final TransactionType type;
  final String? note;

  WalletTransaction({
    required this.id,
    required this.title,
    required this.recipientOrSender,
    required this.amount,
    required this.timestamp,
    required this.type,
    this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'recipientOrSender': recipientOrSender,
      'amount': amount,
      'timestamp': timestamp.toIso8601String(),
      'type': type.name,
      'note': note ?? '',
    };
  }

  factory WalletTransaction.fromMap(Map<String, dynamic> map, String id) {
    return WalletTransaction(
      id: id,
      title: map['title'] ?? '',
      recipientOrSender: map['recipientOrSender'] ?? '',
      amount: (map['amount'] is num) ? (map['amount'] as num).toDouble() : 0.0,
      timestamp: DateTime.tryParse(map['timestamp'] ?? '') ?? DateTime.now(),
      type: TransactionType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => TransactionType.transfer,
      ),
      note: map['note'],
    );
  }
}
