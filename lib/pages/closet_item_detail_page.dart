import 'package:flutter/material.dart';

import '../design/ds.dart';
import '../design/widgets.dart';
import '../models/closet_item.dart';
import '../pages/outfit_detail_page.dart';
import '../sheets/closet_item_editor_sheet.dart';
import '../store/local_store.dart';
import '../utils/date.dart';
import '../utils/dialog.dart';

class ClosetItemDetailPage extends StatelessWidget {
  const ClosetItemDetailPage({
    super.key,
    required this.itemId,
    required this.store,
    required this.refresh,
    required this.onRefresh,
  });

  final String itemId;
  final LocalStore store;
  final ValueNotifier<int> refresh;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final item = store.closet.where((e) => e.id == itemId).firstOrNull;
    if (item == null) {
      return const Scaffold(body: Center(child: Text('未找到该单品')));
    }
    final usedBy = store.outfitsUsingItem(item.id);

    return Scaffold(
      appBar: AppBar(
        title: const Text('单品详情'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () async {
              final changed = await showClosetItemEditorSheet(context, store: store, editing: item);
              if (changed == true) onRefresh();
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              final ok = await confirmDialog(
                context,
                title: '确认删除',
                message: '删除后也会取消与穿搭的关联，确定继续？',
              );
              if (!ok) return;
              await store.deleteClosetItem(item.id);
              onRefresh();
              if (context.mounted) Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(DsSpace.md),
        children: [
          AppImage(path: item.imagePath, height: 300, width: double.infinity, radius: DsRadius.lg),
          const SizedBox(height: DsSpace.md),
          _metaCard(item, context),
          const SizedBox(height: DsSpace.md),
          const SectionTitle('使用记录'),
          const SizedBox(height: DsSpace.sm),
          if (usedBy.isEmpty)
            const EmptyState(title: '尚未被穿搭使用', caption: '在穿搭记录中关联后即可显示')
          else
            ...usedBy.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: DsSpace.sm),
                child: InkWell(
                  borderRadius: DsRadius.md,
                  onTap: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => OutfitDetailPage(
                          entryId: entry.id,
                          store: store,
                          refresh: refresh,
                          onRefresh: onRefresh,
                        ),
                      ),
                    );
                  },
                  child: PaperCard(
                    padding: const EdgeInsets.all(DsSpace.sm),
                    child: Row(
                      children: [
                        AppImage(path: entry.imagePath, width: 66, height: 66),
                        const SizedBox(width: DsSpace.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(ymd(entry.date), style: Theme.of(context).textTheme.bodySmall),
                              const SizedBox(height: 4),
                              Text(
                                entry.note.isEmpty ? '（暂无备注）' : entry.note,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _metaCard(ClosetItem item, BuildContext context) {
    return PaperCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.name, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text('分类：${LocalStore.categoryLabel(item.category)}'),
          if (item.subCategory.isNotEmpty) Text('子分类：${item.subCategory}'),
          Text(item.price <= 0 ? '价格：未填写' : '价格：¥${item.price.toStringAsFixed(0)}'),
          if (item.brand.isNotEmpty) Text('品牌：${item.brand}'),
          if (item.color.isNotEmpty) Text('颜色：${item.color}'),
          if (item.note.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(item.note),
          ],
        ],
      ),
    );
  }
}
