import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/wallet_transaction.dart';
import '../../services/firestore_service.dart';

class ZhippayStatisticScreen extends StatefulWidget {
  const ZhippayStatisticScreen({super.key});

  @override
  State<ZhippayStatisticScreen> createState() => _ZhippayStatisticScreenState();
}

class _ZhippayStatisticScreenState extends State<ZhippayStatisticScreen> {
  int _selectedPeriodIndex = 0; // 0: 1 Tháng, 1: 1 Quý, 2: 1 Năm
  final periods = ['1 Tháng', '1 Quý', '1 Năm'];
  final FirestoreService _firestoreService = FirestoreService();
  final NumberFormat _currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

  @override
  Widget build(BuildContext context) {
    const brandPurple = Color(0xFF4F46E5);
    final transactions = _firestoreService.transactions;

    double totalIncome = 0;
    double totalExpense = 0;

    for (final tx in transactions) {
      if (tx.type == TransactionType.deposit) {
        totalIncome += tx.amount;
      } else {
        totalExpense += tx.amount;
      }
    }

    // Nhân hệ số mô phỏng theo kỳ thống kê (1 tháng x 1, 1 quý x 3, 1 năm x 12)
    final multiplier = _selectedPeriodIndex == 0 ? 1.0 : (_selectedPeriodIndex == 1 ? 2.8 : 10.5);
    final displayIncome = totalIncome * multiplier + 500 * multiplier;
    final displayExpense = totalExpense * multiplier + 300 * multiplier;
    final netCashFlow = displayIncome - displayExpense;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thống kê dòng tiền',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 16),

            // Period Selector Tabs (1 Tháng, 1 Quý, 1 Năm)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: List.generate(periods.length, (index) {
                  final isSelected = _selectedPeriodIndex == index;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedPeriodIndex = index),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: isSelected
                              ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)]
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          periods[index],
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? brandPurple : Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 20),

            // Cash Flow Summary Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatSummary('Tổng thu vào', displayIncome, Colors.green),
                      Container(width: 1, height: 40, color: Colors.grey.shade200),
                      _buildStatSummary('Tổng chi ra', displayExpense, Colors.redAccent),
                    ],
                  ),
                  const Divider(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Dòng tiền thuần (Net):',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        _currencyFormat.format(netCashFlow),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: netCashFlow >= 0 ? Colors.green : Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Biểu đồ cột trực quan mô phỏng dòng tiền
            const Text(
              'Biểu đồ biến động',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildBar('T1', 0.6, 0.4),
                  _buildBar('T2', 0.8, 0.5),
                  _buildBar('T3', 0.5, 0.7),
                  _buildBar('T4', 0.9, 0.6),
                  _buildBar('T5', 0.7, 0.3),
                  _buildBar('T6', 1.0, 0.8),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Danh sách giao dịch
            const Text(
              'Giao dịch chi tiết',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...transactions.map((tx) {
              final isNegative = tx.type != TransactionType.deposit;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tx.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(tx.recipientOrSender, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                    Text(
                      '${isNegative ? '-' : '+'}${_currencyFormat.format(tx.amount)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isNegative ? Colors.black87 : Colors.green,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildStatSummary(String label, double amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          _currencyFormat.format(amount),
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  Widget _buildBar(String label, double incomeRatio, double expenseRatio) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              width: 8,
              height: 80 * incomeRatio,
              decoration: BoxDecoration(
                color: const Color(0xFF10B981),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 4),
            Container(
              width: 8,
              height: 80 * expenseRatio,
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }
}
