import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';

import '../design/ds.dart';
import '../design/widgets.dart';
import '../pages/outfit_detail_page.dart';
import '../pages/virtual_closet_page.dart';
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
        final todays = store.outfitsOn(now);
        final heroImage = todays.isNotEmpty
            ? todays.first.imagePath
            : (store.outfits.isNotEmpty ? store.outfits.first.imagePath : '');
        final heroHeight =
            (MediaQuery.of(context).size.width - DsSpace.md * 2) * 1.2;

        return Scaffold(
          backgroundColor: DsColors.paper,
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(DsSpace.md),
              children: [
                _HeaderRow(date: now),
                const SizedBox(height: DsSpace.md),
                _HeroCard(
                  imagePath: heroImage,
                  height: heroHeight.clamp(360, 560).toDouble(),
                  onCameraTap: () => _pickImageAndSave(context, now),
                ),
                const SizedBox(height: DsSpace.md),
                _ClosetBanner(
                  onTap: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => VirtualClosetPage(
                          store: store,
                          refresh: refresh,
                          onRefresh: onRefresh,
                        ),
                      ),
                    );
                  },
                ),
                _WeekSection(
                  StoreSnapshot(
                    store: store,
                    refresh: refresh,
                    onRefresh: onRefresh,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickImageAndSave(BuildContext context, DateTime date) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('拍照'),
                onTap: () => Navigator.of(context).pop('camera'),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('从相册选择'),
                onTap: () => Navigator.of(context).pop('gallery'),
              ),
            ],
          ),
        );
      },
    );
    if (action == null || !context.mounted) return;

    final source = action == 'camera'
        ? ImageSource.camera
        : ImageSource.gallery;
    final picker = ImagePicker();
    final file = await picker.pickImage(source: source, imageQuality: 85);
    if (file == null) return;

    await store.upsertOutfit(
      imageSourcePath: file.path,
      date: date,
      note: '',
      tags: const <String>[],
      closetItemIds: const <String>[],
    );
    onRefresh();
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('已保存今日穿搭')));
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
                  Icon(
                    Icons.wb_sunny_rounded,
                    color: Color(0xFFF45E06),
                    size: 24,
                  ),
                  SizedBox(width: 4),
                  Text(
                    '晴 24℃',
                    style: TextStyle(
                      color: Color(0xFFF45E06),
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          width: 56,
          height: 56,
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
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('通知中心即将开放')));
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
    required this.onCameraTap,
  });

  final String imagePath;
  final double height;
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
            right: 12,
            bottom: 14,
            child: InkWell(
              onTap: onCameraTap,
              borderRadius: BorderRadius.circular(32),
              child: Container(
                width: 58,
                height: 58,
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 236, 120, 48),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x30F9650A),
                      blurRadius: 18,
                      offset: Offset(0, 9),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.camera_alt_outlined,
                  color: Colors.white,
                  size: 40,
                ),
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
        height: 160,
        decoration: BoxDecoration(
          borderRadius: DsRadius.lg,
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xFF1D2744), Color(0xFF6A4A30)],
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x22000000),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
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
              child: const Icon(
                Icons.door_sliding_outlined,
                color: Color(0xFFE5E9F0),
                size: 52,
              ),
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
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '管理你的个人时尚收藏',
                    style: TextStyle(
                      color: Color(0xFFD0D7E3),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '点击推门开启 →',
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

class StoreSnapshot {
  const StoreSnapshot({
    required this.store,
    required this.refresh,
    required this.onRefresh,
  });

  final LocalStore store;
  final ValueNotifier<int> refresh;
  final VoidCallback onRefresh;
}

class _WeekSection extends StatelessWidget {
  const _WeekSection(this.snapshot);

  final StoreSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
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
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('切换到“日历”页查看全部记录')));
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
            final entries = snapshot.store.outfitsOn(day);
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: index == days.length - 1 ? 0 : 6,
                ),
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
                          store: snapshot.store,
                          refresh: snapshot.refresh,
                          onRefresh: snapshot.onRefresh,
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
          border: outlined
              ? Border.all(color: const Color(0xFFF8660A), width: 1.3)
              : null,
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
                    : (hasRecord
                          ? const Color(0x1AF8660A)
                          : const Color(0xFFE4E8EE)),
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasRecord ? Icons.check : Icons.add,
                size: 12,
                color: selected
                    ? Colors.white
                    : (hasRecord
                          ? const Color(0xFFF8660A)
                          : const Color(0xFFAAB4C4)),
              ),
            ),
          ],
        ),
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
