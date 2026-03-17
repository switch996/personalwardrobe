import 'package:flutter/material.dart';

import 'design/app_bottom_nav.dart';
import 'design/ds.dart';
import 'pages/closet_page.dart';
import 'pages/diary_page.dart';
import 'pages/me_page.dart';
import 'pages/today_page.dart';
import 'sheets/closet_item_editor_sheet.dart';
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
      title: '衣橱日记',
      debugShowCheckedModeBanner: false,
      theme: Ds.themeData(),
      home: _loading
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
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
  final GlobalKey<NavigatorState> _homeNavigatorKey =
      GlobalKey<NavigatorState>();
  int _pageIndex = 0;
  int _navIndex = 0;

  void _switchToTab(int value) {
    setState(() {
      _navIndex = value;
      _pageIndex = value > 2 ? value - 1 : value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      Navigator(
        key: _homeNavigatorKey,
        onGenerateRoute: (_) {
          return MaterialPageRoute<void>(
            builder: (_) => TodayPage(
              store: widget.store,
              refresh: widget.refresh,
              onRefresh: widget.onRefresh,
              onNavigateTab: _switchToTab,
            ),
          );
        },
      ),
      DiaryPage(
        store: widget.store,
        refresh: widget.refresh,
        onRefresh: widget.onRefresh,
        showBottomNav: false,
      ),
      ClosetPage(
        store: widget.store,
        refresh: widget.refresh,
        onRefresh: widget.onRefresh,
      ),
      MePage(store: widget.store, refresh: widget.refresh),
    ];

    return Scaffold(
      body: IndexedStack(index: _pageIndex, children: pages),
      bottomNavigationBar: AppBottomNav(
        selectedIndex: _navIndex,
        firstTab: AppBottomNavFirstTab.home,
        onDestinationSelected: (value) async {
          if (value == 2) {
            final changed = await showClosetItemEditorSheet(
              context,
              store: widget.store,
            );
            if (changed == true) widget.onRefresh();
            return;
          }
          _switchToTab(value);
        },
      ),
    );
  }
}
