import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_glass_morphism/flutter_glass_morphism.dart';

class Homeheader extends StatelessWidget {
  final String name;
  const Homeheader({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GlassMorphismContainer(
          height: 150,
          glassThickness: 30,
          blurIntensity: 0.8
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [_buildTopBar(), SizedBox(height: 20), _buildGreeting()],
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "ComBank",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              _buildCircleIcon(Icons.chat_bubble_outline),
              const SizedBox(width: 8),
              _buildCircleIcon(Icons.notifications_none),
              const SizedBox(width: 8),
              _buildCircleIconWithAction(Icons.logout, () async {
                await FirebaseAuth.instance.signOut();
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCircleIcon(IconData icon) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.3),
      ),
      padding: const EdgeInsets.all(10),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }

  Widget _buildCircleIconWithAction(IconData icon, VoidCallback onTap) {
    return GestureDetector(onTap: onTap, child: _buildCircleIcon(icon));
  }

  Widget _buildGreeting() {
    return Row(
      children: [
        const Icon(Icons.lock_outline, color: Colors.white, size: 24),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Good morning,',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
