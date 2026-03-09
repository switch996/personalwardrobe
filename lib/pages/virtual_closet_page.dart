import 'package:flutter/material.dart';

import '../design/ds.dart';
import '../design/widgets.dart';
import '../models/closet_item.dart';
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
        final now = DateTime.now();
        final topItem = _firstByCategory('top');
        final accessoryItem = _firstByCategory('accessory');
        final dressItem = _firstByCategory('dress');
        final shoesItem = _firstByCategory('shoes');
        final bagItem = _firstByCategory('bag');

        return Scaffold(
          backgroundColor: DsColors.paper,
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(14, 4, 14, 20),
              children: [
                _TopBar(onBack: () => Navigator.of(context).pop()),
                const SizedBox(height: 8),
                _FilterSwitch(
                  byType: _byType,
                  onChange: (byType) {
                    setState(() {
                      _byType = byType;
                    });
                  },
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 300,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        left: 10,
                        top: 26,
                        child: _FloatIcon(
                          label: _labelFor(topItem, '上装'),
                          imagePath: topItem?.imagePath ?? '',
                          iconSize: 66,
                        ),
                      ),
                      Positioned(
                        right: 18,
                        top: 8,
                        child: _FloatIcon(
                          label: _labelFor(accessoryItem, '配饰'),
                          imagePath: accessoryItem?.imagePath ?? '',
                          iconSize: 58,
                        ),
                      ),
                      Positioned(
                        left: 110,
                        top: 76,
                        child: _FloatIcon(
                          label: _labelFor(dressItem, '连衣裙'),
                          imagePath: dressItem?.imagePath ?? '',
                          iconSize: 88,
                          highlighted: true,
                        ),
                      ),
                      Positioned(
                        left: 28,
                        bottom: 18,
                        child: _FloatIcon(
                          label: _labelFor(shoesItem, '鞋子'),
                          imagePath: shoesItem?.imagePath ?? '',
                          iconSize: 54,
                        ),
                      ),
                      Positioned(
                        right: 22,
                        bottom: 30,
                        child: _FloatIcon(
                          label: _labelFor(bagItem, '包袋'),
                          imagePath: bagItem?.imagePath ?? '',
                          iconSize: 68,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                _WeekCalendar(now: now),
              ],
            ),
          ),
        );
      },
    );
  }

  ClosetItem? _firstByCategory(String category) {
    for (final item in widget.store.closet) {
      if (item.category == category) return item;
    }
    return null;
  }

  String _labelFor(ClosetItem? item, String typeLabel) {
    if (_byType) return typeLabel;
    final brand = item?.brand.trim() ?? '';
    return brand.isEmpty ? '未设置品牌' : brand;
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Row(
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: IconButton(
              padding: EdgeInsets.zero,
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            ),
          ),
          const Expanded(
            child: Center(
              child: Text(
                '我的虚拟衣橱',
                style: TextStyle(
                  color: DsColors.ink,
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }
}

class _FilterSwitch extends StatelessWidget {
  const _FilterSwitch({
    required this.byType,
    required this.onChange,
  });

  final bool byType;
  final ValueChanged<bool> onChange;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3F6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFDDE3EC)),
        boxShadow: const [
          BoxShadow(color: Color(0x12000000), blurRadius: 10, offset: Offset(0, 4)),
        ],
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
  const _SwitchCell({
    required this.selected,
    required this.text,
    required this.onTap,
  });

  final bool selected;
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFF8660A) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: selected ? Colors.white : const Color(0xFF6B7C93),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _FloatIcon extends StatelessWidget {
  const _FloatIcon({
    required this.label,
    required this.imagePath,
    required this.iconSize,
    this.highlighted = false,
  });

  final String label;
  final String imagePath;
  final double iconSize;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: iconSize + 20,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: iconSize,
            height: iconSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFF7F5F2),
              border: highlighted ? Border.all(color: const Color(0xFFF2C7AE), width: 4) : null,
              boxShadow: const [
                BoxShadow(color: Color(0x18000000), blurRadius: 14, offset: Offset(0, 6)),
              ],
            ),
            child: Center(
              child: ClipOval(
                child: AppImage(
                  path: imagePath,
                  width: iconSize * 0.62,
                  height: iconSize * 0.62,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: highlighted ? const Color(0xFFF8660A) : DsColors.ink,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeekCalendar extends StatelessWidget {
  const _WeekCalendar({required this.now});

  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final start = DateTime(now.year, now.month, now.day - 3);
    final days = List<DateTime>.generate(
      7,
      (index) => DateTime(start.year, start.month, start.day + index),
    );

    return Column(
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                '每周穿搭日历',
                style: TextStyle(
                  color: DsColors.ink,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const Icon(Icons.calendar_month, color: Color(0xFF7D8FA8)),
            const SizedBox(width: 6),
            Text(
              '${now.month}月',
              style: const TextStyle(
                color: Color(0xFF7D8FA8),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: List<Widget>.generate(days.length, (index) {
            final day = days[index];
            final isToday = _isSameDay(day, now);
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: index == days.length - 1 ? 0 : 6),
                child: Column(
                  children: [
                    Text(
                      _weekdayLabel(day.weekday),
                      style: const TextStyle(
                        color: Color(0xFF9AA9BD),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: isToday ? const Color(0xFFF8660A) : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(14),
                        border: isToday ? null : Border.all(color: const Color(0xFFE3E8EF)),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${day.day}',
                        style: TextStyle(
                          color: isToday ? Colors.white : DsColors.ink,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isToday ? const Color(0xFFF8660A) : const Color(0xFFD8E0EA),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

String _weekdayLabel(int weekday) {
  const labels = <String>['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
  return labels[weekday - 1];
}

bool _isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}
