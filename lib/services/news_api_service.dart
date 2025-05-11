// lib/services/news_api_service.dart
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../app/models/article.dart';

class NewsApiService {
  final String apiKey;
  final String baseUrl;

  NewsApiService()
      : apiKey = dotenv.env['API_KEY'] ?? '',
        baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  // Fetch trending articles (top headlines)
  Future<List<Article>> fetchTrendingArticles() async {
    final String url = '${baseUrl}top-headlines?country=us&apiKey=$apiKey';
    return _fetchArticlesFromUrl(url);
  }

  // Fetch articles by categories
  Future<List<Article>> fetchArticles({
    List<String>? categories,
  }) async {
    if (categories == null || categories.isEmpty) {
      return fetchTrendingArticles();
    }

    // Join categories with OR operator for the API
    final String categoriesParam = categories.join(' OR ').toLowerCase();
    final String url = '${baseUrl}top-headlines?q=$categoriesParam&apiKey=$apiKey';
    return _fetchArticlesFromUrl(url);
  }

  // Fetch articles based on search query
  Future<List<Article>> fetchSearchArticles(String query) async {
    if (query.isEmpty) return [];

    final String url = '${baseUrl}everything?q=$query&apiKey=$apiKey';
    return _fetchArticlesFromUrl(url);
  }

  // Fetch articles with keyword
  Future<List<Article>> fetchKeywordArticles() async {
    final String url = '${baseUrl}everything?q=keyword&apiKey=$apiKey';
    return _fetchArticlesFromUrl(url);
  }

  // Common method to fetch articles from URL
  Future<List<Article>> _fetchArticlesFromUrl(String url) async {
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final articlesList = data['articles'] as List;
        return articlesList.map((article) => Article.fromJson(article)).toList();
      } else {
        print('API Error: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Exception in _fetchArticlesFromUrl: $e');
      return [];
    }
  }
}