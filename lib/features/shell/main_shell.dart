import 'package:flutter/material.dart';

import '../../core/services/api_client.dart';
import '../../core/services/seen_repository.dart';
import '../../core/services/offline_library.dart';
import '../home/home_screen.dart';
import '../search/search_screen.dart';
import '../favorites/favorites_screen.dart';
import '../library/offline_library_screen.dart';
import '../profile/profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  final _api = ApiClient();

  late final _repo = SeenRepository(_api);

  final _offline = OfflineLibrary();

  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(
        repository: _repo,
        offline: _offline,
      ),
      SearchScreen(
        repository: _repo,
      ),
      FavoritesScreen(
        repository: _repo,
      ),
      OfflineLibraryScreen(
        offline: _offline,
      ),
      ProfileScreen(
        repository: _repo,
        offline: _offline,
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) {
          setState(() {
            _index = value;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.auto_stories_outlined),
            selectedIcon: Icon(Icons.auto_stories),
            label: 'الرئيسية',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_rounded),
            label: 'بحث',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: 'المفضلة',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_border),
            selectedIcon: Icon(Icons.bookmark),
            label: 'للقراءة',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'حسابي',
          ),
        ],
      ),
    );
  }
}