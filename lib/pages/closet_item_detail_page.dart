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
    Future<void> handleEdit() async {
      final changed = await showClosetItemEditorSheet(context, store: store, editing: item);
      if (changed == true) onRefresh();
    }

    Future<void> handleDelete() async {
      final ok = await confirmDialog(
        context,
        title: '确认删除',
        message: '删除后也会取消与穿搭的关联，确定继续？',
      );
      if (!ok) return;
      await store.deleteClosetItem(item.id);
      onRefresh();
      if (context.mounted) Navigator.of(context).pop();
    }

    Future<void> handleTry() async {
      await store.markItemAsWornToday(item.id);
      onRefresh();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已加入今日穿搭单品列表')));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 392),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 30),
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
                const SizedBox(height: 24),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: const Color(0xFFEFEFEF),
                    boxShadow: const [BoxShadow(color: DsColors.shadow, blurRadius: 20, offset: Offset(0, 10))],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: AppImage(
                    path: item.imagePath,
                    width: double.infinity,
                    fit: BoxFit.fitWidth,
                    radius: BorderRadius.circular(20),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.name, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: DsColors.ink)),
                          const SizedBox(height: 6),
                          Text(
                            _tagLine(item),
                            style: const TextStyle(color: Color(0xFF8A8A8A), fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      children: [
                        _ActionPill(
                          icon: Icons.edit_outlined,
                          onTap: handleEdit,
                          background: const Color(0xFFECECEC),
                          iconColor: const Color(0xFF2D2D2D),
                          tooltip: '修改资料',
                        ),
                        _ActionPill(
                          icon: Icons.delete_outline,
                          onTap: handleDelete,
                          background: const Color(0xFFECECEC),
                          iconColor: const Color(0xFFD32F2F),
                          tooltip: '删除单品',
                        ),
                        _ActionPill(
                          icon: Icons.checkroom_outlined,
                          onTap: () => handleTry(),
                          background: const Color(0xFFECECEC),
                          iconColor: const Color(0xFF2D2D2D),
                          tooltip: '立刻穿上',
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _InfoCard(
                  children: [
                    _InfoRow(icon: Icons.price_check_outlined, label: '价格', value: item.price <= 0 ? '未填写' : '¥${item.price.toStringAsFixed(0)}', highlight: item.price > 0),
                    _InfoRow(
                      icon: Icons.event_available_outlined,
                      label: '购买时间',
                      value: _formatDate(item.createdAt),
                    ),
                    _InfoRow(icon: Icons.category_outlined, label: '分类', value: LocalStore.categoryLabel(item.category)),
                    if (item.brand.isNotEmpty)
                      _InfoRow(
                        icon: Icons.store_mall_directory_outlined,
                        label: '品牌',
                        value: item.brand,
                      ),
                    _InfoRow(icon: Icons.palette_outlined, label: '颜色', value: item.color.isEmpty ? '未填写' : item.color),
                  ],
                ),
                const SizedBox(height: 24),
                const Text('备注信息', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: DsColors.ink)),
                const SizedBox(height: 10),
                Text(
                  item.note.isEmpty ? '这件单品还没有备注，试着写下灵感与搭配建议吧。' : item.note,
                  style: const TextStyle(color: DsColors.mutedInk, height: 1.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _tagLine(ClosetItem item) {
    final tags = <String>[];
    if (item.brand.isNotEmpty) tags.add(item.brand);
    tags.add(LocalStore.categoryLabel(item.category));
    return tags.join(' · ');
  }

  String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFFECECEC),
          shape: BoxShape.circle,
          boxShadow: const [BoxShadow(color: Color(0x12000000), blurRadius: 10, offset: Offset(0, 4))],
        ),
        child: Icon(icon, color: DsColors.ink, size: 18),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEAEAEA)),
        boxShadow: const [BoxShadow(color: Color(0x12000000), blurRadius: 14, offset: Offset(0, 6))],
      ),
      child: Column(children: children),
    );
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
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F1F1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF616161)),
          ),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: Color(0xFF6E6E6E))),
          const Spacer(),
          Text(
            value.isEmpty ? '—' : value,
            style: TextStyle(
              color: highlight ? const Color(0xFFD32F2F) : DsColors.ink,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionPill extends StatelessWidget {
  const _ActionPill({
    required this.icon,
    required this.onTap,
    this.background = Colors.white,
    this.iconColor = DsColors.ink,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color background;
  final Color iconColor;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final pill = GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: background,
          shape: BoxShape.circle,
          boxShadow: const [BoxShadow(color: Color(0x12000000), blurRadius: 10, offset: Offset(0, 4))],
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
    );
    if (tooltip == null) return pill;
    return Tooltip(message: tooltip!, child: pill);
  }
}
