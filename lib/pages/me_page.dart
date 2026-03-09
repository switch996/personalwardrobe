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
          title: 'Me',
          body: ListView(
            padding: const EdgeInsets.all(DsSpace.md),
            children: [
              const PaperCard(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: DsColors.paperDeep,
                    child: Icon(Icons.person_outline, color: DsColors.copper),
                  ),
                  title: Text('Personal Wardrobe'),
                  subtitle: Text('V1 local diary'),
                ),
              ),
              const SizedBox(height: DsSpace.md),
              PaperCard(
                child: Column(
                  children: [
                    _statLine('Outfit records', '$outfitCount'),
                    _statLine('Closet items', '$closetCount'),
                    _statLine('Tag types used', '${tags.length}'),
                  ],
                ),
              ),
              const SizedBox(height: DsSpace.md),
              const PaperCard(
                child: Text('Storage: local JSON + copied images under app_documents folder.'),
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
