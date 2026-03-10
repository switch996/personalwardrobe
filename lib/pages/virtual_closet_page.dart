import 'package:flutter/material.dart';

import '../design/ds.dart';
import '../models/closet_item.dart';
import '../pages/closet_page.dart';
import '../pages/diary_page.dart';
import '../pages/me_page.dart';
import '../pages/outfit_detail_page.dart';
import '../sheets/closet_item_editor_sheet.dart';
import '../store/local_store.dart';

class VirtualClosetPage extends StatefulWidget {
  const VirtualClosetPage({
    super.key,
    required this.store,
    required this.refresh,
    required this.onRefresh,
  });

  final LocalStore store;
  final ValueNotifier<int> refresh;
  final VoidCallback onRefresh;

  @override
  State<VirtualClosetPage> createState() => _VirtualClosetPageState();
}

class _VirtualClosetPageState extends State<VirtualClosetPage> {
  bool _byType = true;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: widget.refresh,
      builder: (context, value, child) {
        return Scaffold(
          backgroundColor: DsColors.paper,
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                _TopBar(onBack: () => Navigator.of(context).pop()),
                const SizedBox(height: 10),
                _FilterSwitch(
                  byType: _byType,
                  onChange: (value) => setState(() => _byType = value),
                ),
                const SizedBox(height: 20),
                _FloatBoard(store: widget.store, byType: _byType),
                const SizedBox(height: 24),
                _WeeklyStrip(
                  store: widget.store,
                  refresh: widget.refresh,
                  onRefresh: widget.onRefresh,
                ),
              ],
            ),
          ),
          bottomNavigationBar: _BottomNav(
            store: widget.store,
            refresh: widget.refresh,
            onRefresh: widget.onRefresh,
          ),
        );
      },
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
        ),
        const Expanded(
          child: Center(
            child: Text(
              '我的虚拟衣橱',
              style: TextStyle(
                color: DsColors.ink,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        const SizedBox(width: 48),
      ],
    );
  }
}

class _FilterSwitch extends StatelessWidget {
  const _FilterSwitch({required this.byType, required this.onChange});

  final bool byType;
  final ValueChanged<bool> onChange;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F4ED),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: DsColors.line),
      ),
      child: Row(
        children: [
          _SwitchCell(
            selected: byType,
            text: '按类型',
            onTap: () => onChange(true),
          ),
          _SwitchCell(
            selected: !byType,
            text: '按品牌',
            onTap: () => onChange(false),
          ),
        ],
      ),
    );
  }
}

class _SwitchCell extends StatelessWidget {
  const _SwitchCell({required this.selected, required this.text, required this.onTap});

  final bool selected;
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(11),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
            boxShadow: selected
                ? const [
                    BoxShadow(color: Color(0x15000000), blurRadius: 8, offset: Offset(0, 3)),
                  ]
                : null,
          ),
          child: Text(
            text,
            style: TextStyle(
              color: selected ? DsColors.ink : DsColors.mutedInk,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _FloatBoard extends StatelessWidget {
  const _FloatBoard({required this.store, required this.byType});

  final LocalStore store;
  final bool byType;

  @override
  Widget build(BuildContext context) {
    final topItem = _firstByCategory('top');
    final accessoryItem = _firstByCategory('accessory');
    final dressItem = _firstByCategory('dress');
    final shoesItem = _firstByCategory('shoes');
    final bagItem = _firstByCategory('bag');

    return SizedBox(
      height: 240,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(left: 12, top: 16, child: _FloatIcon(label: _labelFor(topItem, '上装'), icon: Icons.checkroom_outlined)),
          Positioned(right: 20, top: 0, child: _FloatIcon(label: _labelFor(accessoryItem, '配饰'), icon: Icons.auto_awesome_outlined)),
          Positioned(left: 120, top: 40, child: _FloatIcon(label: _labelFor(dressItem, '连衣裙'), icon: Icons.dry_cleaning, highlighted: true)),
          Positioned(left: 30, bottom: 10, child: _FloatIcon(label: _labelFor(shoesItem, '鞋子'), icon: Icons.hiking_outlined)),
          Positioned(right: 24, bottom: 20, child: _FloatIcon(label: _labelFor(bagItem, '包袋'), icon: Icons.shopping_bag_outlined)),
        ],
      ),
    );
  }

  ClosetItem? _firstByCategory(String category) {
    for (final item in store.closet) {
      if (item.category == category) return item;
    }
    return null;
  }

  String _labelFor(ClosetItem? item, String typeLabel) {
    if (byType) {
      return item == null ? typeLabel : LocalStore.categoryLabel(item.category);
    }
    final brand = item?.brand.trim() ?? '';
    return brand.isEmpty ? '未设置品牌' : brand;
  }
}

class _FloatIcon extends StatefulWidget {
  const _FloatIcon({required this.label, required this.icon, this.highlighted = false});

  final String label;
  final IconData icon;
  final bool highlighted;

  @override
  State<_FloatIcon> createState() => _FloatIconState();
}

