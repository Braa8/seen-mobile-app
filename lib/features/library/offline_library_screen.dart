import 'package:flutter/material.dart';

import '../../core/models/post.dart';
import '../../core/services/offline_library.dart';
import '../../core/services/seen_repository.dart';
import '../../core/services/api_client.dart';
import '../../core/widgets/async_state.dart';
import '../../core/theme/seen_theme.dart';
import '../articles/article_screen.dart';

class OfflineLibraryScreen extends StatefulWidget {
  const OfflineLibraryScreen({
    super.key,
    required this.offline,
  });

  final OfflineLibrary offline;

  @override
  State<OfflineLibraryScreen> createState() =>
      _OfflineLibraryScreenState();
}

class _OfflineLibraryScreenState extends State<OfflineLibraryScreen> {
  late Future<List<SeenPost>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.offline.all();
  }

  void _refresh() {
    setState(() {
      _future = widget.offline.all();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 14),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'مكتبة القراءة',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
                IconButton(
                  onPressed: _refresh,
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 14),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                'المقالات المحفوظة محلياً على هذا الجهاز',
                style: TextStyle(
                  color: SeenColors.muted,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<SeenPost>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const LoadingState();
                }

                if (snapshot.hasError) {
                  return ErrorState(
                    message: snapshot.error.toString(),
                    onRetry: _refresh,
                  );
                }

                final posts = snapshot.data ?? <SeenPost>[];

                if (posts.isEmpty) {
                  return const EmptyState(
                    title: 'لا توجد مقالات محفوظة',
                    subtitle:
                        'افتح أي مقال واضغط «للقراءة» لتحتفظ بنسخة نصية على جهازك.',
                    icon: Icons.download_for_offline_outlined,
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: posts.length,
                  separatorBuilder: (_, _) {
                    return const SizedBox(height: 8);
                  },
                  itemBuilder: (context, index) {
                    final post = posts[index];

                    return Card(
                      child: ListTile(
                        title: Text(
                          post.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        subtitle: Text(post.category),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ArticleScreen(
                                post: post,
                                repository: SeenRepository(ApiClient()),
                                offline: widget.offline,
                              ),
                            ),
                          );
                        },
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () async {
                            await widget.offline.remove(post.id);

                            if (mounted) {
                              _refresh();
                            }
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}