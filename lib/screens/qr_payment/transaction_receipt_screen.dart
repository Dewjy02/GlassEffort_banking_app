import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_glass_morphism/flutter_glass_morphism.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';

const Color primaryBlue = Color(0xFF1E3A8A);
const Color successGreen = Color(0xFF69F0AE);

class TransactionReceiptScreen extends StatefulWidget {
  final String transactionId;
  final String type;
  final String description;
  final String category;
  final double amount;
  final Timestamp? timestamp;
  final String? note;
  final String? recipient;
  final String? sender;

  const TransactionReceiptScreen({
    super.key,
    required this.transactionId,
    required this.type,
    required this.description,
    required this.category,
    required this.amount,
    this.timestamp,
    this.note,
    this.recipient,
    this.sender,
  });

  @override
  State<TransactionReceiptScreen> createState() =>
      _TransactionReceiptScreenState();
}

class _TransactionReceiptScreenState extends State<TransactionReceiptScreen> {
  final GlobalKey _receiptKey = GlobalKey();
  bool _isSharing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: GlassMorphismContainer(
            borderRadius: BorderRadius.circular(50),
            blurIntensity: 90,
            
            child: Center(child: const Icon(Icons.close, color: Colors.white)),
          ),
        ),
        actions: [
          IconButton(
            onPressed: _isSharing ? null : _shareReceipt,
            icon: const Icon(Icons.ios_share, color: Colors.white),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/backgroundImage.png', 
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 130, 20, 30),
              child: Column(
                children: [
                  RepaintBoundary(
                    key: _receiptKey,
                    // The receipt content is now inside a Glass Container
                    child: _buildGlassReceiptCard(),
                  ),
                  const SizedBox(height: 30),
                  _buildNewActionButtons(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassReceiptCard() {
    final isDebit = widget.type == 'debit';
    final amountText = '\$${widget.amount.toStringAsFixed(2)}';
    String formattedDate = 'Unknown date';
    String formattedTime = '';

    if (widget.timestamp != null) {
      final date = widget.timestamp!.toDate();
      formattedDate = DateFormat('MMMM dd, yyyy').format(date);
      formattedTime = DateFormat('hh:mm a').format(date);
    }

    return GlassMorphismContainer(
      width: double.infinity,
      borderRadius: BorderRadius.circular(24),
      opacity: 0.2,
      border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: successGreen.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: successGreen,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  isDebit ? 'Payment Sent' : 'Payment Received',
                  style: const TextStyle(
                    color: Colors.white, 
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  amountText,
                  style: const TextStyle(
                    color: Colors.white, 
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$formattedDate at $formattedTime',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7), 
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.white.withOpacity(0.2)),
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Transaction Details',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, 
                  ),
                ),
                const SizedBox(height: 24),
                _buildNewDetailRow('To', widget.recipient ?? 'Unknown'),
                if (widget.sender != null) ...[
                  const SizedBox(height: 16),
                  _buildNewDetailRow('From', widget.sender!),
                ],
                const SizedBox(height: 16),
                _buildNewDetailRow('Category', widget.category),
                const SizedBox(height: 16),
                _buildNewDetailRow(
                  'Reference',
                  widget.transactionId.toUpperCase(),
                  isMono: true,
                ),
                if (widget.note != null && widget.note!.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(
                        0.1,
                      ), 
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Note',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.note!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          Divider(height: 1, color: Colors.white.withOpacity(0.2)),
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Amount Details',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                _buildAmountRow('Amount', amountText),
                const SizedBox(height: 12),
                _buildAmountRow('Service Fee', '\$0.00'),
                const SizedBox(height: 16),
                Divider(color: Colors.white.withOpacity(0.2)),
                const SizedBox(height: 16),
                _buildAmountRow('Total Amount', amountText, isTotal: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewDetailRow(String label, String value, {bool isMono = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7), 
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: Colors.white, 
              fontSize: 14,
              fontWeight: FontWeight.w600,
              fontFamily: isMono ? 'Courier New' : null,
              letterSpacing: isMono ? 0.5 : null,
            ),
          ),
        ),
      ],
    );
  }
  Widget _buildAmountRow(String label, String amount, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.w500,
            color: isTotal
                ? Colors.white
                : Colors.white.withOpacity(0.7), 
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            color: Colors.white, 
          ),
        ),
      ],
    );
  }

  Widget _buildNewActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: GlassMorphismButton(
            onPressed: () => Navigator.pushNamed(context, "/home"),
            style: GlassMorphismButtonStyle(
              foregroundColor: Colors.green,
              blurIntensity: 20,
            ),
            child: const Text(
              'Done',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextButton.icon(
          onPressed: () {
          },
          icon: Icon(
            Icons.flag_outlined,
            size: 18,
            color: Colors.white.withOpacity(0.8),
          ), 
          label: Text(
            'Report an issue',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ), 
          ),
        ),
      ],
    );
  }

  Future<void> _shareReceipt() async {
    setState(() {
      _isSharing = true;
    });

    try {
      final boundary =
          _receiptKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 4.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();

      if (kIsWeb) {
        await Share.shareXFiles([
          XFile.fromData(
            bytes,
            name: 'receipt_${widget.transactionId}.png',
            mimeType: 'image/png',
          ),
        ], text: 'Transaction Receipt for ${widget.amount}');
      } else {
        final tempDir = await getTemporaryDirectory();
        final file = File(
          '${tempDir.path}/receipt_${widget.transactionId}.png',
        );
        await file.writeAsBytes(bytes);

        await Share.shareXFiles([
          XFile(file.path),
        ], text: 'Transaction Receipt for ${widget.amount}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share receipt: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSharing = false;
        });
      }
    }
  }
}