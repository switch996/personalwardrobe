import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../design/ds.dart';
import '../design/widgets.dart';
import '../models/closet_item.dart';
import '../pages/closet_item_detail_page.dart';
import '../pages/virtual_closet_page.dart';
import '../store/local_store.dart';

class TodayPage extends StatelessWidget {
  const TodayPage({
    super.key,
    required this.store,
    required this.refresh,
    required this.onRefresh,
    this.onNavigateTab,
  });

  final LocalStore store;
  final ValueNotifier<int> refresh;
  final VoidCallback onRefresh;
  final ValueChanged<int>? onNavigateTab;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: refresh,
      builder: (context, value, child) {
        final now = DateTime.now();
        final todays = store.outfitsOn(now);
        final fallbackSeed = now.year * 10000 + now.month * 100 + now.day;
        final heroImage = todays.isNotEmpty
            ? todays.first.imagePath
            : (store.outfits.isNotEmpty ? store.outfits.first.imagePath : '');
        final heroHeight =
            ((MediaQuery.of(context).size.width - DsSpace.md * 2) * 1.18)
                .clamp(360.0, 560.0)
                .toDouble();

        return Scaffold(
          backgroundColor: DsColors.paper,
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(DsSpace.md),
              children: [
                _HeaderRow(date: now),
                const SizedBox(height: 14),
                _HeroCard(
                  imagePath: heroImage,
                  height: heroHeight,
                  placeholderSeed: fallbackSeed,
                  onCameraTap: () => _pickImageAndSave(context, now),
                ),
                const SizedBox(height: 16),
                _TodayWearList(
                  store: store,
                  refresh: refresh,
                  onRefresh: onRefresh,
                ),
                const SizedBox(height: 16),
                _ClosetSummaryCard(
                  onEnterCloset: () => _openCloset(context),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _openCloset(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => VirtualClosetPage(
          store: store,
          refresh: refresh,
          onRefresh: onRefresh,
          onNavigateTab: onNavigateTab,
        ),
      ),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${date.year}年${date.month}月${date.day}日',
                style: const TextStyle(
                  color: DsColors.ink,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  height: 1.05,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0x1AD32F2F),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0x33D32F2F)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.wb_sunny_rounded,
                      color: Color(0xFFD32F2F),
                      size: 18,
                    ),
                    SizedBox(width: 6),
                    Text(
                      '晴 24°C',
                      style: TextStyle(
                        color: Color(0xFFD32F2F),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFE3E3E3)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x12000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('通知中心即将开放')),
              );
            },
            icon: const Icon(Icons.notifications_outlined, color: DsColors.ink),
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
    required this.placeholderSeed,
    required this.onCameraTap,
  });

  final String imagePath;
  final double height;
  final int placeholderSeed;
  final VoidCallback onCameraTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE7E7E7)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(8),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: imagePath.trim().isEmpty
                  ? AppImage(
                      path: _apiPlaceholderUrl(placeholderSeed),
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : AppImage(
                      path: imagePath,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
            ),
          ),
          Positioned(
            right: 12,
            bottom: 12,
            child: InkWell(
              onTap: onCameraTap,
              borderRadius: BorderRadius.circular(28),
              child: Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: Color(0xFFD32F2F),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x33D32F2F),
                      blurRadius: 16,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.camera_alt_outlined,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _apiPlaceholderUrl(int seed) {
    return 'https://loremflickr.com/900/1200/fashion,outfit?lock=$seed';
  }
}

class _TodayWearList extends StatelessWidget {
  const _TodayWearList({
    required this.store,
    required this.refresh,
    required this.onRefresh,
  });

