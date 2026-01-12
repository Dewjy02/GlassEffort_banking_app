import 'package:banking_app/core/constants/colors.dart';
import 'package:flutter/material.dart';

class ActionItem {
  final IconData icon;
  final String label;
  final Color iconColor;

  const ActionItem({
    required this.icon,
    required this.label,
    required this.iconColor,
  });
}

// Home screen action items
const List<ActionItem> homeActionItems = [
  ActionItem(icon: Icons.sync_alt, label: 'Transfer', iconColor: primaryBlue),
  ActionItem(
    icon: Icons.wallet_outlined,
    label: 'Payment',
    iconColor: primaryBlue,
  ),
  ActionItem(
    icon: Icons.shopping_cart_outlined,
    label: 'Shop',
    iconColor: primaryBlue,
  ),
  ActionItem(icon: Icons.apps, label: 'Other', iconColor: primaryBlue),
  ActionItem(icon: Icons.apps, label: 'Other', iconColor: primaryBlue),
];
