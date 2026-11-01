import '../models/post.dart';
import '../models/seen_notification.dart';
import 'api_client.dart';

class SeenRepository {
  SeenRepository(this.api);
  final ApiClient api;

  Future<List<SeenPost>> fetchPosts({int limit = 30, String? category}) async {
    final params = <String, String>{'limit': '$limit'};

    if (category != null && category.isNotEmpty && category != 'الكل') {
      params['category'] = category;
    }

    final data = await api.get(
      '/api/posts?${Uri(queryParameters: params).query}',
    );

    final list = data['posts'];

    if (list is! List) {
      return [];
    }

    return list
        .whereType<Map>()
        .map((e) => SeenPost.fromJson(Map<String, dynamic>.from(e)))
        .where((post) => post.id.isNotEmpty)
        .toList();
  }

  Future<SeenPost> fetchPost(String id) async {
    final data = await api.get('/api/posts/${Uri.encodeComponent(id)}');
    final post = data['post'];
    if (post is! Map) throw ApiException('استجابة المقال غير متوقعة');
    return SeenPost.fromJson(Map<String, dynamic>.from(post));
  }

  Future<List<SeenPost>> fetchFavorites() async {
    final data = await api.get('/api/favorites', authenticated: true);
    final list = data['favorites'];
    if (list is! List) return [];
    return list
        .whereType<Map>()
        .map((e) => SeenPost.fromJson(Map<String, dynamic>.from(e)))
        .where((p) => p.id.isNotEmpty)
        .toList();
  }

  Future<void> addFavorite(String id) async =>
      api.post('/api/favorites', authenticated: true, body: {'postId': id});
  Future<void> removeFavorite(String id) async =>
      api.delete('/api/favorites', authenticated: true, body: {'postId': id});

  Future<LikeResult> getLike(String id) async {
    final data = await api.get('/api/posts/${Uri.encodeComponent(id)}/like');
    return LikeResult(
      liked: data['liked'] == true,
      count: _int(data['likesCount']),
    );
  }

  Future<LikeResult> toggleLike(String id) async {
    final data = await api.post(
      '/api/posts/${Uri.encodeComponent(id)}/like',
      authenticated: true,
    );
    return LikeResult(
      liked: data['liked'] == true,
      count: _int(data['likesCount']),
    );
  }

  Future<List<SeenNotification>> fetchNotifications() async {
    final data = await api.get('/api/notifications', authenticated: true);
    final list = data['notifications'];
    if (list is! List) return [];
    return list
        .whereType<Map>()
        .map((e) => SeenNotification.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> markNotificationRead(String id) async =>
      api.put('/api/notifications', authenticated: true, body: {'id': id});
  Future<int> clearReadNotifications() async {
    final data = await api.delete('/api/notifications', authenticated: true);
    return _int(data['deleted']);
  }

  static int _int(dynamic value) =>
      value is num ? value.toInt() : int.tryParse('$value') ?? 0;
}

class LikeResult {
  const LikeResult({required this.liked, required this.count});
  final bool liked;
  final int count;
}
