// lib/app/models/article.dart
class Article {
  final String title;
  final String? urlToImage;
  final Map<String, dynamic>? source;
  final String? publishedAt;
  final String? content;
  final String? description;
  final String? author;
  final String? url;

  Article({
    required this.title,
    this.urlToImage,
    this.source,
    this.publishedAt,
    this.content,
    this.description,
    this.author,
    this.url,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      title: json['title'] ?? 'No title available',
      urlToImage: json['urlToImage'] ?? 'https://via.placeholder.com/300',
      source: json['source'],
      publishedAt: json['publishedAt'] ?? '',
      content: json['content'],
      description: json['description'],
      author: json['author'],
      url: json['url'],
    );
  }

  // Convert article to map for easy manipulation if needed
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'urlToImage': urlToImage,
      'source': source,
      'publishedAt': publishedAt,
      'content': content,
      'description': description,
      'author': author,
      'url': url,
    };
  }

  // Get source name safely
  String getSourceName() {
    return source?['name'] ?? 'Unknown source';
  }
}