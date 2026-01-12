import 'package:banking_app/models/action_item_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_glass_morphism/flutter_glass_morphism.dart';

class ActionGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GlassMorphismContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'What would you like to do today?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ),
          SizedBox(
            height: 110,
            width: MediaQuery.of(context).size.width*0.98,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: homeActionItems.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) => SizedBox(
                width: 90,
                child: _ActionButton(item: homeActionItems[index]),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final ActionItem item;

  const _ActionButton({required this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        print('Tapped ${item.label}');
      },
      borderRadius: BorderRadius.circular(15),
      child: GlassMorphismContainer(
        glassThickness: 20,
        borderRadius: BorderRadius.circular(15),
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 5),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(item.icon, color: Colors.black87, size: 30),
              const SizedBox(height: 8),
              Text(
                item.label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}