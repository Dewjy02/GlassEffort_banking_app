import 'package:banking_app/core/constants/colors.dart';
import 'package:banking_app/screens/home/widgets/actionGrid.dart';
import 'package:banking_app/screens/home/widgets/bankCardWidget.dart';
import 'package:banking_app/screens/home/widgets/bottomNavBar.dart' hide primaryBlue;
import 'package:banking_app/screens/home/widgets/transactionHistorySection.dart';
import 'package:banking_app/screens/home/widgets/homeHeader.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage('assets/backgroundImage.png'), context);
  }

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        setState(() {
          _selectedIndex = index;
        });
        break;
      case 1: 
        setState(() {
          _selectedIndex = index;
        });
        break;
      case 2:
        Navigator.pushNamed(context, '/qr_payment');
        break;
      case 3:
        setState(() {
          _selectedIndex = index;
        });
        break;
      case 4: 
        Navigator.pushNamed(context, '/transaction_receipt');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: const _HomePageContent(),

      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),

      floatingActionButton: CustomFloatingActionButton(
        onPressed: () => _onItemTapped(2),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

 class _HomePageContent extends StatelessWidget {
  const _HomePageContent();
  Stream<DocumentSnapshot<Map<String, dynamic>>>? _fetchUserData() {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _fetchUserData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsetsGeometry.only(top: 100),
              child: CircularProgressIndicator(color: primaryBlue),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.hasError || snapshot.data == null || !snapshot.data!.exists) {
          const fallbackName = 'Guest';
          const fallbackBalance = '0.00';
          const fallbackCardSuffix = 'XXXX';

          if (snapshot.hasError) {
            print('Error fetching user data ${snapshot.error}');
          }

          return _buildContent(
            name: fallbackName,
            balance: fallbackBalance,
            cardNumberSuffix: fallbackCardSuffix,
          );
        }
        final userData = snapshot.data!;
        final name = userData['name'] ?? 'User';
        final balance = (userData['account_balance'] is num)
            ? userData['account_balance'].toStringAsFixed(2)
            : '0.00';
        final cardNumberSuffix = userData['card_number_suffix'] ?? 'XXXX';

        return _buildContent(
          name: name,
          balance: balance,
          cardNumberSuffix: cardNumberSuffix.toString(),
        );
      },
    );
  }

  Widget _buildContent({
    required String name,
    required String balance,
    required String cardNumberSuffix,
  }) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/backgroundImage.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
        ),
        Positioned.fill(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Homeheader(name: name),
                BankCardWidget(
                  name: name,
                  balance: balance,
                  cardNumberSuffix: int.tryParse(cardNumberSuffix) ?? 1234,
                ),
                ActionGrid(),
                TransactionHistorySection(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
