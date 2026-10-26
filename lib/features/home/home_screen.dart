import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../core/models/post.dart';
import '../../core/services/seen_repository.dart';
import '../../core/services/offline_library.dart';
import '../../core/widgets/seen_brand.dart';
import '../../core/widgets/async_state.dart';
import '../../core/theme/seen_theme.dart';
import '../articles/article_screen.dart';
import '../notifications/notifications_screen.dart';
import '../puzzle/daily_puzzle_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.repository,
    required this.offline,
  });

  final SeenRepository repository;
  final OfflineLibrary offline;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<SeenPost>> _future;

  String _category = 'الكل';

  static const List<String> _categories = [
    'الكل',
    'سياسة',
    'اقتصاد',
    'مجتمع',
    'ثقافة',
    'رأي',
    'عالم',
    'تقنية',
  ];

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<SeenPost>> _load() {
    return widget.repository.fetchPosts(
      limit: 50,
      category: _category,
    );
  }

  void _changeCategory(String value) {
    setState(() {
      _category = value;
      _future = _load();
    });
  }

  Future<void> _refresh() async {
    final future = _load();

    setState(() {
      _future = future;
    });

    await future;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _refresh,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
                child: Row(
                  children: [
                    const Expanded(
                      child: SeenBrand(),
                    ),
                    IconButton(
                      tooltip: 'الإشعارات',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => NotificationsScreen(
                              repository: widget.repository,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.notifications_none_rounded,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Editorial welcome banner.
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: SeenColors.tealDark,
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'قراءة تتجاوز العنوان',
                        style: TextStyle(
                          color: SeenColors.gold,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'ما الذي يحدث،\nولماذا يهمّك؟',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 27,
                          height: 1.3,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'مساحة للأخبار والسياق والرأي، بعيداً عن ضجيج اللحظة.',
                        style: TextStyle(
                          color: Color(0xFFD4E1DC),
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const DailyPuzzleScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.grid_4x4_rounded),
                          label: const Text('جرّب لغز اليوم'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Category selector.
            SliverToBoxAdapter(
              child: SizedBox(
                height: 48,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final value = _categories[index];
                    final selected = value == _category;

                    return ChoiceChip(
                      label: Text(value),
                      selected: selected,
                      onSelected: (_) => _changeCategory(value),
                      selectedColor: SeenColors.teal,
                      labelStyle: TextStyle(
                        color: selected ? Colors.white : SeenColors.ink,
                        fontWeight: FontWeight.w600,
                      ),
                      side: BorderSide(
                        color: selected
                            ? SeenColors.teal
                            : SeenColors.line,
                      ),
                    );
                  },
                ),
              ),
            ),

            // Section heading.
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _category == 'الكل' ? 'أحدث القصص' : _category,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                    const Text(
                      'آخر التحديثات',
                      style: TextStyle(
                        fontSize: 11,
                        color: SeenColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Articles from the API.
            FutureBuilder<List<SeenPost>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverFillRemaining(
                    child: LoadingState(),
                  );
                }

                if (snapshot.hasError) {
                  return SliverFillRemaining(
                    child: ErrorState(
                      message: snapshot.error.toString(),
                      onRetry: () {
                        setState(() {
                          _future = _load();
                        });
                      },
                    ),
                  );
                }

                final posts = snapshot.data ?? <SeenPost>[];

                if (posts.isEmpty) {
                  return const SliverFillRemaining(
                    child: EmptyState(
                      title: 'لا توجد مقالات هنا بعد',
                      subtitle: 'جرّب تصنيفاً آخر أو عد لاحقاً.',
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final post = posts[index];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _PostCard(
                            post: post,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ArticleScreen(
                                    post: post,
                                    repository: widget.repository,
                                    offline: widget.offline,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                      childCount: posts.length,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  const _PostCard({
    required this.post,
    required this.onTap,
  });

  final SeenPost post;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bodyStyle = Theme.of(context).textTheme.bodyMedium ??
        const TextStyle(
          fontSize: 14,
          height: 1.6,
          color: SeenColors.ink,
        );

    final smallStyle = Theme.of(context).textTheme.bodySmall ??
        const TextStyle(
          fontSize: 12,
          color: SeenColors.muted,
        );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (post.featuredImage.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(22),
                ),
                child: CachedNetworkImage(
                  imageUrl: post.featuredImage,
                  height: 190,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (_, _) => Container(
                    height: 190,
                    color: SeenColors.line,
                  ),
                  errorWidget: (_, _, _) => Container(
                    height: 120,
                    color: SeenColors.line,
                    child: const Icon(
                      Icons.image_not_supported_outlined,
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(17),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.category,
                    style: const TextStyle(
                      color: SeenColors.teal,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    post.title,
                    style: Theme.of(context).textTheme.titleLarge,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (post.excerpt.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      post.excerpt,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: bodyStyle.copyWith(
                        color: SeenColors.muted,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.edit_note_rounded,
                        size: 16,
                        color: SeenColors.muted,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          post.authorName,
                          style: smallStyle,
                        ),
                      ),
                      const Icon(
                        Icons.favorite_border,
                        size: 15,
                        color: SeenColors.muted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${post.likesCount}',
                        style: smallStyle,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}