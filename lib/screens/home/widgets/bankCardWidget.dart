import 'package:flutter/material.dart';
import 'package:flutter_glass_morphism/flutter_glass_morphism.dart';

class BankCardWidget extends StatelessWidget {
  final String name;
  final String balance;
  final int cardNumberSuffix;

  const BankCardWidget({
    super.key,
    required this.name,
    required this.balance,
    required this.cardNumberSuffix,
  });

  @override
  Widget build(BuildContext context) {
    return GlassMorphismContainer(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.all(20),
      blurIntensity: 10,
      glassThickness: 20,
      tintColor: Colors.black12,
      height: 250,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildCardTop(),
          _buildBalanceDisplay(balance),
          _buildCardNumber(cardNumberSuffix),
          _buildCardDetails(name),
        ],
      ),
    );
  }
}

Widget _buildCardTop() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Icon(Icons.credit_card, size: 40, color: Colors.yellow[800]),
      const Text(
        'VISA',
        style: TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.w900,
          shadows: [
            Shadow(blurRadius: 5, color: Colors.black54, offset: Offset(1, 1)),
          ],
        ),
      ),
    ],
  );
}

Widget _buildBalanceDisplay(String balance) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Available Balance',
        style: TextStyle(color: Colors.white70, fontSize: 12),
      ),
      const SizedBox(height: 4),
      Text(
        '\$$balance',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  );
}

Widget _buildCardNumber(int cardNumberSuffix) {
  return Text(
    '**** **** **** $cardNumberSuffix'.toString(),
    style: const TextStyle(
      color: Colors.white,
      fontSize: 18,
      fontWeight: FontWeight.bold,
      letterSpacing: 4,
    ),
  );
}

Widget _buildCardDetails(String name) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Card Holder', style: TextStyle(color: Colors.white70, fontSize: 12)),
            Text(name.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: const [
            Text('Expires', style: TextStyle(color: Colors.white70, fontSize: 12)),
            Text('12/26', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500))
          ],
        )
      ],
    );
  }
