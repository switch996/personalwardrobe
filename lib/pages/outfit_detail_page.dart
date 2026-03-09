import 'package:flutter/material.dart';

import '../design/ds.dart';
import '../design/widgets.dart';
import '../models/closet_item.dart';
import '../sheets/outfit_editor_sheet.dart';
import '../store/local_store.dart';
import '../utils/date.dart';
import '../utils/dialog.dart';

class OutfitDetailPage extends StatelessWidget {
  const OutfitDetailPage({
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
    final entry = store.outfits.where((e) => e.id == entryId).firstOrNull;
    if (entry == null) {
      return const Scaffold(body: Center(child: Text('Outfit not found.')));
    }

    final relatedItems = store.closet.where((c) => entry.closetItemIds.contains(c.id)).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Outfit Detail'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () async {
              final changed = await showOutfitEditorSheet(
                context,
                store: store,
                editing: entry,
                initialDate: entry.date,
              );
              if (changed == true) onRefresh();
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              final ok = await confirmDialog(
                context,
                title: 'Delete',
                message: 'Delete this outfit record?',
              );
              if (!ok) return;
              await store.deleteOutfit(entry.id);
              onRefresh();
              if (context.mounted) Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(DsSpace.md),
        children: [
          AppImage(path: entry.imagePath, height: 280, width: double.infinity, radius: DsRadius.lg),
          const SizedBox(height: DsSpace.md),
          PaperCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ymd(entry.date), style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 8),
                Text(entry.note.isEmpty ? '(no note)' : entry.note),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: entry.tags.map((e) => Chip(label: Text(e))).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: DsSpace.md),
          const SectionTitle('Related Closet Items'),
          const SizedBox(height: DsSpace.sm),
          if (relatedItems.isEmpty)
            const EmptyState(title: 'No linked item', caption: 'Edit this record to link closet items.')
          else
            ...relatedItems.map((item) => _relatedItemCard(context, item)),
        ],
      ),
    );
  }

  Widget _relatedItemCard(BuildContext context, ClosetItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: DsSpace.sm),
      child: PaperCard(
        padding: const EdgeInsets.all(DsSpace.sm),
        child: Row(
          children: [
            AppImage(path: item.imagePath, width: 64, height: 64),
            const SizedBox(width: DsSpace.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, style: Theme.of(context).textTheme.titleMedium),
                  Text(item.category, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
