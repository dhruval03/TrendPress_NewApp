import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/colors.dart';
import '../../components/greeting_header.dart'; 

class NewsDetailScreen extends StatefulWidget {
  final Map<String, dynamic> article;

  const NewsDetailScreen({
    Key? key,
    required this.article,
  }) : super(key: key);

  @override
  State<NewsDetailScreen> createState() => _NewsDetailScreenState();
}

class _NewsDetailScreenState extends State<NewsDetailScreen> {
  bool _isBookmarked = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkBookmarkStatus();
  }

  // Check if the article is already bookmarked
  Future<void> _checkBookmarkStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarks = prefs.getStringList('bookmarks') ?? [];
    final articleJson = jsonEncode(widget.article);
    setState(() {
      _isBookmarked = bookmarks.contains(articleJson);
    });
  }

  // Toggle bookmark status
  Future<void> _toggleBookmark() async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarks = prefs.getStringList('bookmarks') ?? [];
    final articleJson = jsonEncode(widget.article);

    if (_isBookmarked) {
      bookmarks.remove(articleJson);
    } else {
      bookmarks.add(articleJson);
    }

    await prefs.setStringList('bookmarks', bookmarks);
    setState(() {
      _isBookmarked = !_isBookmarked;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isBookmarked ? 'Article bookmarked' : 'Bookmark removed'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final isSmall = width < 360;

    final title = widget.article['title'] ?? 'No title available';
    final imageUrl = widget.article['urlToImage'] ?? 'https://via.placeholder.com/300';
    final sourceName = widget.article['source']?['name'] ?? 'Unknown source';
    final publishedAt = widget.article['publishedAt'] ?? '';
    final content = widget.article['content'] ?? 'No content available';
    final description = widget.article['description'] ?? 'No description available';
    final author = widget.article['author'] ?? 'Unknown author';
    final url = widget.article['url'] ?? '';

    // Format date
    String formattedDate = "Unknown date";
    if (publishedAt.isNotEmpty) {
      try {
        final date = DateTime.parse(publishedAt);
        formattedDate = DateFormat('MMMM dd, yyyy • hh:mm a').format(date);
      } catch (e) {
        formattedDate = "Date unavailable";
      }
    }

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Image.network(
                        imageUrl,
                        height: height * 0.35,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: height * 0.35,
                            color: Colors.grey[300],
                            child: const Center(
                              child: Icon(Icons.image_not_supported, size: 50),
                            ),
                          );
                        },
                      ),
                      Container(
                        height: height * 0.35,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                            stops: const [0.6, 1.0],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 16,
                        left: 16,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 16,
                        left: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.lightPrimary,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            sourceName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Article content
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: isSmall ? 20 : 24,
                            fontWeight: FontWeight.bold,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Date and author row
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                formattedDate,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        if (author != 'Unknown author') ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.person, size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  "By $author",
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],

                        const SizedBox(height: 20),

                        // Description
                        Text(
                          description,
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.5,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[800],
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 16),

                        // Main content
                        Text(
                          content.replaceAll(RegExp(r'\[\+\d+ chars\]$'), ''),
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.6,
                            color: Colors.grey[800],
                          ),
                        ),
                        
                        const SizedBox(height: 30),

                        // Read more button
                        if (url.isNotEmpty)
                          Center(
                            child: ElevatedButton(
                              onPressed: () => _launchUrl(url),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.lightPrimary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: const Text('Read Full Article'),
                            ),
                          ),

                        const SizedBox(height: 50),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Action buttons overlay at bottom
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildActionButton(
                      icon: _isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                      label: "Bookmark",
                      isActive: _isBookmarked,
                      onTap: _toggleBookmark,
                    ),
                    _buildActionButton(
                      icon: Icons.text_snippet_outlined,
                      label: "Full Article",
                      onTap: () => _launchUrl(url),
                    ),
                  ],
                ),
              ),
            ),

            // Loading indicator
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? AppColors.lightPrimary : Colors.grey[700],
            size: 22,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isActive ? AppColors.lightPrimary : Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Article URL is not available')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final Uri uri = Uri.parse(url);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch the article')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}