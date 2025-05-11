import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:trend_press/app/components/BottomNavigationBar.dart';
import '../../theme/colors.dart';
import '../../../../services/news_api_service.dart';
import '../../components/greeting_header.dart';
import '../home/NewsDetailScreen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final NewsApiService _newsApiService = NewsApiService();
  final TextEditingController _searchController = TextEditingController();

  late Future<List<dynamic>> _trendingArticles;
  late Future<List<dynamic>> _latestArticles;
  
  // Navigation bar state
  int _currentNavIndex = 0;

  final List<String> _allCategories = [
    'All',
    'Business',
    'Finance',
    'Tech',
    'Food',
    'Crypto',
  ];
  Set<String> _selectedCategories = {'All'};
  String _searchQuery = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchArticles();
  }

  @override
  void dispose() {
    _searchController.dispose(); // Dispose controllers to prevent memory leaks
    super.dispose();
  }

  Future<void> _fetchArticles() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // For Trending section
      if (_searchQuery.isNotEmpty) {
        // If search query exists, use it for both sections
        _trendingArticles = _fetchSearchArticles(_searchQuery);
        _latestArticles = _fetchSearchArticles(_searchQuery);
      } else if (_selectedCategories.contains('All')) {
        // If 'All' is selected and no search query, fetch trending articles
        _trendingArticles = _newsApiService.fetchTrendingArticles();
        // For latest section, use the specific 'keyword' endpoint
        _latestArticles = _fetchKeywordArticles();
      } else {
        // Handle multiple selected categories
        List<String> categories = _selectedCategories.toList();
        
        // Fetch articles with categories
        _trendingArticles = _newsApiService.fetchArticles(
          categories: categories,
        );
        
        // Always use keyword articles for latest section if no search
        _latestArticles = _fetchKeywordArticles();
      }
    } catch (e) {
      print('Error fetching articles: $e');
    } finally {
      // Ensure loading state is updated even if there's an error
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Method to fetch articles based on search query
  Future<List<dynamic>> _fetchSearchArticles(String query) async {
    final String apiKey = dotenv.env['API_KEY']!;
  final String baseUrl = dotenv.env['API_BASE_URL']!;
  final String url = '${baseUrl}everything?q=$query&apiKey=$apiKey';
    
    try {
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['articles'] ?? [];
      } else {
        print('API Error for search articles: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Exception in _fetchSearchArticles: $e');
      return [];
    }
  }
  
  // Method to fetch keyword articles
  Future<List<dynamic>> _fetchKeywordArticles() async {
    final String apiKey = dotenv.env['API_KEY']!;
    final String baseUrl = dotenv.env['API_BASE_URL']!;
    final String url = '${baseUrl}everything?q=keyword&apiKey=$apiKey';
    
    try {
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['articles'] ?? [];
      } else {
        print('API Error for keyword articles: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Exception in _fetchKeywordArticles: $e');
      return [];
    }
  }

  void _onCategoryTapped(String category) {
    setState(() {
      // Reset search when selecting categories
      if (_searchQuery.isNotEmpty) {
        _searchController.clear();
        _searchQuery = '';
      }
      
      if (category == 'All') {
        _selectedCategories = {'All'};
      } else {
        _selectedCategories.remove('All');
        if (_selectedCategories.contains(category)) {
          _selectedCategories.remove(category);
          // If all categories are deselected, select 'All'
          if (_selectedCategories.isEmpty) {
            _selectedCategories = {'All'};
          }
        } else {
          _selectedCategories.add(category);
        }
      }
    });
    _fetchArticles();
  }

  void _onSearch() {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;
    
    setState(() {
      _searchQuery = query;
      // Reset categories to 'All' when searching
      _selectedCategories = {'All'};
    });
    _fetchArticles();
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
    });
    _fetchArticles();
  }
  
  // Handle navigation bar item selection
  void _onNavItemTapped(int index) {
    setState(() {
      _currentNavIndex = index;
    });
    
    // Here you would typically handle navigation to different screens
    // For now, we'll just print a message
    print('Navigated to tab $index');
    
    // Example of how you might implement actual navigation:
    // if (index != 0) { // If not Home tab
    //   Navigator.pushReplacementNamed(context, getRouteForIndex(index));
    // }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final isSmall = width < 360;

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      // Add the bottom navigation bar
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentNavIndex,
        onTap: _onNavItemTapped,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.04),
          child: RefreshIndicator(
            onRefresh: () async {
              await _fetchArticles();
            },
            child: ListView(
              children: [
                SizedBox(height: height * 0.02),
                
                // Using the new header component
                NewsHeader(
                  isSmall: isSmall,
                  showAvatar: false, // Set to true if you want to show avatar
                ),

                SizedBox(height: height * 0.03),

                // Search bar
                Container(
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
                          controller: _searchController,
                          decoration: const InputDecoration(
                            hintText: "Search news articles...",
                            border: InputBorder.none,
                          ),
                          onSubmitted: (_) => _onSearch(),
                        ),
                      ),
                      _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.grey),
                              onPressed: _clearSearch,
                            )
                          : IconButton(
                              icon: const Icon(Icons.search, color: AppColors.lightPrimary),
                              onPressed: _onSearch,
                            ),
                    ],
                  ),
                ),

                SizedBox(height: height * 0.025),

                // Categories
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _allCategories.length,
                    itemBuilder: (context, index) {
                      final category = _allCategories[index];
                      final isSelected = _selectedCategories.contains(category);

                      return GestureDetector(
                        onTap: () => _onCategoryTapped(category),
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
                ),

                SizedBox(height: height * 0.03),

                // Search active indicator
                if (_searchQuery.isNotEmpty) ...[
                  Container(
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
                            'Showing results for "$_searchQuery"',
                            style: const TextStyle(
                              color: AppColors.lightPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: _clearSearch,
                          child: const Icon(Icons.close, size: 16, color: AppColors.lightPrimary),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: height * 0.02),
                ],

                // Top Section Title (Changes based on search)
                _buildSectionHeader(
                  _searchQuery.isNotEmpty ? "Top Results" : "Top Headlines", 
                  isSmall
                ),
                SizedBox(height: height * 0.015),

                // Trending/Search Results List
                _isLoading
                    ? SizedBox(
                        height: height * 0.2,
                        child: const Center(child: CircularProgressIndicator()),
                      )
                    : FutureBuilder<List<dynamic>>(
                        future: _trendingArticles,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return SizedBox(
                              height: height * 0.2,
                              child: const Center(child: CircularProgressIndicator()),
                            );
                          } else if (snapshot.hasError) {
                            return _buildErrorWidget(height, snapshot.error.toString());
                          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return _buildEmptyStateWidget(height);
                          } else {
                            final articles = snapshot.data!;
                            return SizedBox(
                              height: height * 0.35,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: articles.length > 10 ? 10 : articles.length,
                                itemBuilder: (context, index) {
                                  final article = articles[index];
                                  return _buildTrendingCard(
                                    context,
                                    article['title'] ?? 'No title available',
                                    article['urlToImage'] ?? 'https://via.placeholder.com/300',
                                    article['source']?['name'] ?? 'Unknown source',
                                    article['publishedAt'] ?? '',
                                    article,  // Pass the full article object
                                  );
                                },
                              ),
                            );
                          }
                        },
                      ),

                SizedBox(height: height * 0.03),

                // Latest Section (Changes title based on search)
                _buildSectionHeader(
                  _searchQuery.isNotEmpty ? "More Articles" : "Latest News", 
                  isSmall
                ),
                SizedBox(height: height * 0.015),

                // Latest Cards
                _isLoading
                    ? SizedBox(
                        height: height * 0.2,
                        child: const Center(child: CircularProgressIndicator()),
                      )
                    : FutureBuilder<List<dynamic>>(
                        future: _latestArticles,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return SizedBox(
                              height: height * 0.2,
                              child: const Center(child: CircularProgressIndicator()),
                            );
                          } else if (snapshot.hasError) {
                            return _buildErrorWidget(height, snapshot.error.toString());
                          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return _buildEmptyStateWidget(height);
                          } else {
                            final articles = snapshot.data!;
                            return ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: articles.length > 8 ? 8 : articles.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final article = articles[index];
                                return _buildLatestCard(
                                  context,
                                  article['title'] ?? 'No title available',
                                  article['urlToImage'] ?? 'https://via.placeholder.com/300',
                                  article['source']?['name'] ?? 'Unknown source',
                                  article['publishedAt'] ?? '',
                                  article,  // Pass the full article object
                                );
                              },
                            );
                          }
                        },
                      ),
                
                // Add padding at the bottom to account for navigation bar
                SizedBox(height: height * 0.08),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(double height, String errorMessage) {
    return SizedBox(
      height: height * 0.2, 
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 40, color: Colors.red),
            const SizedBox(height: 8),
            const Text(
              'Failed to load articles',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              errorMessage,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
            TextButton(
              onPressed: _fetchArticles,
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyStateWidget(double height) {
    return SizedBox(
      height: height * 0.2,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.article_outlined, size: 40, color: Colors.grey),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty 
                ? 'No results found for "$_searchQuery"' 
                : 'No articles found',
              style: TextStyle(color: Colors.grey[600]),
            ),
            if (_searchQuery.isNotEmpty || !_selectedCategories.contains('All'))
              TextButton(
                onPressed: () {
                  setState(() {
                    _searchController.clear();
                    _searchQuery = '';
                    _selectedCategories = {'All'};
                  });
                  _fetchArticles();
                },
                child: const Text('Reset filters'),
              )
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isSmall) {
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
      ],
    );
  }

  Widget _buildTrendingCard(
    BuildContext context,
    String title,
    String imageUrl,
    String source,
    String publishedAt,
    dynamic article, // Full article data
  ) {
    final width = MediaQuery.of(context).size.width;
    final timeAgo = _getTimeAgo(publishedAt);
    
    return GestureDetector(
      onTap: () {
        // Directly navigate using the full article data we received
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NewsDetailScreen(article: article),
          ),
        );
      },
      child: Container(
        width: width * 0.7,
        margin: EdgeInsets.only(right: width * 0.04),
        decoration: BoxDecoration(
          color: AppColors.lightCard,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Image.network(
                imageUrl,
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 140,
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(Icons.image_not_supported, size: 40),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.lightAccent.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          source,
                          style: TextStyle(
                            color: AppColors.lightAccent,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.schedule, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(timeAgo, style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLatestCard(
    BuildContext context,
    String title,
    String imageUrl,
    String source,
    String publishedAt,
    dynamic article, // Full article data
  ) {
    final width = MediaQuery.of(context).size.width;
    final timeAgo = _getTimeAgo(publishedAt);

    return GestureDetector(
      onTap: () {
        // Directly navigate using the full article data we received
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NewsDetailScreen(article: article),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.lightCard,
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
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                width: width * 0.22,
                height: width * 0.22,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: width * 0.22,
                    height: width * 0.22,
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(Icons.image_not_supported, size: 30),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    source,
                    style: TextStyle(
                      color: AppColors.lightAccent,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.schedule, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(timeAgo, style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  String _getTimeAgo(String publishedAt) {
    if (publishedAt.isEmpty) return "Unknown time";
    
    try {
      final publishDate = DateTime.parse(publishedAt);
      final now = DateTime.now();
      final difference = now.difference(publishDate);
      
      if (difference.inDays > 0) {
        return "${difference.inDays}d ago";
      } else if (difference.inHours > 0) {
        return "${difference.inHours}h ago";
      } else if (difference.inMinutes > 0) {
        return "${difference.inMinutes}m ago";
      } else {
        return "Just now";
      }
    } catch (e) {
      return "Unknown time";
    }
  }
}