class SeenPost {
  const SeenPost({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.excerpt,
    required this.authorName,
    required this.featuredImage,
    required this.createdAt,
    required this.likesCount,
    required this.viewsCount,
    this.tags = const [],
  });

  final String id;
  final String title;
  final String content;
  final String category;
  final String excerpt;
  final String authorName;
  final String featuredImage;
  final DateTime? createdAt;
  final int likesCount;
  final int viewsCount;
  final List<String> tags;

  factory SeenPost.fromJson(Map<String, dynamic> json) {
    final stats = json['stats'] is Map ? Map<String, dynamic>.from(json['stats'] as Map) : <String, dynamic>{};
    final rawDate = json['createdAt'] ?? json['publishedAt'];
    DateTime? date;
    if (rawDate is String) date = DateTime.tryParse(rawDate);
    if (rawDate is Map && rawDate['_seconds'] is num) {
      date = DateTime.fromMillisecondsSinceEpoch((rawDate['_seconds'] as num).toInt() * 1000, isUtc: true);
    }
    final rawTags = json['tags'];
    return SeenPost(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? 'بدون عنوان').toString(),
      content: (json['content'] ?? '').toString(),
      category: (json['category'] ?? 'عام').toString(),
      excerpt: (json['excerpt'] ?? '').toString(),
      authorName: (json['authorName'] ?? 'فريق سين').toString(),
      featuredImage: (json['featuredImage'] ?? '').toString(),
      createdAt: date,
      likesCount: _toInt(stats['likes'] ?? json['likesCount']),
      viewsCount: _toInt(stats['views'] ?? json['viewsCount']),
      tags: rawTags is List ? rawTags.map((e) => e.toString()).toList() : const [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id, 'title': title, 'content': content, 'category': category,
    'excerpt': excerpt, 'authorName': authorName, 'featuredImage': featuredImage,
    'createdAt': createdAt?.toIso8601String(), 'likesCount': likesCount,
    'viewsCount': viewsCount, 'tags': tags,
  };

  static int _toInt(dynamic value) => value is num ? value.toInt() : int.tryParse('$value') ?? 0;
}