  final LocalStore store;
  final ValueNotifier<int> refresh;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final items = store.quickWearItemsForToday();
    final now = DateTime.now();
    final dateLabel = '${now.month}月${now.day}日';
    const accentBackground = Color(0x1AD32F2F);
    const accentBorder = Color(0x33D32F2F);
    const chipBackground = Color(0x33D32F2F);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFFFFF), Color(0xFFF5F5F5)],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26D32F2F),
            blurRadius: 24,
            offset: Offset(0, 14),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '今日穿搭单品',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: DsColors.ink,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: chipBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${items.length} 件',
                  style: const TextStyle(
                    color: Color(0xFFD32F2F),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                dateLabel,
                style: const TextStyle(
                  color: Color(0xFFD32F2F),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.info_outline,
                size: 18,
                color: Color(0xFFE53935),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '在单品详情点击“立刻穿上”添加，长按单品卡片可删除。',
                  style: const TextStyle(
                    color: Color(0xFFD32F2F),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (items.isEmpty)
            Container(
              height: 110,
              decoration: BoxDecoration(
                color: accentBackground,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: accentBorder),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.centerLeft,
              child: const Text(
                '今日还没有选定单品，去逛逛衣橱挑一件吧～',
                style: TextStyle(
                  color: Color(0xFFD32F2F),
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            SizedBox(
              height: 210,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: items.length,
                separatorBuilder: (context, _) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return _QuickWearItemCard(
                    item: item,
                    onTap: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ClosetItemDetailPage(
                            itemId: item.id,
                            store: store,
                            refresh: refresh,
                            onRefresh: onRefresh,
                          ),
                        ),
                      );
                    },
                    onRemove: () async {
                      final removed = await store.removeQuickWearItem(item.id);
                      if (removed) {
                        onRefresh();
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('已移除 ${item.name}')),
                        );
                      }
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

class _QuickWearItemCard extends StatefulWidget {
  const _QuickWearItemCard({
    required this.item,
    required this.onTap,
    required this.onRemove,
  });

  final ClosetItem item;
  final VoidCallback onTap;
  final Future<void> Function() onRemove;

  @override
  State<_QuickWearItemCard> createState() => _QuickWearItemCardState();
}

class _QuickWearItemCardState extends State<_QuickWearItemCard> {
  bool _showDelete = false;

  void _handleTap() {
    if (_showDelete) {
      setState(() => _showDelete = false);
      return;
    }
    widget.onTap();
  }

  void _handleLongPress() {
    if (!_showDelete) {
      setState(() => _showDelete = true);
    }
  }

  Future<void> _handleRemove() async {
    await widget.onRemove();
    if (mounted) {
      setState(() => _showDelete = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final brandText = widget.item.brand.isEmpty ? '未设置品牌' : widget.item.brand;
    return SizedBox(
      width: 140,
      child: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: GestureDetector(
                    onTap: _handleTap,
                    onLongPress: _handleLongPress,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: AppImage(
                        path: widget.item.imagePath,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 6,
                  top: 6,
                  child: IgnorePointer(
                    ignoring: !_showDelete,
                    child: AnimatedOpacity(
                      opacity: _showDelete ? 1 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: _RemoveBadge(onRemove: _handleRemove),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: Text(
              widget.item.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
          ),
          const SizedBox(height: 2),
          SizedBox(
            width: double.infinity,
            child: Text(
              '${LocalStore.categoryLabel(widget.item.category)} · $brandText',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: DsColors.mutedInk),
            ),
          ),
        ],
      ),
    );
  }
}

class _RemoveBadge extends StatelessWidget {
  const _RemoveBadge({required this.onRemove});

  final Future<void> Function() onRemove;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xCC1F1F1F),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onRemove,
        borderRadius: BorderRadius.circular(14),
        child: const SizedBox(
          width: 28,
          height: 28,
          child: Icon(Icons.close, color: Colors.white, size: 18),
        ),
      ),
    );
  }
}

class _ClosetSummaryCard extends StatelessWidget {
  const _ClosetSummaryCard({required this.onEnterCloset});

  final VoidCallback onEnterCloset;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onEnterCloset,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE8E8E8)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 14,
              offset: Offset(0, 7),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '我的衣橱',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: DsColors.ink,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    '打造你的风格',
                    style: TextStyle(
                      color: DsColors.mutedInk,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Text(
              '→',
              style: TextStyle(
                color: Color(0xFFD32F2F),
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
