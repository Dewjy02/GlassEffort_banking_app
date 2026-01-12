// lib/models/transaction_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String id;
  final String type; // 'debit' or 'credit'
  final String description;
  final String category;
  final double amount;
  final DateTime date;

  TransactionModel({
    required this.id,
    required this.type,
    required this.description,
    required this.category,
    required this.amount,
    required this.date,
  });

  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    DateTime parsedDate = DateTime.now();
    if (data['timestamp'] != null) {
      parsedDate = (data['timestamp'] as Timestamp).toDate();
    }

    return TransactionModel(
      id: doc.id,
      type: data['type'] ?? 'debit',
      description: data['description'] ?? 'Unknown Transaction',
      category: data['category'] ?? 'General',
      amount: (data['amount'] is num) 
          ? (data['amount'] as num).toDouble() 
          : 0.0,
      date: parsedDate,
    );
  }

  static List<TransactionModel> dummyTransactions = [
    TransactionModel(
      id: '1',
      type: 'debit',
      description: 'Starbucks Coffee',
      category: 'Food & Drink',
      amount: 5.40,
      date: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    TransactionModel(
      id: '2',
      type: 'credit',
      description: 'Freelance Payment',
      category: 'Income',
      amount: 1250.00,
      date: DateTime.now().subtract(const Duration(days: 1)),
    ),
    TransactionModel(
      id: '3',
      type: 'debit',
      description: 'Netflix Subscription',
      category: 'Entertainment',
      amount: 15.99,
      date: DateTime.now().subtract(const Duration(days: 3)),
    ),
    TransactionModel(
      id: '4',
      type: 'debit',
      description: 'Uber Ride',
      category: 'Transport',
      amount: 24.50,
      date: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];
}