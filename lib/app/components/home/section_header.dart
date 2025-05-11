import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final bool isSmall;
  final VoidCallback? onViewAllTap;

  const SectionHeader({
    Key? key,
    required this.title,
    required this.isSmall,
    this.onViewAllTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: isSmall ? 16 : 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (onViewAllTap != null)
          TextButton(
            onPressed: onViewAllTap,
            child: const Text("View All"),
          ),
      ],
    );
  }
}