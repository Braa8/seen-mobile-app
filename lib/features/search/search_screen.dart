import 'package:flutter/material.dart';

import '../../core/models/post.dart';
import '../../core/services/seen_repository.dart';
import '../../core/widgets/seen_brand.dart';
import '../../core/widgets/async_state.dart';
import '../articles/article_screen.dart';
import '../../core/services/offline_library.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({
    super.key,
    required this.repository,
  });

  final SeenRepository repository;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();

  late Future<List<SeenPost>> _future;

  String _query = '';

  @override
  void initState() {
    super.initState();
    _future = widget.repository.fetchPosts(limit: 100);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _search(String value) {
    setState(() {
      _query = value.trim();
    });
  }

  void _clearSearch() {
    _controller.clear();
    _search('');
  }

  void _retry() {
    setState(() {
      _future = widget.repository.fetchPosts(limit: 100);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 18),
            child: Row(
              children: [
                SeenBrand(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _controller,
              onChanged: _search,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'ابحث عن خبر أو موضوع...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  onPressed: _clearSearch,
                  icon: const Icon(Icons.close),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
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
                    onRetry: _retry,
                  );
                }

                final all = snapshot.data ?? <SeenPost>[];

                final normalizedQuery = _query.toLowerCase();

                final results = _query.isEmpty
                    ? <SeenPost>[]
                    : all.where((post) {
                        final searchable =
                            '${post.title} '
                            '${post.excerpt} '
                            '${post.category} '
                            '${post.authorName} '
                            '${post.tags.join(' ')}';

                        return searchable
                            .toLowerCase()
                            .contains(normalizedQuery);
                      }).toList();

                if (_query.isEmpty) {
                  return const EmptyState(
                    title: 'ابدأ بكلمة مفتاحية',
                    subtitle:
                        'ابحث في العناوين والملخصات والتصنيفات.',
                    icon: Icons.manage_search_rounded,
                  );
                }

                if (results.isEmpty) {
                  return const EmptyState(
                    title: 'لم نعثر على نتائج',
                    subtitle: 'جرّب كلمة أقصر أو مختلفة.',
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: results.length,
                  separatorBuilder: (_, _) {
                    return const Divider(height: 22);
                  },
                  itemBuilder: (context, index) {
                    final post = results[index];

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        post.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      subtitle: Text(
                        '${post.category} • ${post.authorName}',
                        maxLines: 1,
                      ),
                      trailing: const Icon(Icons.chevron_left),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ArticleScreen(
                              post: post,
                              repository: widget.repository,
                              offline: OfflineLibrary(),
                            ),
                          ),
                        );
                      },
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