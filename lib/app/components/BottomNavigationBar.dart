import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trend_press/app/routes/app_routes.dart';
import 'package:trend_press/app/theme/colors.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavigationBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        if (index == 1) { // Bookmark is at index 1
          Get.toNamed(AppRoutes.bookmark); // Navigate to bookmark screen
        } else {
          onTap(index); // Handle other tabs normally
        }
      },
      selectedItemColor: AppColors.lightPrimary,
      unselectedItemColor: Colors.grey,
      backgroundColor: Colors.white,
      elevation: 8,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bookmark),
          label: 'Bookmarks',
        ),
      ],
    );
  }
}