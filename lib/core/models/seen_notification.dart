class SeenNotification {
  const SeenNotification({required this.id, required this.title, required this.message, required this.read, this.postId, this.type = 'general', this.createdAt});

  final String id;
  final String title;
  final String message;
  final bool read;
  final String? postId;
  final String type;
  final DateTime? createdAt;

  factory SeenNotification.fromJson(Map<String, dynamic> json) {
    final rawDate = json['createdAt'];
    DateTime? date;
    if (rawDate is String) date = DateTime.tryParse(rawDate);
    if (rawDate is Map && rawDate['_seconds'] is num) {
      date = DateTime.fromMillisecondsSinceEpoch((rawDate['_seconds'] as num).toInt() * 1000, isUtc: true);
    }
    return SeenNotification(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? 'إشعار جديد').toString(),
      message: (json['message'] ?? '').toString(),
      read: json['read'] == true,
      postId: json['postId']?.toString(),
      type: (json['type'] ?? 'general').toString(),
      createdAt: date,
    );
  }
}
