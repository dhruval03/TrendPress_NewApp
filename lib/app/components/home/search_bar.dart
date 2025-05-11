import 'package:flutter/material.dart';
import 'package:trend_press/app/theme/colors.dart';

class NewsSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSearch;
  final VoidCallback onClear;

  const NewsSearchBar({
    Key? key,
    required this.controller,
    required this.onSearch,
    required this.onClear,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: width * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.grey),
          SizedBox(width: width * 0.02),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: "Search news articles...",
                border: InputBorder.none,
              ),
              onSubmitted: (_) => onSearch(),
            ),
          ),
          controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: onClear,
                )
              : IconButton(
                  icon: const Icon(Icons.search, color: AppColors.lightPrimary),
                  onPressed: onSearch,
                ),
        ],
      ),
    );
  }
}

// Search indicator widget
class SearchActiveIndicator extends StatelessWidget {
  final String searchQuery;
  final VoidCallback onClear;

  const SearchActiveIndicator({
    Key? key,
    required this.searchQuery,
    required this.onClear,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.lightPrimary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, size: 16, color: AppColors.lightPrimary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Showing results for "$searchQuery"',
              style: const TextStyle(
                color: AppColors.lightPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          GestureDetector(
            onTap: onClear,
            child: const Icon(Icons.close, size: 16, color: AppColors.lightPrimary),
          ),
        ],
      ),
    );
  }
}