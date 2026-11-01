
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

/// Returns the featured image when available.
/// Otherwise, extracts the first image URL from the article HTML.
String _imageForPost(SeenPost post) {
  final featured = post.featuredImage.trim();

  if (featured.isNotEmpty) {
    return featured;
  }

  final content = post.content;

  // Extract the src attribute from the first HTML img element.
  final match = RegExp(
    r'<img\b[^>]*?\bsrc\s*=\s*(["\x27])(.*?)\1',
    caseSensitive: false,
    dotAll: true,
  ).firstMatch(content);

  final rawUrl = match?.group(2)?.trim();

  if (rawUrl == null || rawUrl.isEmpty) {
    return '';
  }

  // Decode the most common HTML entity found in image URLs.
  final imageUrl = rawUrl.replaceAll('&amp;', '&');

  final uri = Uri.tryParse(imageUrl);

  if (uri == null || !uri.hasAuthority) {
    return '';
  }

  if (uri.scheme != 'http' && uri.scheme != 'https') {
    return '';
  }

  return imageUrl;
}

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

  Future<List<SeenPost>> _load() async {
  final posts = await widget.repository.fetchPosts(
    limit: 50,
    category: _category,
  );

  for (final post in posts) {
    debugPrint('ARTICLE: ${post.title}');
    debugPrint('FEATURED IMAGE: ${post.featuredImage}');
    debugPrint('CONTENT LENGTH: ${post.content.length}');

    final imageIndex = post.content.toLowerCase().indexOf('<img');

    if (imageIndex >= 0) {
      final start = imageIndex > 100 ? imageIndex - 100 : 0;
      final end = (imageIndex + 500).clamp(0, post.content.length);

      debugPrint(
        'IMAGE HTML: ${post.content.substring(start, end)}',
      );
    } else {
      debugPrint('NO IMG TAG FOUND IN CONTENT');
    }

    debugPrint('EXTRACTED IMAGE: ${_imageForPost(post)}');
  }

  return posts;
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

  void _openArticle(SeenPost post) {
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
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _refresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Header.
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
                        color: SeenColors.blue,
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
                    color: const Color.fromARGB(255, 193, 191, 186),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: SeenColors.line),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.auto_stories_rounded,
                            size: 17,
                            color: SeenColors.olive,
                          ),
                          SizedBox(width: 7),
                          Text(
                            'قراءة تتجاوز العنوان',
                            style: TextStyle(
                              color: SeenColors.olive,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'ما الذي يحدث،\nولماذا يهمّك؟',
                        style: TextStyle(
                          color: SeenColors.blue,
                          fontSize: 27,
                          height: 1.3,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'مساحة للأخبار والسياق والرأي، بعيداً عن ضجيج اللحظة.',
                        style: TextStyle(
                          color: SeenColors.muted,
                          height: 1.7,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: FilledButton.tonalIcon(
                          style: FilledButton.styleFrom(
                            foregroundColor: SeenColors.blue,
                            backgroundColor:
                                SeenColors.blue.withValues(alpha: 0.09),
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
                      selectedColor: SeenColors.blue,
                      backgroundColor: SeenColors.card,
                      labelStyle: TextStyle(
                        color: selected ? Colors.white : SeenColors.ink,
                        fontWeight: FontWeight.w600,
                      ),
                      side: BorderSide(
                        color: selected
                            ? SeenColors.blue
                            : SeenColors.line,
                      ),
                    );
                  },
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

                // Include articles with either a featured or inline image.
                final featuredPosts = posts
                    .where((post) => _imageForPost(post).isNotEmpty)
                    .take(5)
                    .toList();

                return SliverMainAxisGroup(
                  slivers: [
                    // Featured articles carousel.
                    if (featuredPosts.isNotEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 22),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  20,
                                  0,
                                  20,
                                  12,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'مختارات سين',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineMedium,
                                      ),
                                    ),
                                    const Text(
                                      'قصص تستحق القراءة',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: SeenColors.muted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              _FeaturedCarousel(
                                posts: featuredPosts,
                                onTap: _openArticle,
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Latest articles heading.
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          20,
                          28,
                          20,
                          14,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _category == 'الكل'
                                    ? 'أحدث القصص'
                                    : _category,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium,
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

                    // Articles list.
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                        20,
                        0,
                        20,
                        30,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final post = posts[index];

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: _PostCard(
                                post: post,
                                onTap: () => _openArticle(post),
                              ),
                            );
                          },
                          childCount: posts.length,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Featured articles carousel.
class _FeaturedCarousel extends StatefulWidget {
  const _FeaturedCarousel({
    required this.posts,
    required this.onTap,
  });

  final List<SeenPost> posts;
  final ValueChanged<SeenPost> onTap;

  @override
  State<_FeaturedCarousel> createState() => _FeaturedCarouselState();
}

class _FeaturedCarouselState extends State<_FeaturedCarousel> {
  late final PageController _controller;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.90);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _moveTo(int page) {
    if (page < 0 || page >= widget.posts.length) {
      return;
    }

    _controller.animateToPage(
      page,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.posts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        SizedBox(
          height: 265,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PageView.builder(
                controller: _controller,
                itemCount: widget.posts.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final post = widget.posts[index];
                  final imageUrl = _imageForPost(post);

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: GestureDetector(
                      onTap: () => widget.onTap(post),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            CachedNetworkImage(
                              imageUrl: imageUrl,
                              fit: BoxFit.cover,
                              placeholder: (_, _) => Container(
                                color: SeenColors.line,
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: SeenColors.blue,
                                  ),
                                ),
                              ),
                              errorWidget: (_, _, _) => Container(
                                color: SeenColors.line,
                                child: const Icon(
                                  Icons.image_not_supported_outlined,
                                  size: 36,
                                  color: SeenColors.muted,
                                ),
                              ),
                            ),

                            // Gradient behind the article title.
                            const DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Color(0x44000000),
                                    Color(0xE6000000),
                                  ],
                                  stops: [0.20, 0.55, 1],
                                ),
                              ),
                            ),

                            // Article information.
                            Positioned(
                              right: 20,
                              left: 20,
                              bottom: 20,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: SeenColors.olive,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      post.category,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    post.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 21,
                                      height: 1.4,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 7),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.edit_note_rounded,
                                        size: 16,
                                        color: Color(0xFFE5E5E5),
                                      ),
                                      const SizedBox(width: 5),
                                      Expanded(
                                        child: Text(
                                          post.authorName,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Color(0xFFE5E5E5),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      const Icon(
                                        Icons.arrow_back_rounded,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),

              // Navigation arrows.
              if (widget.posts.length > 1) ...[
                Positioned(
                  right: 10,
                  child: _CarouselArrow(
                    icon: Icons.chevron_right_rounded,
                    onTap: () => _moveTo(_currentPage + 1),
                  ),
                ),
                Positioned(
                  left: 10,
                  child: _CarouselArrow(
                    icon: Icons.chevron_left_rounded,
                    onTap: () => _moveTo(_currentPage - 1),
                  ),
                ),
              ],
            ],
          ),
        ),

        // Page indicators.
        if (widget.posts.length > 1) ...[
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.posts.length,
              (index) {
                final selected = index == _currentPage;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: selected ? 22 : 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: selected
                        ? SeenColors.blue
                        : SeenColors.olive.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(10),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

// Carousel navigation arrow.
class _CarouselArrow extends StatelessWidget {
  const _CarouselArrow({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.94),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 38,
          height: 38,
          child: Icon(
            icon,
            color: SeenColors.blue,
            size: 25,
          ),
        ),
      ),
    );
  }
}

// Regular article card.
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

    final imageUrl = _imageForPost(post);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(22),
                ),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
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
                      color: SeenColors.olive,
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
