import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class NewsApiService {
  final String _apiKey = dotenv.env['API_KEY']!;
  final String _baseUrl = dotenv.env['API_BASE_URL']!;
  
  // Map app categories to NewsAPI categories
  final Map<String, String> _categoryMapping = {
    'general': 'general',
    'business': 'business',
    'sports': 'sports', 
    'food': 'health', 
    'tech': 'technology',
    'finance': 'business', // Map finance to business
    'crypto': 'business',  // Map crypto to business
  };

  // Main method to fetch articles by search query
  Future<List<dynamic>> fetchArticlesBySearch(String searchQuery) async {
    try {
      final Uri url = Uri.parse('$_baseUrl/everything');
      
      final Map<String, String> queryParams = {
        'apiKey': _apiKey,
        'q': searchQuery,
        'pageSize': '20',
        'sortBy': 'publishedAt',
      };
      
      final response = await http.get(
        url.replace(queryParameters: queryParams),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['articles'] ?? [];
      } else {
        print('API Error for search: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Exception in fetchArticlesBySearch: $e');
      return [];
    }
  }

  // Fetch articles based on search query and/or categories
  Future<List<dynamic>> fetchArticles({
    String? searchQuery, 
    List<String>? categories,
  }) async {
    try {
      // If there's a search query, prioritize it
      if (searchQuery?.isNotEmpty == true) {
        return fetchArticlesBySearch(searchQuery!);
      }
      
      // Default to general if no category is specified
      final effectiveCategories = (categories?.isNotEmpty == true) 
          ? categories!
          : ['general'];
      
      // Initialize an empty list to store all articles
      List<dynamic> allArticles = [];
      
      // Make API requests for each category
      for (final category in effectiveCategories) {
        String newsApiCategory = _categoryMapping[category.toLowerCase()] ?? 'general';
        
        final Map<String, String> queryParams = {
          'apiKey': _apiKey,
          'pageSize': '20',
        };
        
        Uri url = Uri.parse('$_baseUrl/top-headlines');
        queryParams['category'] = newsApiCategory;
        queryParams['country'] = 'us'; 
        
        final response = await http.get(
          url.replace(queryParameters: queryParams),
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final articles = data['articles'] as List;
          
          for (var article in articles) {
            if (article is Map) {
              article['category'] = category;
            }
          }
          
          allArticles.addAll(articles);
        } else {
          print('API Error for category $category: ${response.statusCode} - ${response.body}');
        }
      }
      
      // Sort by published date (newest first)
      allArticles.sort((a, b) {
        final dateA = a['publishedAt'] ?? '';
        final dateB = b['publishedAt'] ?? '';
        return dateB.compareTo(dateA);
      });
      
      // Remove duplicates based on title
      final seen = <String>{};
      allArticles = allArticles.where((article) {
        final title = article['title'] ?? '';
        final duplicate = seen.contains(title);
        seen.add(title);
        return !duplicate;
      }).toList();
      
      return allArticles;
    } catch (e) {
      print('Exception in fetchArticles: $e');
      throw Exception('Failed to load articles: $e');
    }
  }
  
  // Helper method to fetch trending articles
  Future<List<dynamic>> fetchTrendingArticles() async {
    try {
      final url = Uri.parse('$_baseUrl/top-headlines');
      final response = await http.get(
        url.replace(queryParameters: {
          'apiKey': _apiKey,
          'country': 'us',
          'pageSize': '20',
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['articles'] ?? [];
      } else {
        throw Exception('Failed to load trending articles');
      }
    } catch (e) {
      print('Exception in fetchTrendingArticles: $e');
      return [];
    }
  }
  
  // Helper method to fetch articles by single category
  Future<List<dynamic>> fetchArticlesByCategory(String category) async {
    if (category.toLowerCase() == 'all') {
      return fetchTrendingArticles();
    }
    
    try {
      String newsApiCategory = _categoryMapping[category.toLowerCase()] ?? 'general';
      
      final url = Uri.parse('$_baseUrl/top-headlines');
      final response = await http.get(
        url.replace(queryParameters: {
          'apiKey': _apiKey,
          'category': newsApiCategory,
          'country': 'us',
          'pageSize': '20',
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final articles = data['articles'] ?? [];
        
        // Add category to each article
        for (var article in articles) {
          if (article is Map) {
            article['category'] = category;
          }
        }
        
        return articles;
      } else {
        throw Exception('Failed to load articles for category: $category');
      }
    } catch (e) {
      print('Exception in fetchArticlesByCategory: $e');
      return [];
    }
  }
}