class _FloatIconState extends State<_FloatIcon> {
  bool _forward = true;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 2400),
      tween: Tween(begin: _forward ? -6 : 6, end: _forward ? 6 : -6),
      curve: Curves.easeInOut,
      onEnd: () => setState(() => _forward = !_forward),
      builder: (context, value, child) => Transform.translate(offset: Offset(0, value), child: child),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: widget.highlighted ? 84 : 70,
            height: widget.highlighted ? 84 : 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: widget.highlighted ? Border.all(color: const Color(0xFFF2C7AE), width: 3) : null,
              boxShadow: const [
                BoxShadow(color: Color(0x14000000), blurRadius: 10, offset: Offset(0, 4)),
              ],
            ),
            child: Icon(widget.icon, color: widget.highlighted ? DsColors.copper : DsColors.ink, size: widget.highlighted ? 40 : 34),
          ),
          const SizedBox(height: 6),
          Container(
            width: widget.highlighted ? 32 : 26,
            height: 6,
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0x1A000000), Color(0x05000000)]),
              borderRadius: BorderRadius.all(Radius.circular(3)),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            widget.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: widget.highlighted ? DsColors.copper : DsColors.ink,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyStrip extends StatelessWidget {
  const _WeeklyStrip({required this.store, required this.refresh, required this.onRefresh});

  final LocalStore store;
  final ValueNotifier<int> refresh;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day - 3);
    final days = List<DateTime>.generate(7, (index) => DateTime(start.year, start.month, start.day + index));

    return Column(
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                '本周穿搭日历',
                style: TextStyle(
                  color: DsColors.ink,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('切换到“日历”页查看全部记录')),
                );
              },
              child: const Text(
                '查看全部',
                style: TextStyle(
                  color: Color(0xFFF45E06),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: DsSpace.sm),
        Row(
          children: List<Widget>.generate(days.length, (index) {
            final day = days[index];
            final entries = store.outfitsOn(day);
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: index == days.length - 1 ? 0 : 6),
                child: _WeekDayCard(
                  day: day,
                  isToday: _isSameDay(day, now),
                  hasRecord: entries.isNotEmpty,
                  onTap: () async {
                    if (entries.isEmpty) return;
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => OutfitDetailPage(
                          entryId: entries.first.id,
                          store: store,
                          refresh: refresh,
                          onRefresh: onRefresh,
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _WeekDayCard extends StatelessWidget {
  const _WeekDayCard({
    required this.day,
    required this.isToday,
    required this.hasRecord,
    required this.onTap,
  });

  final DateTime day;
  final bool isToday;
  final bool hasRecord;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final label = _weekdayLabel(day.weekday);
    final selected = isToday && hasRecord;
    final outlined = isToday && !hasRecord;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: selected ? const Color(0xFFF8660A) : const Color(0xFFF1F3F5),
          border: outlined ? Border.all(color: const Color(0xFFF8660A), width: 1.3) : null,
          boxShadow: selected
              ? const [
                  BoxShadow(
                    color: Color(0x28F8660A),
                    blurRadius: 14,
                    offset: Offset(0, 8),
                  ),
                ]
              : null,
        ),
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : const Color(0xFF97A6BA),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              '${day.day}',
              style: TextStyle(
                color: selected ? Colors.white : DsColors.ink,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0x33FFFFFF)
                    : (hasRecord ? const Color(0x1AF8660A) : const Color(0xFFE4E8EE)),
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasRecord ? Icons.check : Icons.add,
                size: 12,
                color: selected
                    ? Colors.white
                    : (hasRecord ? const Color(0xFFF8660A) : const Color(0xFFAAB4C4)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomNav extends StatefulWidget {
  const _BottomNav({required this.store, required this.refresh, required this.onRefresh});

  final LocalStore store;
  final ValueNotifier<int> refresh;
  final VoidCallback onRefresh;

  @override
  State<_BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<_BottomNav> {
  int _navIndex = 0;
  double _addTurns = 0;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      height: 70,
      backgroundColor: DsColors.paper,
      selectedIndex: _navIndex,
      onDestinationSelected: (value) async {
        switch (value) {
          case 0:
            setState(() {
              _navIndex = value;
            });
            Navigator.of(context).pop();
            break;
          case 1:
            setState(() {
              _navIndex = value;
            });
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => DiaryPage(
                  store: widget.store,
                  refresh: widget.refresh,
                  onRefresh: widget.onRefresh,
                ),
              ),
            );
            break;
          case 2:
            setState(() {
              _addTurns += 1;
            });
            final changed = await showClosetItemEditorSheet(context, store: widget.store);
            if (changed == true) widget.onRefresh();
            break;
          case 3:
            setState(() {
              _navIndex = value;
            });
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ClosetPage(
                  store: widget.store,
                  refresh: widget.refresh,
                  onRefresh: widget.onRefresh,
                ),
              ),
            );
            break;
          case 4:
            setState(() {
              _navIndex = value;
            });
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => MePage(store: widget.store, refresh: widget.refresh),
              ),
            );
            break;
        }
      },
      destinations: [
        const NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: '首页',
        ),
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

  Widget _buildAddIcon(bool selected) {
    return AnimatedRotation(
      turns: _addTurns,
      duration: const Duration(milliseconds: 400),
      child: Icon(
        selected ? Icons.add_circle : Icons.add_circle_outline,
        size: 34,
        color: selected ? DsColors.copper : null,
      ),
    );
  }
}

String _weekdayLabel(int weekday) {
  const labels = <String>['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
  return labels[weekday - 1];
}

bool _isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}
