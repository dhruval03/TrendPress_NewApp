import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 

class NewsHeader extends StatelessWidget {
  final String username;
  final bool showAvatar;
  final VoidCallback? onAvatarTap;
  final bool isSmall;

  const NewsHeader({
    Key? key,
    this.username = 'Explorer',
    this.showAvatar = false,
    this.onAvatarTap,
    this.isSmall = false,
  }) : super(key: key);

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 18) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    return DateFormat('dd/MM/yyyy').format(now);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${_getGreeting()}, $username",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isSmall ? 16 : 20,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _getFormattedDate(),
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
        if (showAvatar)
          GestureDetector(
            onTap: onAvatarTap,
            child: CircleAvatar(
              radius: isSmall ? 18 : 22,
              backgroundColor: Colors.grey[300],
              child: Icon(
                Icons.person,
                size: isSmall ? 20 : 24,
                color: Colors.grey[600],
              ),
            ),
          ),
      ],
    );
  }
}