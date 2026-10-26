import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../core/api.dart';
import '../core/offline.dart';
import '../main.dart' show firebaseReady;

const ink = Color(0xFF172B36);
const blue = Color(0xFF1B5366);
const gold = Color(0xFFC38E51);

// ============================================================
// APP SHELL
// ============================================================

class SeenShell extends StatefulWidget {
  final SeenApi api;
  final OfflineLibrary offline;

  const SeenShell({
    super.key,
    required this.api,
    required this.offline,
  });

  @override
  State<SeenShell> createState() => _SeenShellState();
}

class _SeenShellState extends State<SeenShell> {
  int tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: tab,
        children: [
          HomeScreen(
            api: widget.api,
            offline: widget.offline,
          ),
          SearchScreen(
            api: widget.api,
            offline: widget.offline,
          ),
          LibraryScreen(
            api: widget.api,
            offline: widget.offline,
          ),
          AccountScreen(
            api: widget.api,
            offline: widget.offline,
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (index) {
          setState(() => tab = index);
        },
        height: 72,
        indicatorColor: const Color(0xFFDCE7E7),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'الرئيسية',
          ),
          NavigationDestination(
            icon: Icon(Icons.search),
            label: 'البحث',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_outline),
            label: 'مكتبتي',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'حسابي',
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SHARED COMPONENTS
// ============================================================

class SeenMasthead extends StatelessWidget {
  const SeenMasthead({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 32, height: 1, color: gold),
              const SizedBox(width: 14),
              const Text(
                'ســيــن',
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                  color: ink,
                ),
              ),
              const SizedBox(width: 14),
              Container(width: 32, height: 1, color: gold),
            ],
          ),
          const Text(
            'لأن الصحافة سؤال',
            style: TextStyle(
              fontSize: 12,
              letterSpacing: 1.3,
              color: blue,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            height: 1,
            color: ink.withValues(alpha: 0.18),
          ),
        ],
      ),
    );
  }
}

class StateMessage extends StatelessWidget {
  final String message;
  final VoidCallback? retry;

  const StateMessage({
    super.key,
    required this.message,
    this.retry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.auto_stories_outlined,
              size: 42,
              color: blue,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
            if (retry != null)
              TextButton(
                onPressed: retry,
                child: const Text('إعادة المحاولة'),
              ),
          ],
        ),
      ),
    );
  }
}

class PostCard extends StatelessWidget {
  final SeenPost post;
  final VoidCallback onTap;
  final bool prominent;

