import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_glass_morphism/flutter_glass_morphism.dart';
import 'transaction_receipt_screen.dart'; // Import the receipt screen

const Color primaryBlue = Color(0xFF1E3A8A);
const Color secondaryBlue = Color(0xFF4C1D95);

class PaymentConfirmationScreen extends StatefulWidget {
  final String receiverUserId;
  final String receiverUserName;

  const PaymentConfirmationScreen({
    super.key,
    required this.receiverUserId,
    required this.receiverUserName,
  });

  @override
  State<PaymentConfirmationScreen> createState() =>
      _PaymentConfirmationScreenState();
}

class _PaymentConfirmationScreenState extends State<PaymentConfirmationScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  bool _isProcessing = false;
  double? _senderBalance;

  @override
  void initState() {
    super.initState();
    _loadSenderBalance();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadSenderBalance() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (mounted) {
      setState(() {
        _senderBalance = ((doc.data()?['account_balance'] ?? 0.0) as num)
            .toDouble();
      });
    }
  }

  Future<void> _confirmPayment() async {
    if (_amountController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter an amount')));
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    if (_senderBalance != null && amount > _senderBalance!) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Insufficient balance')));
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) throw Exception('User not logged in');

      await _makePayment(
        currentUser.uid,
        widget.receiverUserId,
        amount,
        widget.receiverUserName,
        _noteController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment successful!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => TransactionReceiptScreen(
            transactionId: 'TXN${DateTime.now().millisecondsSinceEpoch}_sender',
            type: 'debit',
            description: 'QR Payment to ${widget.receiverUserName}',
            category: 'QR Payment',
            amount: amount,
            timestamp: Timestamp.now(),
            note: _noteController.text.isNotEmpty ? _noteController.text : null,
            recipient: widget.receiverUserName,
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _makePayment(
    String senderUserId,
    String receiverUserId,
    double amount,
    String receiverUserName,
    String note,
  ) async {
    final firestore = FirebaseFirestore.instance;
    final batch = firestore.batch();

    final senderDoc = firestore.collection('users').doc(senderUserId);
    final receiverDoc = firestore.collection('users').doc(receiverUserId);

    final senderData = await senderDoc.get();
    final receiverData = await receiverDoc.get();

    if (!senderData.exists || !receiverData.exists) {
      throw Exception('User data not found');
    }

    final senderBalance = (senderData.data()?['account_balance'] ?? 0.0) as num;
    final receiverBalance =
        (receiverData.data()?['account_balance'] ?? 0.0) as num;
    final senderName = senderData.data()?['name'] ?? 'User';

    if (senderBalance < amount) {
      throw Exception('Insufficient balance');
    }

    batch.update(senderDoc, {'account_balance': senderBalance - amount});

    batch.update(receiverDoc, {'account_balance': receiverBalance + amount});

    final transactionId = firestore.collection('transactions').doc().id;
    final timestamp = FieldValue.serverTimestamp();

    batch.set(
      firestore.collection('transactions').doc(transactionId + '_sender'),
      {
        'userId': senderUserId,
        'type': 'debit',
        'amount': amount,
        'description': 'QR Payment to $receiverUserName',
        'note': note.isNotEmpty ? note : null,
        'recipient': receiverUserName,
        'recipientId': receiverUserId,
        'timestamp': timestamp,
        'category': 'QR Payment',
      },
    );

    batch.set(
      firestore.collection('transactions').doc(transactionId + '_receiver'),
      {
        'userId': receiverUserId,
        'type': 'credit',
        'amount': amount,
        'description': 'QR Payment from $senderName',
        'note': note.isNotEmpty ? note : null,
        'sender': senderName,
        'senderId': senderUserId,
        'timestamp': timestamp,
        'category': 'QR Payment',
      },
    );

    await batch.commit();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: GlassMorphismAppBar(
        enableDynamicSizing: true,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: const Text(
            'Confirm Payment',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/transaction_receipt');
            },
            child: Icon(Icons.next_plan,color: Colors.white,))
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/backgroundImage.png', fit: BoxFit.cover),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(0, 60, 0, 0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                    child: GlassMorphismContainer(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.all(25),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                children: [
                                  const Text(
                                    'Pay to',
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  const Icon(
                                    Icons.account_circle,
                                    size: 70,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(height: 15),
                                  Text(
                                    widget.receiverUserName,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 40),
                          const Text(
                            'Enter Amount',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 15),
                          TextField(
                            controller: _amountController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: primaryBlue,
                            ),
                            decoration: InputDecoration(
                              prefixText: '\$ ',
                              prefixStyle: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: primaryBlue,
                              ),
                              hintText: '0.00',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: const BorderSide(
                                  color: primaryBlue,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          if (_senderBalance != null)
                            Text(
                              'Available balance: \$${_senderBalance!.toStringAsFixed(2)}',
                              style: TextStyle(fontSize: 14, color: Colors.black),
                            ),
                          const SizedBox(height: 20),
                          const Text(
                            'Note (Optional)',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _noteController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: 'Add a note...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: const BorderSide(
                                  color: primaryBlue,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: GlassMorphismButton(
                        style: GlassMorphismButtonStyle(
                          backgroundColor: Colors.green,
                          borderRadius: BorderRadius.circular(24),
                          blurIntensity: 8.0,
                        ),
                        onPressed: _isProcessing ? null : _confirmPayment,
                        child: _isProcessing
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Confirm Payment',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: _isProcessing ? null : () => Navigator.pop(context),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
