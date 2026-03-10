import 'package:flutter/material.dart';

import '../design/ds.dart';
import '../design/widgets.dart';
import '../models/closet_item.dart';
import '../sheets/closet_item_editor_sheet.dart';
import '../store/local_store.dart';
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

    return Scaffold(
      backgroundColor: DsColors.paper,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            Row(
              children: [
                _CircleButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: () => Navigator.of(context).pop(),
                ),
                const Spacer(),
                const Text('单品详情', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: DsColors.ink)),
                const Spacer(),
                _CircleButton(
                  icon: Icons.share_outlined,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('分享功能即将上线')));
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                color: Colors.white,
                boxShadow: const [BoxShadow(color: DsColors.shadow, blurRadius: 25, offset: Offset(0, 14))],
              ),
              padding: const EdgeInsets.all(12),
              child: AppImage(path: item.imagePath, height: 280, width: double.infinity, radius: BorderRadius.circular(22)),
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: DsColors.ink)),
                      const SizedBox(height: 6),
                      Text(
                        _tagLine(item),
                        style: const TextStyle(color: Color(0xFFEA7F2C), fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                _CircleButton(
                  icon: Icons.favorite_border,
                  onTap: () {},
                  background: Colors.white,
                  iconColor: const Color(0xFFEA680E),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _InfoCard(
              children: [
                _InfoRow(icon: Icons.price_check_outlined, label: '价格', value: item.price <= 0 ? '未填写' : '¥${item.price.toStringAsFixed(0)}', highlight: item.price > 0),
                _InfoRow(
                  icon: Icons.straighten_outlined,
                  label: '尺码',
                  value: item.subCategory.isEmpty ? '标准' : item.subCategory,
                ),
                _InfoRow(icon: Icons.palette_outlined, label: '材质', value: item.color.isEmpty ? '未填写' : item.color),
                _InfoRow(icon: Icons.event_outlined, label: '购买日期', value: _formatDate(item.createdAt)),
              ],
            ),
            const SizedBox(height: 20),
            const Text('穿搭笔记', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: DsColors.ink)),
            const SizedBox(height: 8),
            Text(
              item.note.isEmpty ? '这件单品还没有备注，试着写下今日的穿搭灵感吧。' : item.note,
              style: const TextStyle(color: DsColors.mutedInk, height: 1.4),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final changed = await showClosetItemEditorSheet(context, store: store, editing: item);
                      if (changed == true) onRefresh();
                    },
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('修改资料'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: DsColors.ink,
                      side: const BorderSide(color: DsColors.line),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('试穿功能即将上线')));
                    },
                    icon: const Icon(Icons.checkroom_outlined),
                    label: const Text('立即试穿'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFFF7B1B),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    ),
                  ),
                ),
              ],
            ),
            TextButton(
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
              child: const Text('删除单品', style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _tagLine(ClosetItem item) {
    final tags = <String>[];
    if (item.brand.isNotEmpty) tags.add(item.brand);
    tags.add(LocalStore.categoryLabel(item.category));
    return tags.join(' · ');
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFFF7EBF1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFFB77A83)),
          ),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: Color(0xFF7C6A73))),
          const Spacer(),
          Text(
            value.isEmpty ? '—' : value,
            style: TextStyle(
              color: highlight ? const Color(0xFFF45C9F) : DsColors.ink,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.icon,
    required this.onTap,
    this.background = Colors.white,
    this.iconColor = DsColors.ink,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color background;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: background,
          shape: BoxShape.circle,
          boxShadow: const [BoxShadow(color: DsColors.shadow, blurRadius: 12, offset: Offset(0, 6))],
        ),
        child: Icon(icon, color: iconColor, size: 18),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [BoxShadow(color: DsColors.shadow, blurRadius: 20, offset: Offset(0, 10))],
      ),
      child: Column(children: children),
    );
  }
}
