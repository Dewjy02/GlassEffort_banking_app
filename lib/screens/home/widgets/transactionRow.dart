import 'package:banking_app/models/transaction_model.dart';
import 'package:flutter/material.dart';

class TransactionRow extends StatelessWidget {
  final TransactionModel transaction; 

  const TransactionRow({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    final isDebit = transaction.type == 'debit';
    final icon = isDebit ? Icons.arrow_upward : Icons.arrow_downward;
    final iconColor = isDebit ? Colors.red : Colors.green;
    final amountText = '${isDebit ? '-' : '+'}\$${transaction.amount.toStringAsFixed(2)}';
    final amountColor = isDebit ? Colors.red : Colors.green;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          _buildIcon(icon, iconColor),
          const SizedBox(width: 15),
          _buildDetails(transaction.description, transaction.category),
          Text(
            amountText,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: amountColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIcon(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }

  Widget _buildDetails(String title, String subtitle) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}