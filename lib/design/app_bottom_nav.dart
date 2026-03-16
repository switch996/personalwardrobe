import 'dart:async';

import 'package:flutter/material.dart';

import 'ds.dart';

enum AppBottomNavFirstTab { today, home }

class AppBottomNav extends StatefulWidget {
  const AppBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.firstTab = AppBottomNavFirstTab.home,
    this.height = 70,
  });

  final int selectedIndex;
  final FutureOr<void> Function(int index) onDestinationSelected;
  final AppBottomNavFirstTab firstTab;
  final double height;

  @override
  State<AppBottomNav> createState() => _AppBottomNavState();
}

class _AppBottomNavState extends State<AppBottomNav> {
  double _addTurns = 0;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      height: widget.height,
      backgroundColor: DsColors.paper,
      selectedIndex: widget.selectedIndex,
      onDestinationSelected: (value) async {
        if (value == 2) {
          setState(() {
            _addTurns += 1;
          });
        }
        await widget.onDestinationSelected(value);
      },
      destinations: [
        _firstDestination(widget.firstTab),
        const NavigationDestination(
          icon: Icon(Icons.calendar_month_outlined),
          selectedIcon: Icon(Icons.calendar_month),
          label: '日历',
        ),
        NavigationDestination(
          icon: _buildAddIcon(false),
          selectedIcon: _buildAddIcon(true),
          label: '',
        ),
        const NavigationDestination(
          icon: Icon(Icons.checkroom_outlined),
          selectedIcon: Icon(Icons.checkroom),
          label: '衣橱',
        ),
        const NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: '我的',
        ),
      ],
    );
  }

  NavigationDestination _firstDestination(AppBottomNavFirstTab firstTab) {
    if (firstTab == AppBottomNavFirstTab.today) {
      return const NavigationDestination(
        icon: Icon(Icons.today_outlined),
        selectedIcon: Icon(Icons.today),
        label: '今日',
      );
    }
    return const NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home),
      label: '首页',
    );
  }

  Widget _buildAddIcon(bool selected) {
    return AnimatedRotation(
      turns: _addTurns,
      duration: const Duration(milliseconds: 400),
      child: Transform.translate(
        offset: const Offset(0, 10),
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: selected ? DsColors.copper : DsColors.paperDeep,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x22000000),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.add_rounded,
              size: 34,
              color: selected ? Colors.white : DsColors.red,
            ),
          ),
        ),
      ),
    );
  }
}
