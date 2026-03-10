import 'package:flutter/material.dart';

import '../design/ds.dart';
import '../design/widgets.dart';
import '../store/local_store.dart';

class MePage extends StatelessWidget {
  const MePage({super.key, required this.store, required this.refresh});

  final LocalStore store;
  final ValueNotifier<int> refresh;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: refresh,
      builder: (context, value, child) {
        final outfitCount = store.outfits.length;
        final closetCount = store.closet.length;
        final tags = <String>{};
        for (final o in store.outfits) {
          tags.addAll(o.tags);
        }

        return AppScaffold(
          title: '我的',
          body: ListView(
            padding: const EdgeInsets.all(DsSpace.md),
            children: [
              const PaperCard(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: DsColors.paperDeep,
                    child: Icon(Icons.person_outline, color: DsColors.copper),
                  ),
                  title: Text('衣橱日记'),
                  subtitle: Text('本地版 V1'),
                ),
              ),
              const SizedBox(height: DsSpace.md),
              PaperCard(
                child: Column(
                  children: [
                    _statLine('穿搭记录', '$outfitCount'),
                    _statLine('衣橱单品', '$closetCount'),
                    _statLine('使用过的标签', '${tags.length}'),
                  ],
                ),
              ),
              const SizedBox(height: DsSpace.md),
              const PaperCard(
                child: Text('存储方式：本地 JSON + app_documents 目录中的图片原图。'),
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget _statLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(label),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
