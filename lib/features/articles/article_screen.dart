import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/models/post.dart';
import '../../core/services/seen_repository.dart';
import '../../core/services/offline_library.dart';
import '../../core/services/session_service.dart';
import '../../core/theme/seen_theme.dart';
import '../../core/widgets/async_state.dart';

class ArticleScreen extends StatefulWidget {
  const ArticleScreen({
    super.key,
    required this.post,
    required this.repository,
    required this.offline,
  });

  final SeenPost post;
  final SeenRepository repository;
  final OfflineLibrary offline;

  @override
  State<ArticleScreen> createState() => _ArticleScreenState();
}

class _ArticleScreenState extends State<ArticleScreen> {
  late SeenPost _post = widget.post;

  bool _loading = false;
  bool _liked = false;
  bool _saved = false;
  bool _favorite = false;

  int _likes = 0;

  @override
  void initState() {
    super.initState();
    _likes = _post.likesCount;
    _refresh();
  }

  Future<void> _refresh() async {
    try {
      final fresh = await widget.repository.fetchPost(_post.id);
      final like = await widget.repository.getLike(_post.id);
      final saved = await widget.offline.contains(_post.id);

      if (!mounted) return;

      setState(() {
        _post = fresh;
        _liked = like.liked;
        _likes = like.count;
        _saved = saved;
      });
    } catch (_) {
      // نبقي المقال متاحاً حتى لو تعذر تحديث بياناته.
    }
  }

  Future<void> _toggleLike() async {
    if (!SessionService.instance.isSignedIn) {
      _message('سجّل الدخول للإعجاب بالمقال');
      return;
    }

    setState(() => _loading = true);

    try {
      final result = await widget.repository.toggleLike(_post.id);

      if (mounted) {
        setState(() {
          _liked = result.liked;
          _likes = result.count;
        });
      }
    } catch (e) {
      _message(e.toString());
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _toggleFavorite() async {
    if (!SessionService.instance.isSignedIn) {
      _message('سجّل الدخول لحفظ المقال في المفضلة');
      return;
    }

    setState(() => _loading = true);

    try {
      final wasFavorite = _favorite;

      if (wasFavorite) {
        await widget.repository.removeFavorite(_post.id);
      } else {
        await widget.repository.addFavorite(_post.id);
      }

      if (!mounted) return;

      setState(() {
        _favorite = !wasFavorite;
      });

      _message(
        _favorite ? 'أُضيف إلى المفضلة' : 'أُزيل من المفضلة',
      );
    } catch (e) {
      _message(e.toString());
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _toggleOffline() async {
    if (!SessionService.instance.isSignedIn) {
      _message('سجّل الدخول لحفظ المقال للقراءة دون اتصال');
      return;
    }

    try {
      final wasSaved = _saved;

      if (wasSaved) {
        await widget.offline.remove(_post.id);
      } else {
        await widget.offline.save(_post);
      }

      if (!mounted) return;

      setState(() {
        _saved = !wasSaved;
      });

      _message(
        _saved ? 'حُفظ للقراءة دون اتصال' : 'أُزيل من مكتبة القراءة',
      );
    } catch (e) {
      _message(e.toString());
    }
  }

  void _message(String text) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: const Color.fromARGB(255, 140, 137, 128),
            title: const Text('سين'),
            actions: [
              IconButton(
                onPressed: () {
                  SharePlus.instance.share(
                    ShareParams(
                      text: '${_post.title}\n\n${_post.excerpt}',
                    ),
                  );
                },
                icon: const Icon(Icons.ios_share_rounded),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _post.category,
                    style: const TextStyle(
                      color: SeenColors.teal,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _post.title,
                    style: textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.edit_note_rounded,
                        size: 18,
                        color: SeenColors.muted,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          _post.authorName,
                          style: textTheme.bodySmall,
                        ),
                      ),
                      if (_post.createdAt != null)
                        Text(
                          '${_post.createdAt!.year}/'
                          '${_post.createdAt!.month}/'
                          '${_post.createdAt!.day}',
                          style: textTheme.bodySmall,
                        ),
                    ],
                  ),
                  if (_post.featuredImage.isNotEmpty) ...[
                    const SizedBox(height: 22),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: CachedNetworkImage(
                        imageUrl: _post.featuredImage,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (_, _) => const SizedBox(
                          height: 190,
                          child: LoadingState(),
                        ),
                        errorWidget: (_, _, _) => const SizedBox(
                          height: 100,
                          child: Icon(
                            Icons.image_not_supported_outlined,
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 22),
                  if (_post.excerpt.isNotEmpty)
                    Container(
                      padding: const EdgeInsetsDirectional.only(
                        start: 16,
                      ),
                      decoration: const BoxDecoration(
                        border: Border(
                          right: BorderSide(
                            color: SeenColors.gold,
                            width: 3,
                          ),
                        ),
                      ),
                      child: Text(
                        _post.excerpt,
                        style: textTheme.titleMedium,
                      ),
                    ),
                  const SizedBox(height: 18),
                  if (_post.content.trim().isEmpty)
                    const Text('لا يتوفر نص المقال.')
                  else
                    HtmlWidget(
                      _post.content,
                      textStyle: const TextStyle(
                        fontSize: 17,
                        height: 1.85,
                      ),
                      customStylesBuilder: (element) {
                        switch (element.localName) {
                          case 'p':
                            return {
                              'margin': '0 0 16px 0',
                            };
                          case 'h2':
                            return {
                              'font-size': '23px',
                              'font-weight': 'bold',
                              'margin': '24px 0 10px 0',
                            };
                          case 'img':
                            return {
                              'margin': '12px 0',
                            };
                          default:
                            return null;
                        }
                      },
                    ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 8,
                    ),
                    decoration: BoxDecoration(
                      border: Border.symmetric(
                        horizontal: BorderSide(
                          color: SeenColors.line,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _ActionButton(
                          icon: _liked
                              ? Icons.favorite
                              : Icons.favorite_border,
                          label: '$_likes',
                          active: _liked,
                          onTap: _loading ? null : _toggleLike,
                        ),
                        _ActionButton(
                          icon: _favorite
                              ? Icons.bookmark
                              : Icons.bookmark_border,
                          label: 'المفضلة',
                          active: _favorite,
                          onTap: _loading ? null : _toggleFavorite,
                        ),
                        _ActionButton(
                          icon: _saved
                              ? Icons.download_done_rounded
                              : Icons.download_for_offline_outlined,
                          label: 'للقراءة',
                          active: _saved,
                          onTap: _loading ? null : _toggleOffline,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Icon(
              icon,
              color: active ? SeenColors.teal : SeenColors.muted,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: active ? SeenColors.teal : SeenColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