  const PostCard({
    super.key,
    required this.post,
    required this.onTap,
    this.prominent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 6, 18, 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (post.image.isNotEmpty)
                SizedBox(
                  height: prominent ? 220 : 155,
                  child: Image.network(
                    post.image,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) {
                      return const ColoredBox(
                        color: Color(0xFFE3E6E3),
                        child: Center(
                          child: Icon(
                            Icons.image_not_supported_outlined,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.category,
                      style: const TextStyle(
                        fontSize: 11,
                        color: blue,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      post.title,
                      style: TextStyle(
                        fontSize: prominent ? 24 : 19,
                        height: 1.4,
                        fontWeight: FontWeight.w800,
                        color: ink,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (post.excerpt.isNotEmpty)
                      Text(
                        post.excerpt,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF6A777B),
                          height: 1.7,
                        ),
                      ),
                    const SizedBox(height: 10),
                    Text(
                      post.author,
                      style: const TextStyle(
                        fontSize: 12,
                        color: gold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void openPost(
  BuildContext context,
  SeenApi api,
  OfflineLibrary offline,
  SeenPost post, {
  bool saved = false,
}) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ArticleScreen(
        api: api,
        offline: offline,
        initial: post,
        offlineOnly: saved,
      ),
    ),
  );
}

void showError(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}

// ============================================================
// HOME
// ============================================================

class HomeScreen extends StatefulWidget {
  final SeenApi api;
  final OfflineLibrary offline;

  const HomeScreen({
    super.key,
    required this.api,
    required this.offline,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<SeenPost>> data;
  String? category;
  List<String> categories = [];

  @override
  void initState() {
    super.initState();
    reload();
  }

  void reload() {
    data = widget.api.posts(category: category);

    data.then((posts) {
      if (!mounted || category != null) return;

      final values = posts
          .map((post) => post.category)
          .where((value) => value.isNotEmpty)
          .toSet()
          .toList();

      setState(() => categories = values);
    }).catchError((Object _) {});
  }

  Future<void> refresh() async {
    setState(reload);

    try {
      await data;
    } catch (_) {
      // FutureBuilder displays the request error.
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: refresh,
        child: FutureBuilder<List<SeenPost>>(
          future: data,
          builder: (context, snapshot) {
            final posts = snapshot.data ?? [];

            return CustomScrollView(
              slivers: [
                const SliverToBoxAdapter(
                  child: SeenMasthead(),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'من نافذة سين',
                          style: TextStyle(
                            fontSize: 12,
                            color: gold,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          'قصص تستحق القراءة',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: ink,
                          ),
                        ),
                        const SizedBox(height: 14),

                        if (categories.isNotEmpty)
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                ChoiceChip(
                                  label: const Text('الكل'),
                                  selected: category == null,
                                  onSelected: (_) {
                                    setState(() {
                                      category = null;
                                      reload();
                                    });
                                  },
                                ),

                                for (final item in categories)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      right: 8,
                                    ),
                                    child: ChoiceChip(
                                      label: Text(item),
                                      selected: category == item,
                                      onSelected: (_) {
                                        setState(() {
                                          category = item;
                                          reload();
                                        });
                                      },
                                    ),
                                  ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),

                if (snapshot.connectionState !=
                    ConnectionState.done)
                  const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (snapshot.hasError)
                  SliverFillRemaining(
                    child: StateMessage(
                      message: '${snapshot.error}',
                      retry: () => setState(reload),
                    ),
                  )
                else if (posts.isEmpty)
                  const SliverFillRemaining(
                    child: StateMessage(
                      message:
                          'لا توجد مقالات منشورة في هذا القسم.',
                    ),
                  )
                else
                  SliverList.builder(
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      return PostCard(
                        post: posts[index],
                        prominent: index == 0,
                        onTap: () => openPost(
                          context,
                          widget.api,
                          widget.offline,
                          posts[index],
                        ),
                      );
                    },
                  ),

                const SliverToBoxAdapter(
                  child: SizedBox(height: 25),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ============================================================
// ARTICLE
// ============================================================

class ArticleScreen extends StatefulWidget {
  final SeenApi api;
  final OfflineLibrary offline;
  final SeenPost initial;
  final bool offlineOnly;

  const ArticleScreen({
    super.key,
    required this.api,
    required this.offline,
    required this.initial,
    this.offlineOnly = false,
  });

  @override
  State<ArticleScreen> createState() => _ArticleScreenState();
}

class _ArticleScreenState extends State<ArticleScreen> {
  late SeenPost post;

  bool saved = false;
  bool busy = false;
  bool loading = true;

  LikeState? likes;
  String? error;

  @override
  void initState() {
    super.initState();
    post = widget.initial;
    initialize();
  }

  Future<void> initialize() async {
    try {
      saved = await widget.offline.contains(post.id);

      if (!widget.offlineOnly) {
        post = await widget.api.post(post.id);

        try {
          likes = await widget.api.likeState(post.id);
        } catch (_) {
          // The article remains readable if likes fail.
        }
      }

      error = null;
    } catch (e) {
      error = '$e';
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  Future<void> toggleSaved() async {
    if (busy) return;

    setState(() => busy = true);

    try {
      if (saved) {
        await widget.offline.remove(post.id);
      } else {
        if (post.content.isEmpty) {
          post = await widget.api.post(post.id);
        }

        await widget.offline.save(post);
      }

      if (mounted) {
        setState(() => saved = !saved);
      }
    } catch (e) {
      if (mounted) showError(context, '$e');
    } finally {
      if (mounted) {
        setState(() => busy = false);
      }
    }
  }

  Future<void> toggleLike() async {
    if (!firebaseReady ||
        FirebaseAuth.instance.currentUser == null) {
      await showLogin(context, widget.api);

      if (mounted) {
        try {
          final state = await widget.api.likeState(post.id);
          if (mounted) setState(() => likes = state);
        } catch (_) {}
      }
      return;
    }

    try {
      final state = await widget.api.toggleLike(post.id);

      if (mounted) {
        setState(() => likes = state);
      }
    } catch (e) {
      if (mounted) showError(context, '$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('سين | قراءة'),
        actions: [
          IconButton(
            tooltip: 'حفظ دون اتصال',
            onPressed: busy || loading ? null : toggleSaved,
            icon: Icon(
              saved
                  ? Icons.download_done
                  : Icons.download_outlined,
            ),
          ),
          IconButton(
            tooltip: 'إعجاب',
            onPressed: widget.offlineOnly
                ? null
                : toggleLike,
            icon: Icon(
              likes?.liked == true
                  ? Icons.favorite
                  : Icons.favorite_border,
              color: likes?.liked == true
                  ? Colors.redAccent
                  : null,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          20,
          12,
          20,
          50,
        ),
        children: [
          Text(
            post.category,
            style: const TextStyle(
              color: gold,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            post.title,
            style: const TextStyle(
              fontSize: 30,
              height: 1.45,
              fontWeight: FontWeight.w900,
              color: ink,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            post.author,
            style: const TextStyle(color: blue),
          ),
          const SizedBox(height: 16),

          if (post.image.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                post.image,
                height: 240,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) {
                  return const SizedBox.shrink();
                },
              ),
            ),

          const SizedBox(height: 20),

          if (error != null)
            StateMessage(
              message: error!,
              retry: () {
                setState(() => loading = true);
                initialize();
              },
            ),

          if (post.content.isNotEmpty)
            Html(
              data: post.content,
              style: {
                'body': Style(
                  fontSize: FontSize(18),
                  lineHeight: LineHeight.number(1.9),
                  color: ink,
                  margin: Margins.zero,
                ),
                'p': Style(
                  margin: Margins.only(bottom: 16),
                ),
              },
            ),

          if (loading && post.content.isEmpty)
            const Center(
              child: CircularProgressIndicator(),
            ),

          const SizedBox(height: 22),

          if (likes != null)
            Text(
              '${likes!.count} إعجاب',
              style: const TextStyle(color: blue),
            ),
        ],
      ),
    );
  }
}

// ============================================================
// SEARCH
// ============================================================

class SearchScreen extends StatefulWidget {
  final SeenApi api;
  final OfflineLibrary offline;

  const SearchScreen({
    super.key,
    required this.api,
    required this.offline,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late Future<List<SeenPost>> data;
  String query = '';

  @override
  void initState() {
    super.initState();
    data = widget.api.posts();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const SeenMasthead(),

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
            ),
            child: TextField(
              onChanged: (value) {
                setState(() => query = value);
              },
              decoration: InputDecoration(
                hintText: 'ابحث في المقالات المحمّلة...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          Expanded(
            child: FutureBuilder<List<SeenPost>>(
              future: data,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return StateMessage(
                    message: '${snapshot.error}',
                    retry: () {
                      setState(() {
                        data = widget.api.posts();
                      });
                    },
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final found = snapshot.data!.where((post) {
                  final searchable =
                      '${post.title} '
                      '${post.excerpt} '
                      '${post.category}';

                  return searchable.toLowerCase().contains(
                    query.toLowerCase(),
                  );
                }).toList();

                if (found.isEmpty) {
                  return const StateMessage(
                    message: 'لا توجد نتائج مطابقة',
                  );
                }

                return ListView.builder(
                  itemCount: found.length,
                  itemBuilder: (context, index) {
                    return PostCard(
                      post: found[index],
                      onTap: () => openPost(
                        context,
                        widget.api,
                        widget.offline,
                        found[index],
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

// ============================================================
// OFFLINE LIBRARY
// ============================================================

class LibraryScreen extends StatefulWidget {
  final SeenApi api;
  final OfflineLibrary offline;

  const LibraryScreen({
    super.key,
    required this.api,
    required this.offline,
  });

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  late Future<List<SeenPost>> saved;

  @override
  void initState() {
    super.initState();
    refresh();
  }

  void refresh() {
    saved = widget.offline.all();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const SeenMasthead(),

          const Padding(
            padding: EdgeInsets.all(16),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                'مقالات للقراءة دون اتصال',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),

          Expanded(
            child: FutureBuilder<List<SeenPost>>(
              future: saved,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return StateMessage(
                    message: '${snapshot.error}',
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final list = snapshot.data!;

                if (list.isEmpty) {
                  return const StateMessage(
                    message:
                        'لم تحفظ أي مقال بعد. '
                        'افتح مقالاً واضغط زر التنزيل.',
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    setState(refresh);
                    await saved;
                  },
                  child: ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      return PostCard(
                        post: list[index],
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ArticleScreen(
                                api: widget.api,
                                offline: widget.offline,
                                initial: list[index],
                                offlineOnly: true,
                              ),
                            ),
                          );

                          if (mounted) {
                            setState(refresh);
                          }
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// ACCOUNT
// ============================================================

class AccountScreen extends StatefulWidget {
  final SeenApi api;
  final OfflineLibrary offline;

  const AccountScreen({
    super.key,
    required this.api,
    required this.offline,
  });

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        children: [
          const SeenMasthead(),

          const Padding(
            padding: EdgeInsets.all(22),
            child: Text(
              'مساحتك في سين',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),

          if (!firebaseReady)
            const ListTile(
              leading: Icon(Icons.info_outline),
              title: Text(
                'يلزم إعداد Firebase Android '
                'لتفعيل الحساب.',
              ),
            )
          else
            StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                final user = snapshot.data;

                return Column(
                  children: [
                    ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.person),
                      ),
                      title: Text(
                        user?.displayName ?? 'زائر',
                      ),
                      subtitle: Text(
                        user?.email ??
                            'تصفح المقالات متاح دون حساب',
                      ),
                    ),

                    if (user == null)
                      FilledButton(
                        onPressed: () async {
                          await showLogin(
                            context,
                            widget.api,
                          );

                          if (mounted) setState(() {});
                        },
                        child: const Text(
                          'تسجيل الدخول / إنشاء حساب',
                        ),
                      )
                    else ...[
                      ListTile(
                        leading: const Icon(
                          Icons.favorite_outline,
                        ),
                        title: const Text(
                          'المفضلة على الحساب',
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => RemoteFavorites(
                                api: widget.api,
                                offline: widget.offline,
                              ),
                            ),
                          );
                        },
                      ),

                      ListTile(
                        leading: const Icon(
                          Icons.notifications_outlined,
                        ),
                        title: const Text('الإشعارات'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => NoticesScreen(
                                api: widget.api,
                                offline: widget.offline,
                              ),
                            ),
                          );
                        },
                      ),

                      TextButton(
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();
                        },
                        child: const Text('تسجيل الخروج'),
                      ),
                    ],
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}

// ============================================================
// REMOTE FAVORITES
// ============================================================

class RemoteFavorites extends StatefulWidget {
  final SeenApi api;
  final OfflineLibrary offline;

  const RemoteFavorites({
    super.key,
    required this.api,
    required this.offline,
  });

  @override
  State<RemoteFavorites> createState() => _RemoteFavoritesState();
}

class _RemoteFavoritesState extends State<RemoteFavorites> {
  late Future<List<SeenPost>> data;

  @override
  void initState() {
    super.initState();
    data = widget.api.favorites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مفضلتي'),
      ),
      body: FutureBuilder<List<SeenPost>>(
        future: data,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return StateMessage(
              message: '${snapshot.error}',
              retry: () {
                setState(() {
                  data = widget.api.favorites();
                });
              },
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.data!.isEmpty) {
            return const StateMessage(
              message: 'لا توجد مقالات في المفضلة.',
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final post = snapshot.data![index];

              return PostCard(
                post: post,
                onTap: () => openPost(
                  context,
                  widget.api,
                  widget.offline,
                  post,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ============================================================
// NOTIFICATIONS
// ============================================================

class NoticesScreen extends StatefulWidget {
  final SeenApi api;
  final OfflineLibrary offline;

  const NoticesScreen({
    super.key,
    required this.api,
    required this.offline,
  });

  @override
  State<NoticesScreen> createState() => _NoticesScreenState();
}

class _NoticesScreenState extends State<NoticesScreen> {
  late Future<List<SeenNotice>> data;

  @override
  void initState() {
    super.initState();
    data = widget.api.notifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإشعارات'),
      ),
      body: FutureBuilder<List<SeenNotice>>(
        future: data,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return StateMessage(
              message: '${snapshot.error}',
              retry: () {
                setState(() {
                  data = widget.api.notifications();
                });
              },
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.data!.isEmpty) {
            return const StateMessage(
              message: 'لا توجد إشعارات حالياً.',
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final notice = snapshot.data![index];

              return ListTile(
                leading: Icon(
                  notice.read
                      ? Icons.mark_email_read_outlined
                      : Icons.markunread_outlined,
                ),
                title: Text(notice.title),
                subtitle: Text(notice.message),
                onTap: () async {
                  try {
                    await widget.api.markRead(notice.id);

                    if (notice.postId.isNotEmpty &&
                        context.mounted) {
                      final post = await widget.api.post(
                        notice.postId,
                      );

                      if (context.mounted) {
                        openPost(
                          context,
                          widget.api,
                          widget.offline,
                          post,
                        );
                      }
                    }

                    if (mounted) {
                      setState(() {
                        data = widget.api.notifications();
                      });
                    }
                  } catch (e) {
                    if (context.mounted) {
                      showError(context, '$e');
                    }
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}

// ============================================================
// AUTHENTICATION
// ============================================================

Future<void> showLogin(
  BuildContext context,
  SeenApi api,
) async {
  if (!firebaseReady) {
    showError(
      context,
      'أكمل إعداد Firebase أولاً',
    );
    return;
  }

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => AuthSheet(api: api),
  );
}

class AuthSheet extends StatefulWidget {
  final SeenApi api;

  const AuthSheet({
    super.key,
    required this.api,
  });

  @override
  State<AuthSheet> createState() => _AuthSheetState();
}

class _AuthSheetState extends State<AuthSheet> {
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();

  bool register = false;
  bool busy = false;

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (email.text.trim().isEmpty ||
        password.text.isEmpty) {
      showError(
        context,
        'أدخل البريد الإلكتروني وكلمة المرور',
      );
      return;
    }

    if (register && name.text.trim().isEmpty) {
      showError(context, 'أدخل الاسم');
      return;
    }

    setState(() => busy = true);

    try {
      if (register) {
        await widget.api.register(
          name.text.trim(),
          email.text.trim(),
          password.text,
        );
      }

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.text.trim(),
        password: password.text,
      );

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        showError(
          context,
          'تعذر إتمام العملية: $e',
        );
      }
    } finally {
      if (mounted) {
        setState(() => busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        22,
        12,
        22,
        MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              register
                  ? 'انضم إلى سين'
                  : 'أهلاً بعودتك',
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 20),

            if (register)
              TextField(
                controller: name,
                decoration: const InputDecoration(
                  labelText: 'الاسم',
                ),
              ),

            TextField(
              controller: email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'البريد الإلكتروني',
              ),
            ),

            TextField(
              controller: password,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'كلمة المرور',
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: busy ? null : submit,
                child: Text(
                  register
                      ? 'إنشاء حساب'
                      : 'دخول',
                ),
              ),
            ),

            TextButton(
              onPressed: busy
                  ? null
                  : () {
                      setState(() {
                        register = !register;
                      });
                    },
              child: Text(
                register
                    ? 'لدي حساب بالفعل'
                    : 'ليس لديك حساب؟ انضم إلينا',
              ),
            ),
          ],
        ),
      ),
    );
  }
}