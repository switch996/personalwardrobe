import 'package:flutter/material.dart';

import '../design/ds.dart';
import '../design/widgets.dart';
import '../pages/closet_page.dart';
import '../pages/outfit_detail_page.dart';
import '../sheets/outfit_editor_sheet.dart';
import '../store/local_store.dart';

class TodayPage extends StatelessWidget {
  const TodayPage({
    super.key,
    required this.store,
    required this.refresh,
    required this.onRefresh,
  });

  final LocalStore store;
  final ValueNotifier<int> refresh;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: refresh,
      builder: (context, value, child) {
        final now = DateTime.now();
        final todayEntries = store.outfitsOn(now);
        final coverPath = todayEntries.isNotEmpty
            ? todayEntries.first.imagePath
            : (store.outfits.isNotEmpty ? store.outfits.first.imagePath : '');
        final screenWidth = MediaQuery.of(context).size.width;
        final heroHeight = (screenWidth - DsSpace.md * 2) * 1.22;

        return Scaffold(
          backgroundColor: DsColors.paper,
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(DsSpace.md),
              children: [
                _HeaderRow(date: now),
                const SizedBox(height: DsSpace.md),
                _HeroCard(
                  imagePath: coverPath,
                  height: heroHeight.clamp(360, 560).toDouble(),
                  hasTodayRecord: todayEntries.isNotEmpty,
                  onCameraTap: () async {
                    final changed = await showOutfitEditorSheet(
                      context,
                      store: store,
                      initialDate: now,
                    );
                    if (changed == true) onRefresh();
                  },
                ),
                const SizedBox(height: DsSpace.md),
                _ClosetBanner(
                  onTap: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ClosetPage(
                          store: store,
                          refresh: refresh,
                          onRefresh: onRefresh,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: DsSpace.md),
                _WeekSection(
                  store: store,
                  refresh: refresh,
                  onRefresh: onRefresh,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${date.year}年${date.month}月${date.day}日',
                style: const TextStyle(
                  color: DsColors.ink,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              const Row(
                children: [
                  Icon(Icons.wb_sunny_rounded, color: Color(0xFFF45E06), size: 26),
                  SizedBox(width: 4),
                  Text(
                    '晴 24°C',
                    style: TextStyle(
                      color: Color(0xFFF45E06),
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          width: 66,
          height: 66,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F3F4),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFE0E6EA)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('通知中心敬请期待')),
              );
            },
            icon: const Icon(Icons.notifications, color: Color(0xFF334A66)),
          ),
        ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.imagePath,
    required this.height,
    required this.hasTodayRecord,
    required this.onCameraTap,
  });

  final String imagePath;
  final double height;
  final bool hasTodayRecord;
  final VoidCallback onCameraTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: DsRadius.lg,
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF2B2D3B), Color(0xFF1F2030)],
                  ),
                ),
                child: AppImage(
                  path: imagePath,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
          ),
          Positioned(
            left: 18,
            bottom: 20,
            child: Container(
              width: 230,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xE6F4F0EC),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '今日推荐',
                    style: TextStyle(
                      color: Color(0xFFF07E29),
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    hasTodayRecord ? '今日已记录穿搭' : '简约都市风',
                    style: const TextStyle(
                      color: DsColors.ink,
                      fontSize: 40 / 2,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    '适合今日职场与约会',
                    style: TextStyle(
                      color: Color(0xFF6A7A93),
                      fontSize: 16 / 1.3,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 24,
            bottom: 28,
            child: InkWell(
              onTap: onCameraTap,
              borderRadius: BorderRadius.circular(28),
              child: Container(
                width: 84,
                height: 84,
                decoration: const BoxDecoration(
                  color: Color(0xFFF9650A),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x30F9650A),
                      blurRadius: 16,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 34),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ClosetBanner extends StatelessWidget {
  const _ClosetBanner({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: DsRadius.lg,
      child: Container(
        height: 162,
        decoration: BoxDecoration(
          borderRadius: DsRadius.lg,
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xFF1D2744), Color(0xFF6A4A30)],
          ),
          boxShadow: const [
            BoxShadow(color: Color(0x22000000), blurRadius: 20, offset: Offset(0, 10)),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 98,
              height: 98,
              decoration: BoxDecoration(
                color: const Color(0x2DFFFFFF),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0x40FFFFFF)),
              ),
              child: const Icon(Icons.door_sliding_outlined, color: Color(0xFFE5E9F0), size: 52),
            ),
            const SizedBox(width: 20),
            const Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '进入虚拟衣橱',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 40 / 2,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '管理您的个人时尚收藏',
                    style: TextStyle(
                      color: Color(0xFFD0D7E3),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '点击推门开启 ->',
                    style: TextStyle(
                      color: Color(0xFFF5903D),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
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

class _WeekSection extends StatelessWidget {
  const _WeekSection({
    required this.store,
    required this.refresh,
    required this.onRefresh,
  });

  final LocalStore store;
  final ValueNotifier<int> refresh;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day - (now.weekday - 1));
    final days = List<DateTime>.generate(
      5,
      (index) => DateTime(start.year, start.month, start.day + index),
    );

    return Column(
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                '本周穿搭日历',
                style: TextStyle(
                  color: DsColors.ink,
                  fontSize: 40 / 2,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('请切到 Diary 查看全部记录')),
                );
              },
              child: const Text(
                '查看全部',
                style: TextStyle(
                  color: Color(0xFFF45E06),
                  fontSize: 34 / 2,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: DsSpace.sm),
        SizedBox(
          height: 124,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: days.length,
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final day = days[index];
              final entries = store.outfitsOn(day);
              return _WeekDayCard(
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
              );
            },
          ),
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
    final dayLabel = _weekdayLabel(day.weekday);
    final selected = isToday && hasRecord;
    final outlined = isToday && !hasRecord;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        width: 102,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: selected ? const Color(0xFFF8660A) : const Color(0xFFF1F3F5),
          border: outlined ? Border.all(color: const Color(0xFFF8660A), width: 2) : null,
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
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          children: [
            Text(
              dayLabel,
              style: TextStyle(
                color: selected ? Colors.white : const Color(0xFF97A6BA),
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${day.day}',
              style: TextStyle(
                color: selected ? Colors.white : DsColors.ink,
                fontSize: 34 / 2,
                fontWeight: FontWeight.w800,
              ),
            ),
            const Spacer(),
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0x33FFFFFF)
                    : (hasRecord ? const Color(0x1AF8660A) : const Color(0xFFE4E8EE)),
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasRecord ? Icons.check : Icons.add,
                size: 18,
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

String _weekdayLabel(int weekday) {
  const labels = <String>['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
  return labels[weekday - 1];
}

bool _isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}
