import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:trend_press/app/routes/app_routes.dart';
import 'package:trend_press/app/views/home/NewsDetailScreen.dart';
import 'package:trend_press/app/components/BottomNavigationBar.dart';
import '../../theme/colors.dart';

class BookmarkedNewsScreen extends StatefulWidget {
  const BookmarkedNewsScreen({Key? key}) : super(key: key);

  @override
  State<BookmarkedNewsScreen> createState() => _BookmarkedNewsScreenState();
}

class _BookmarkedNewsScreenState extends State<BookmarkedNewsScreen> {
  List<Map<String, dynamic>> _bookmarkedArticles = [];

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  // Load bookmarks from SharedPreferences
  Future<void> _loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarks = prefs.getStringList('bookmarks') ?? [];
    setState(() {
      _bookmarkedArticles = bookmarks
          .map((bookmark) => jsonDecode(bookmark) as Map<String, dynamic>)
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Bookmarked News'),
        backgroundColor: AppColors.lightPrimary,
        foregroundColor: Colors.white,
      ),
      body: _bookmarkedArticles.isEmpty
          ? const Center(
              child: Text(
                'No bookmarked articles yet.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _bookmarkedArticles.length,
              itemBuilder: (context, index) {
                final article = _bookmarkedArticles[index];
                final title = article['title'] ?? 'No title available';
                final imageUrl = article['urlToImage'] ?? 'https://via.placeholder.com/150';
                final sourceName = article['source']?['name'] ?? 'Unknown source';
                final publishedAt = article['publishedAt'] ?? '';

                // Format date
                String formattedDate = "Unknown date";
                if (publishedAt.isNotEmpty) {
                  try {
                    final date = DateTime.parse(publishedAt);
                    formattedDate = DateFormat('MMMM dd, yyyy').format(date);
                  } catch (e) {
                    formattedDate = "Date unavailable";
                  }
                }

                return GestureDetector(
                  onTap: () {
                    Get.to(() => NewsDetailScreen(article: article));
                  },
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Thumbnail
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            bottomLeft: Radius.circular(12),
                          ),
                          child: Image.network(
                            imageUrl,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 100,
                                height: 100,
                                color: Colors.grey[300],
                                child: const Icon(Icons.image_not_supported, size: 40),
                              );
                            },
                          ),
                        ),
                        // Article details
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    height: 1.2,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  sourceName,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  formattedDate,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: 1, 
        onTap: (index) {
          if (index == 0) { 
            Get.offAllNamed(AppRoutes.home); 
          }
        },
      ),
    );
  }
}