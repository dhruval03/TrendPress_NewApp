import 'package:flutter/material.dart';

class EmptyStateWidget extends StatelessWidget {
  final double height;
  final String searchQuery;
  final VoidCallback onResetFilters;
  final bool showResetButton;

  const EmptyStateWidget({
    Key? key,
    required this.height,
    required this.searchQuery,
    required this.onResetFilters,
    this.showResetButton = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height * 0.2,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.article_outlined, size: 40, color: Colors.grey),
            const SizedBox(height: 8),
            Text(
              searchQuery.isNotEmpty
                  ? 'No results found for "$searchQuery"'
                  : 'No articles found',
              style: TextStyle(color: Colors.grey[600]),
            ),
            if (showResetButton)
              TextButton(
                onPressed: onResetFilters,
                child: const Text('Reset filters'),
              )
          ],
        ),
      ),
    );
  }
}