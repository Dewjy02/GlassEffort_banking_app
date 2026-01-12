import 'package:banking_app/firebase_options.dart';
import 'package:banking_app/screens/auth/auth_screen.dart';
import 'package:banking_app/screens/home/home_screen.dart';
import 'package:banking_app/screens/qr_payment/payment_confirmation_screen.dart';
import 'package:banking_app/screens/qr_payment/qr_payment_screen.dart';
import 'package:banking_app/screens/qr_payment/transaction_receipt_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Banking App UI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Roboto'),
      home: const Wrapper(),

      routes: {
        '/qr_payment': (context) =>  QrPaymentScreen(),
        '/home': (context) => const HomeScreen(),
        '/payment_confirmation': (context) => const PaymentConfirmationScreen(receiverUserId: "receiverUserId", receiverUserName: "receiverUserName"),
        '/transaction_receipt': (context) => const TransactionReceiptScreen(transactionId: "transactionId", type: "type", description: "description", category: "category", amount: 200.9),

      },
    );
  }
}

// wrapper for authentication and home screens
class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(stream: FirebaseAuth.instance.authStateChanges(), 
    builder: (context, snapshot){
      if(snapshot.connectionState == ConnectionState.waiting){
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      }
      if(snapshot.hasData && snapshot.data != null){
        return const HomeScreen();
      }
      return const AuthScreen();
    });
  }
}