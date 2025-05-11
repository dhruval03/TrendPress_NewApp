// lib/app/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:trend_press/app/components/BottomNavigationBar.dart';
import 'package:trend_press/app/components/empty_state_widget.dart';
import 'package:trend_press/app/components/error_widget.dart';
import 'package:trend_press/app/components/greeting_header.dart';
import 'package:trend_press/app/components/home/category_selector.dart';
import 'package:trend_press/app/components/home/latest_article_card.dart';
import 'package:trend_press/app/components/home/search_bar.dart';
import 'package:trend_press/app/components/home/section_header.dart';
import 'package:trend_press/app/components/home/trending_article_card.dart';
import 'package:trend_press/app/theme/colors.dart';
import 'package:trend_press/app/views/home/NewsDetailScreen.dart';
import '../../../services/news_api_service.dart';
import '../../utils/constants.dart';
import '../../models/article.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final NewsApiService _newsApiService = NewsApiService();
  final TextEditingController _searchController = TextEditingController();

  late Future<List<Article>> _trendingArticles;
  late Future<List<Article>> _latestArticles;
  
  // Navigation bar state
  int _currentNavIndex = 0;

  final List<String> _allCategories = NewsCategories.all;
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
    _searchController.dispose(); 
    super.dispose();
  }

  Future<void> _fetchArticles() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (_searchQuery.isNotEmpty) {
        _trendingArticles = _newsApiService.fetchSearchArticles(_searchQuery);
        _latestArticles = _newsApiService.fetchSearchArticles(_searchQuery);
      } else if (_selectedCategories.contains('All')) {
        _trendingArticles = _newsApiService.fetchTrendingArticles();
        _latestArticles = _newsApiService.fetchKeywordArticles();
      } else {
        List<String> categories = _selectedCategories.toList();
        
        _trendingArticles = _newsApiService.fetchArticles(
          categories: categories,
        );
        
        _latestArticles = _newsApiService.fetchKeywordArticles();
      }
    } catch (e) {
      print('Error fetching articles: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
  
  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _selectedCategories = {'All'};
    });
    _fetchArticles();
  }
  
  // Handle navigation bar item selection
  void _onNavItemTapped(int index) {
    setState(() {
      _currentNavIndex = index;
    });
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
                
                // Greeting header
                NewsHeader(
                  isSmall: isSmall,
                  showAvatar: false, 
                ),

                SizedBox(height: height * 0.03),

                // Search bar
                NewsSearchBar(
                  controller: _searchController,
                  onSearch: _onSearch,
                  onClear: _clearSearch,
                ),

                SizedBox(height: height * 0.025),

                // Categories
                CategorySelector(
                  categories: _allCategories,
                  selectedCategories: _selectedCategories,
                  onCategoryTapped: _onCategoryTapped,
                  isSmall: isSmall,
                ),

                SizedBox(height: height * 0.03),

                // Search active indicator
                if (_searchQuery.isNotEmpty) ...[
                  SearchActiveIndicator(
                    searchQuery: _searchQuery,
                    onClear: _clearSearch,
                  ),
                  SizedBox(height: height * 0.02),
                ],

                // Top Section Title
                SectionHeader(
                  title: _searchQuery.isNotEmpty ? "Top Results" : "Top Headlines",
                  isSmall: isSmall,
                ),
                
                SizedBox(height: height * 0.015),

                // Trending articles section
                _isLoading
                    ? SizedBox(
                        height: height * 0.2,
                        child: const Center(child: CircularProgressIndicator()),
                      )
                    : FutureBuilder<List<Article>>(
                        future: _trendingArticles,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return SizedBox(
                              height: height * 0.2,
                              child: const Center(child: CircularProgressIndicator()),
                            );
                          } else if (snapshot.hasError) {
                            return NewsErrorWidget(
                              height: height * 0.2,
                              errorMessage: snapshot.error.toString(),
                              onRetry: _fetchArticles,
                            );
                          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return EmptyStateWidget(
                              height: height,
                              searchQuery: _searchQuery,
                              onResetFilters: _resetFilters,
                              showResetButton: _searchQuery.isNotEmpty || 
                                              !_selectedCategories.contains('All'),
                            );
                          } else {
                            final articles = snapshot.data!;
                            return SizedBox(
                              height: height * 0.35,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: articles.length > 10 ? 10 : articles.length,
                                itemBuilder: (context, index) {
                                  final article = articles[index];
                                  return TrendingArticleCard(
                                    article: article,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => NewsDetailScreen(
                                            articleData: article.toJson(),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            );
                          }
                        },
                      ),

                SizedBox(height: height * 0.03),

                // Latest Section
                SectionHeader(
                  title: _searchQuery.isNotEmpty ? "More Articles" : "Latest News",
                  isSmall: isSmall,
                ),
                
                SizedBox(height: height * 0.015),

                // Latest Cards
                _isLoading
                    ? SizedBox(
                        height: height * 0.2,
                        child: const Center(child: CircularProgressIndicator()),
                      )
                    : FutureBuilder<List<Article>>(
                        future: _latestArticles,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return SizedBox(
                              height: height * 0.2,
                              child: const Center(child: CircularProgressIndicator()),
                            );
                          } else if (snapshot.hasError) {
                            return NewsErrorWidget(
                              height: height * 0.2,
                              errorMessage: snapshot.error.toString(),
                              onRetry: _fetchArticles,
                            );
                          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return EmptyStateWidget(
                              height: height,
                              searchQuery: _searchQuery,
                              onResetFilters: _resetFilters,
                              showResetButton: _searchQuery.isNotEmpty || 
                                              !_selectedCategories.contains('All'),
                            );
                          } else {
                            final articles = snapshot.data!;
                            return ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: articles.length > 8 ? 8 : articles.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final article = articles[index];
                                return LatestArticleCard(
                                  article: article,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => NewsDetailScreen(
                                          articleData: article.toJson(),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          }
                        },
                      ),
                
                SizedBox(height: height * 0.08),
              ],
            ),
          ),
        ),
      ),
    );
  }
}