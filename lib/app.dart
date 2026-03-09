import 'package:flutter/material.dart';

import 'design/ds.dart';
import 'pages/closet_page.dart';
import 'pages/diary_page.dart';
import 'pages/me_page.dart';
import 'pages/today_page.dart';
import 'store/local_store.dart';

class WardrobeApp extends StatefulWidget {
  const WardrobeApp({super.key});

  @override
  State<WardrobeApp> createState() => _WardrobeAppState();
}

class _WardrobeAppState extends State<WardrobeApp> {
  final LocalStore _store = LocalStore();
  final ValueNotifier<int> _refresh = ValueNotifier<int>(0);
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _store.loadAll();
    if (!mounted) return;
    setState(() {
      _loading = false;
    });
  }

  @override
  void dispose() {
    _refresh.dispose();
    super.dispose();
  }

  void _notifyRefresh() {
    _refresh.value = _refresh.value + 1;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Personal Wardrobe',
      debugShowCheckedModeBanner: false,
      theme: Ds.themeData(),
      home: _loading
          ? const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            )
          : _RootTabs(
              store: _store,
              refresh: _refresh,
              onRefresh: _notifyRefresh,
            ),
    );
  }
}

class _RootTabs extends StatefulWidget {
  const _RootTabs({
    required this.store,
    required this.refresh,
    required this.onRefresh,
  });

  final LocalStore store;
  final ValueNotifier<int> refresh;
  final VoidCallback onRefresh;

  @override
  State<_RootTabs> createState() => _RootTabsState();
}

class _RootTabsState extends State<_RootTabs> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      TodayPage(
        store: widget.store,
        refresh: widget.refresh,
        onRefresh: widget.onRefresh,
      ),
      DiaryPage(
        store: widget.store,
        refresh: widget.refresh,
        onRefresh: widget.onRefresh,
      ),
      ClosetPage(
        store: widget.store,
        refresh: widget.refresh,
        onRefresh: widget.onRefresh,
      ),
      MePage(store: widget.store, refresh: widget.refresh),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        backgroundColor: DsColors.paper,
        selectedIndex: _index,
        onDestinationSelected: (value) {
          setState(() {
            _index = value;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.today_outlined),
            selectedIcon: Icon(Icons.today),
            label: 'Today',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Diary',
          ),
          NavigationDestination(
            icon: Icon(Icons.checkroom_outlined),
            selectedIcon: Icon(Icons.checkroom),
            label: 'Closet',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Me',
          ),
        ],
      ),
    );
  }
}
