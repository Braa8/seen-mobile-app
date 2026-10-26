import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/post.dart';

class OfflineLibrary {
  static const _fileName = 'seen_offline_articles.json';

  Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }

  Future<List<SeenPost>> all() async {
    try {
      final file = await _file();
      if (!await file.exists()) return [];
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is! List) return [];
      return decoded.whereType<Map>().map((e) => SeenPost.fromJson(Map<String, dynamic>.from(e))).toList();
    } catch (_) { return []; }
  }

  Future<void> save(SeenPost post) async {
    final items = await all();
    final updated = [post, ...items.where((p) => p.id != post.id)];
    final file = await _file();
    await file.writeAsString(jsonEncode(updated.map((p) => p.toJson()).toList()), flush: true);
  }

  Future<void> remove(String id) async {
    final items = await all();
    final file = await _file();
    await file.writeAsString(jsonEncode(items.where((p) => p.id != id).map((p) => p.toJson()).toList()), flush: true);
  }

  Future<bool> contains(String id) async => (await all()).any((p) => p.id == id);
}
