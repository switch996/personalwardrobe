import 'package:flutter/material.dart';

import '../design/ds.dart';
import '../design/widgets.dart';
import '../models/closet_item.dart';
import '../models/outfit_entry.dart';
import '../store/local_store.dart';
import 'closet_item_detail_page.dart';

class DiaryOutfitDetailPage extends StatelessWidget {
  const DiaryOutfitDetailPage({
    super.key,
    required this.entryId,
    required this.store,
    required this.refresh,
    required this.onRefresh,
  });

  final String entryId;
  final LocalStore store;
  final ValueNotifier<int> refresh;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: refresh,
      builder: (context, value, child) {
        final entry = store.outfits.where((e) => e.id == entryId).firstOrNull;
        if (entry == null) {
          return Scaffold(
            backgroundColor: DsColors.paper,
            appBar: AppBar(title: const Text('穿搭详情')),
            body: const Center(child: Text('未找到该穿搭')),
          );
        }

        final relatedItems = _resolveRelatedItems(entry);
        return Scaffold(
          backgroundColor: DsColors.paper,
          body: SafeArea(
            child: Column(
              children: [
                _TopBar(date: entry.date),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                    children: [
                      _OutfitImageCard(path: entry.imagePath),
                      const SizedBox(height: 22),
                      const Text(
                        '搭配单品',
                        style: TextStyle(
                          color: Color(0xFFF07B1B),
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (relatedItems.isEmpty)
                        Container(
                          height: 120,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF6EFE5),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: DsColors.line),
                          ),
                          child: const Text(
                            '当天暂无搭配单品',
                            style: TextStyle(
                              color: DsColors.mutedInk,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      else
                        GridView.builder(
                          itemCount: relatedItems.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 14,
                                mainAxisSpacing: 14,
                                childAspectRatio: 0.76,
                              ),
                          itemBuilder: (context, index) {
                            final item = relatedItems[index];
                            return _ClosetItemTile(
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
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<ClosetItem> _resolveRelatedItems(OutfitEntry entry) {
    if (entry.closetItemIds.isEmpty) return const <ClosetItem>[];
    final lookup = <String, ClosetItem>{
      for (final item in store.closet) item.id: item,
    };
    return entry.closetItemIds
        .map((id) => lookup[id])
        .whereType<ClosetItem>()
        .toList();
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE8DAC8))),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 22,
              color: Color(0xFF9A6340),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                _dateLabel(date),
                style: const TextStyle(
                  color: Color(0xFF141A2D),
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('分享功能即将上线')));
            },
            icon: const Icon(
              Icons.share_outlined,
              size: 24,
              color: Color(0xFF9A6340),
            ),
          ),
        ],
      ),
    );
  }

  static String _dateLabel(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日';
  }
}

class _OutfitImageCard extends StatelessWidget {
  const _OutfitImageCard({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF3E8DE),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: AspectRatio(
        aspectRatio: 0.78,
        child: AppImage(
          path: path,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.contain,
          radius: BorderRadius.circular(18),
        ),
      ),
    );
  }
}

class _ClosetItemTile extends StatelessWidget {
  const _ClosetItemTile({required this.item, required this.onTap});

  final ClosetItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(18),
              ),
              child: AppImage(
                path: item.imagePath,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.contain,
                radius: BorderRadius.circular(18),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF11172A),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
