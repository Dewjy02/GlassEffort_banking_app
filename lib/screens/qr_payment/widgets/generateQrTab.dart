import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class Generateqrtab extends StatefulWidget {
  const Generateqrtab({super.key});

  @override
  State<Generateqrtab> createState() => _GenerateqrtabState();
}

class _GenerateqrtabState extends State<Generateqrtab> {
  String? _qrData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _genarateQrCode();
  }

  Future<Map<String, dynamic>?> _getUserData() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return null;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    return doc.data()!;
  }

  void _genarateQrCode() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not logged in');

      final userData = await _getUserData();

      if (userData == null) throw Exception('User data not found');

      final qrPayloadInfo = {
        'uid': user.uid,
        'userName': userData['name'] ?? 'User',
        'type': 'receivePayment',
      };

      setState(() {
        _qrData = jsonEncode(qrPayloadInfo);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error generating QR code: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: (_isLoading =false || _qrData == null)
              ? const CircularProgressIndicator()
              : QrImageView(
                  data: _qrData!,
                  size: 230,
                  backgroundColor: Colors.white,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: Colors.blue,
                  ),
                ),
        ),
        const SizedBox(height: 20),
        FutureBuilder<Map<String, dynamic>?>(
          future: _getUserData(),
          builder: (context, snapshot) {
            final userName = snapshot.data?['name'] ?? 'User';
            return Text(
              '@$userName',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontFamily: 'Raleway',
              ),
            );
          },
        ),
        const SizedBox(height: 10),
        const Text(
          "Scan to pay me",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ],
    );
  }
}
