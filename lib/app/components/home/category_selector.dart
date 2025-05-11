import 'package:flutter/material.dart';
import 'package:trend_press/app/theme/colors.dart';

class CategorySelector extends StatelessWidget {
  final List<String> categories;
  final Set<String> selectedCategories;
  final Function(String) onCategoryTapped;
  final bool isSmall;

  const CategorySelector({
    Key? key,
    required this.categories,
    required this.selectedCategories,
    required this.onCategoryTapped,
    required this.isSmall,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategories.contains(category);

          return GestureDetector(
            onTap: () => onCategoryTapped(category),
            child: Container(
              margin: EdgeInsets.only(right: width * 0.02),
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.04,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.lightPrimary
                    : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.lightPrimary),
              ),
              child: Center(
                child: Text(
                  category,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : AppColors.lightPrimary,
                    fontSize: isSmall ? 12 : 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}