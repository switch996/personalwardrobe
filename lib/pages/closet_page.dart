import 'package:flutter/material.dart';

import '../design/ds.dart';
import '../design/widgets.dart';
import '../models/closet_item.dart';
import '../pages/closet_item_detail_page.dart';
import '../sheets/closet_item_editor_sheet.dart';
import '../store/local_store.dart';

class ClosetPage extends StatelessWidget {
  const ClosetPage({
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
        return AppScaffold(
          title: '衣橱',
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () async {
              final changed = await showClosetItemEditorSheet(context, store: store);
              if (changed == true) onRefresh();
            },
            label: const Text('新建单品'),
            icon: const Icon(Icons.add),
          ),
          body: Padding(
            padding: const EdgeInsets.all(DsSpace.md),
            child: store.closet.isEmpty
                ? const EmptyState(title: '衣橱还空着', caption: '点击右下角添加第一件单品')
                : GridView.builder(
                    itemCount: store.closet.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: DsSpace.sm,
                      mainAxisSpacing: DsSpace.sm,
                      childAspectRatio: 0.74,
                    ),
                    itemBuilder: (context, index) {
                      final item = store.closet[index];
                      return _ClosetGridItem(
                        item: item,
                        store: store,
                        refresh: refresh,
                        onRefresh: onRefresh,
                      );
                    },
                  ),
          ),
        );
      },
    );
  }
}

class _ClosetGridItem extends StatelessWidget {
  const _ClosetGridItem({
    required this.item,
    required this.store,
    required this.refresh,
    required this.onRefresh,
  });

  final ClosetItem item;
  final LocalStore store;
  final ValueNotifier<int> refresh;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: DsRadius.md,
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
      child: PaperCard(
        padding: const EdgeInsets.all(DsSpace.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppImage(path: item.imagePath, height: 128, width: double.infinity),
            const SizedBox(height: DsSpace.sm),
            Text(
              item.name,
              style: Theme.of(context).textTheme.titleMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 3),
            Text(LocalStore.categoryLabel(item.category), style: Theme.of(context).textTheme.bodySmall),
            if (item.subCategory.isNotEmpty) ...[
              const SizedBox(height: 3),
              Text(item.subCategory, style: Theme.of(context).textTheme.bodySmall),
            ],
            if (item.brand.isNotEmpty) ...[
              const SizedBox(height: 3),
              Text(
                item.brand,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 4),
            Text(
              item.price <= 0 ? '价格：未填写' : '价格：¥${item.price.toStringAsFixed(0)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
