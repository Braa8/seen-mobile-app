import 'package:flutter/material.dart';

import '../../core/models/post.dart';
import '../../core/services/seen_repository.dart';
import '../../core/services/offline_library.dart';
import '../../core/widgets/async_state.dart';
import '../../core/theme/seen_theme.dart';
import '../../core/services/session_service.dart';
import '../articles/article_screen.dart';
import '../auth/login_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({
    super.key,
    required this.repository,
  });

  final SeenRepository repository;

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late Future<List<SeenPost>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<SeenPost>> _load() {
    return widget.repository.fetchFavorites();
  }

  @override
  Widget build(BuildContext context) {
    if (!SessionService.instance.isSignedIn) {
      return const _SignInPrompt();
    }

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 14),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'مقالاتك المختارة',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _future = _load();
                    });
                  },
                  icon: const Icon(Icons.refresh),
                ),
              ],
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
                    onRetry: () {
                      setState(() {
                        _future = _load();
                      });
                    },
                  );
                }

                final posts = snapshot.data ?? <SeenPost>[];

                if (posts.isEmpty) {
                  return const EmptyState(
                    title: 'مساحتك ما زالت فارغة',
                    subtitle: 'احفظ المقالات التي تريد العودة إليها.',
                    icon: Icons.bookmark_border,
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: posts.length,
                  separatorBuilder: (_, _) {
                    return const SizedBox(height: 10);
                  },
                  itemBuilder: (context, index) {
                    final post = posts[index];

                    return Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(10),
                        title: Text(
                          post.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        subtitle: Text(post.category),
                        trailing: const Icon(Icons.chevron_left),
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ArticleScreen(
                                post: post,
                                repository: widget.repository,
                                offline: OfflineLibrary(),
                              ),
                            ),
                          );

                          if (mounted) {
                            setState(() {
                              _future = _load();
                            });
                          }
                        },
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

class _SignInPrompt extends StatelessWidget {
  const _SignInPrompt();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.lock_outline_rounded,
              size: 46,
              color: SeenColors.teal,
            ),
            const SizedBox(height: 12),
            Text(
              'المفضلة مرتبطة بحسابك',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'سجّل الدخول لمزامنة مقالاتك بين الأجهزة.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LoginScreen(),
                  ),
                );
              },
              child: const Text('تسجيل الدخول'),
            ),
          ],
        ),
      ),
    );
  }
}