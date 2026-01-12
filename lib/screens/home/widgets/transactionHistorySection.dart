import 'package:banking_app/core/skeltonContainer.dart';
import 'package:banking_app/models/transaction_model.dart';
import 'package:banking_app/screens/home/widgets/TransactionRow.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_glass_morphism/flutter_glass_morphism.dart';

class TransactionHistorySection extends StatelessWidget {
  const TransactionHistorySection({super.key});

  Stream<QuerySnapshot> _getTransactionsStream(String userId) {
    return FirebaseFirestore.instance
        .collection('transactions')
        .where('userId', isEqualTo: userId)
        .limit(10)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const SizedBox.shrink();
    }

    return GlassMorphismContainer(
      margin: const EdgeInsets.only(top: 4),
      width: MediaQuery.of(context).size.width * 0.98,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          children: [
            _buildSectionHeader(context),
            const SizedBox(height: 10),
            StreamBuilder<QuerySnapshot>(
              stream: _getTransactionsStream(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Column(
                    children: List.generate(
                      3,
                      (index) => const _TransactionRowSkeleton(),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('Error loading transactions'),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 50,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'No transactions yet',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                final transactions = snapshot.data!.docs;

                return Column(
                  children: transactions.take(5).map((doc) {
                    final transaction = TransactionModel.fromFirestore(doc);
                    return TransactionRow(transaction: transaction);
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Transaction History',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        TextButton(
          onPressed: () {
            // Navigator.pushNamed(context, '/transactions');
          },
          child: const Text(
            'See All',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _TransactionRowSkeleton extends StatelessWidget {
  const _TransactionRowSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          const SkeletonContainer(width: 48, height: 48, radius: 12),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SkeletonContainer(width: 120, height: 16, radius: 4),
                SizedBox(height: 5),
                SkeletonContainer(width: 80, height: 14, radius: 4),
              ],
            ),
          ),
          const SkeletonContainer(width: 70, height: 16, radius: 4),
        ],
      ),
    );
  }
}
