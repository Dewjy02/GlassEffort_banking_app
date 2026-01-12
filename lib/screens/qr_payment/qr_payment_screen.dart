import 'package:banking_app/screens/auth/auth_screen.dart';
import 'package:banking_app/screens/qr_payment/widgets/generateQrTab.dart';
import 'package:banking_app/screens/qr_payment/widgets/scanQrTab.dart'
    hide primaryBlue;
import 'package:flutter/material.dart';
import 'package:flutter_glass_morphism/flutter_glass_morphism.dart';

class QrPaymentScreen extends StatefulWidget {
  const QrPaymentScreen({super.key});

  @override
  State<QrPaymentScreen> createState() => _QrPaymentScreenState();
}

class _QrPaymentScreenState extends State<QrPaymentScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 2;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onNavItemTapped(int index) {
    if (index == 2) {
      return;
    }
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      appBar: GlassMorphismAppBar(
        backgroundColor: Colors.transparent,
        blurIntensity: 20.0,
        enableDynamicSizing: true,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        ),
        title: const Text(
          'QR Payment',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/payment_confirmation');
            },
            child: Icon(Icons.next_plan,color: Colors.white,))
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/backgroundImage.png', fit: BoxFit.fill),
          ),

          Center(
            child: GlassMorphismContainer(
              width: size.width * 0.9,
              height: size.height * 0.65,
              opacity: 0.2,
              tintColor: Colors.white.withOpacity(0.1),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        indicator: BoxDecoration(
                          color: primaryBlue.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: primaryBlue.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.white70,
                        dividerColor: Colors.transparent,
                        tabs: const [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Tab(text: "My QR Code"),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Tab(text: "Scan QR"),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [Generateqrtab(), ScanQrTab()],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
