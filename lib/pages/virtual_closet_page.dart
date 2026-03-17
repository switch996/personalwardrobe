import 'package:flutter/material.dart';

import '../design/app_bottom_nav.dart';
import '../design/ds.dart';
import '../design/widgets.dart';
import '../models/closet_item.dart';
import '../pages/closet_item_detail_page.dart';
import '../sheets/closet_item_editor_sheet.dart';
import '../store/local_store.dart';

class VirtualClosetPage extends StatefulWidget {
  const VirtualClosetPage({
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
  State<VirtualClosetPage> createState() => _VirtualClosetPageState();
}

class _VirtualClosetPageState extends State<VirtualClosetPage> {
  bool _byType = true;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: widget.refresh,
      builder: (context, value, child) {
        return Scaffold(
          backgroundColor: DsColors.paper,
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                _TopBar(onBack: () => Navigator.of(context).pop()),
                const SizedBox(height: 10),
                _FilterSwitch(
                  byType: _byType,
                  onChange: (value) => setState(() => _byType = value),
                ),
                const SizedBox(height: 20),
                _FloatBoard(
                  store: widget.store,
                  byType: _byType,
                  refresh: widget.refresh,
                  onRefresh: widget.onRefresh,
                ),
                const SizedBox(height: 24),
                _TodayWearList(
                  store: widget.store,
                  refresh: widget.refresh,
                  onRefresh: widget.onRefresh,
                ),
              ],
            ),
          ),
          bottomNavigationBar: widget.onNavigateTab == null
              ? AppBottomNav(
                  selectedIndex: 0,
                  firstTab: AppBottomNavFirstTab.home,
                  onDestinationSelected: (value) async {
                    switch (value) {
                      case 0:
                        widget.onNavigateTab?.call(value);
                        break;
                      case 1:
                        if (widget.onNavigateTab != null) {
                          widget.onNavigateTab!(value);
                        } else {
                          Navigator.of(context).pop(value);
                        }
                        break;
                      case 2:
                        final changed = await showClosetItemEditorSheet(
                          context,
                          store: widget.store,
                        );
                        if (changed == true) widget.onRefresh();
                        break;
                      case 3:
                        if (widget.onNavigateTab != null) {
                          widget.onNavigateTab!(value);
                        } else {
                          Navigator.of(context).pop(value);
                        }
                        break;
                      case 4:
                        if (widget.onNavigateTab != null) {
                          widget.onNavigateTab!(value);
                        } else {
                          Navigator.of(context).pop(value);
                        }
                        break;
                    }
                  },
                )
              : null,
        );
      },
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
        ),
        const Expanded(
          child: Center(
            child: Text(
              '我的虚拟衣橱',
              style: TextStyle(
                color: DsColors.ink,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        const SizedBox(width: 48),
      ],
    );
  }
}

class _FilterSwitch extends StatelessWidget {
  const _FilterSwitch({required this.byType, required this.onChange});

  final bool byType;
  final ValueChanged<bool> onChange;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: DsColors.line),
      ),
      child: Row(
        children: [
          _SwitchCell(
            selected: byType,
            text: '按类型',
            onTap: () => onChange(true),
          ),
          _SwitchCell(
            selected: !byType,
            text: '按品牌',
            onTap: () => onChange(false),
          ),
        ],
      ),
    );
  }
}

class _SwitchCell extends StatelessWidget {
  const _SwitchCell({
    required this.selected,
    required this.text,
    required this.onTap,
  });

  final bool selected;
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(11),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
            boxShadow: selected
                ? const [
                    BoxShadow(
                      color: Color(0x15000000),
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Text(
            text,
            style: TextStyle(
              color: selected ? DsColors.ink : DsColors.mutedInk,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
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

// ignore: unused_element
class _LegacyFloatBoard extends StatelessWidget {
  const _LegacyFloatBoard({
    required this.store,
    required this.byType,
    required this.refresh,
    required this.onRefresh,
  });

  final LocalStore store;
  final bool byType;
  final ValueNotifier<int> refresh;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final unmatchedTypeCount = _unmatchedTypeCount();
    final brandlessCount = _brandlessCount();
    final showTypeAlert = byType && unmatchedTypeCount > 0;
    final showBrandAlert = !byType && brandlessCount > 0;

    final categories = LocalStore.closetCategories;
    final iconWidgets = categories.map((category) {
      final item = _firstByCategory(category);
      final labelFallback = LocalStore.categoryLabel(category);
      return _FloatIcon(
        label: _labelFor(item, labelFallback),
        icon: _iconForCategory(category),
        highlighted: category == 'dress',
        onTap: () => _openList(context, category: category, item: item),
      );
    }).toList();

    final alerts = <Widget>[];
    if (showTypeAlert) {
      alerts.add(
        _FloatIcon(
          label: '待匹配类型',
          icon: Icons.help_outline,
          onTap: () => _showMissingTypeNotice(context, unmatchedTypeCount),
        ),
      );
    }
    if (showBrandAlert) {
      alerts.add(
        _FloatIcon(
          label: '未设置品牌',
          icon: Icons.new_label_outlined,
          onTap: () => _showMissingBrandNotice(context, brandlessCount),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Wrap(
            alignment: WrapAlignment.spaceEvenly,
            runSpacing: 28,
            spacing: 12,
            children: iconWidgets,
          ),
          if (alerts.isNotEmpty) ...[
            const SizedBox(height: 24),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 18,
              runSpacing: 18,
              children: alerts,
            ),
          ],
        ],
      ),
    );
  }

  ClosetItem? _firstByCategory(String category) {
    for (final item in store.closet) {
      if (item.category == category) return item;
    }
    return null;
  }

  String _labelFor(ClosetItem? item, String typeLabel) {
    if (byType) {
      return item == null ? typeLabel : LocalStore.categoryLabel(item.category);
    }
    final brand = item?.brand.trim() ?? '';
    return brand.isEmpty ? '未设置品牌' : brand;
  }

  void _openList(
    BuildContext context, {
    required String category,
    ClosetItem? item,
  }) {
    if (byType) {
      final title = '${LocalStore.categoryLabel(category)}列表';
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CategoryListPage(
            store: store,
            refresh: refresh,
            onRefresh: onRefresh,
            title: title,
            category: category,
          ),
        ),
      );
    } else {
      final brandValue = item?.brand.trim() ?? '';
      final display = brandValue.isEmpty ? '未设置品牌' : brandValue;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CategoryListPage(
            store: store,
            refresh: refresh,
            onRefresh: onRefresh,
            title: '$display 列表',
            brand: brandValue,
          ),
        ),
      );
    }
  }

  int _unmatchedTypeCount() {
    final displayed = LocalStore.closetCategories.toSet();
    return store.closet
        .where((item) => !displayed.contains(item.category))
        .length;
  }

  int _brandlessCount() {
    return store.closet.where((item) => item.brand.trim().isEmpty).length;
  }

  void _showMissingTypeNotice(BuildContext context, int count) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('当前有$count 件单品未匹配到展示类型，可前往衣橱补充分类')));
  }

  void _showMissingBrandNotice(BuildContext context, int count) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('当前有$count 件单品未设置品牌，建议完善信息方便筛选')));
  }

  IconData _iconForCategory(String category) {
    switch (category) {
      case 'top':
        return Icons.checkroom_outlined;
      case 'bottom':
        return Icons.view_day_outlined;
      case 'shoes':
        return Icons.hiking_outlined;
      case 'accessory':
        return Icons.auto_awesome_outlined;
      case 'outerwear':
        return Icons.downhill_skiing_outlined;
      case 'dress':
        return Icons.dry_cleaning;
      case 'bag':
        return Icons.shopping_bag_outlined;
      default:
        return Icons.category_outlined;
    }
  }
}

class _FloatBoard extends StatelessWidget {
  const _FloatBoard({
    required this.store,
    required this.byType,
    required this.refresh,
    required this.onRefresh,
  });

  final LocalStore store;
  final bool byType;
  final ValueNotifier<int> refresh;
  final VoidCallback onRefresh;

  static const List<_VirtualIconType> _types = <_VirtualIconType>[
    _VirtualIconType(
      key: 'top',
      label: '\u4e0a\u88c5',
      icon: Icons.checkroom_outlined,
      sourceCategory: 'top',
    ),
    _VirtualIconType(
      key: 'bottom',
      label: '\u4e0b\u88c5',
      icon: Icons.straighten_outlined,
      sourceCategory: 'bottom',
    ),
    _VirtualIconType(
      key: 'outerwear',
      label: '\u5916\u5957',
      icon: Icons.dry_cleaning_outlined,
      sourceCategory: 'outerwear',
    ),
    _VirtualIconType(
      key: 'shoes',
      label: '\u978b\u5b50',
      icon: Icons.hiking_outlined,
      sourceCategory: 'shoes',
    ),
    _VirtualIconType(
      key: 'bag',
      label: '\u5305\u888b',
      icon: Icons.shopping_bag_outlined,
      sourceCategory: 'bag',
    ),
    _VirtualIconType(
      key: 'accessory',
      label: '\u914d\u9970',
      icon: Icons.emoji_people_outlined,
      sourceCategory: 'accessory',
      subOptions: <String>['\u5e3d\u5b50', '\u56f4\u5dfe', '\u8170\u5e26'],
    ),
    _VirtualIconType(
      key: 'jewelry',
      label: '\u9996\u9970',
      icon: Icons.diamond_outlined,
      sourceCategory: 'accessory',
      subOptions: <String>['\u9879\u94fe', '\u6212\u6307', '\u8033\u9970'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final iconWidgets = _types.map((type) {
      final item = _firstByType(type.key);
      return _FloatIcon(
        label: _labelFor(item, type.label),
        icon: type.icon,
        highlighted: false,
        onTap: () => _openList(context, type: type, item: item),
      );
    }).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Wrap(
        alignment: WrapAlignment.spaceEvenly,
        runSpacing: 28,
        spacing: 12,
        children: iconWidgets,
      ),
    );
  }

  ClosetItem? _firstByType(String typeKey) {
    for (final item in store.closet) {
      if (_matchesType(item, typeKey)) return item;
    }
    return null;
  }

  bool _matchesType(ClosetItem item, String typeKey) {
    switch (typeKey) {
      case 'top':
      case 'bottom':
      case 'outerwear':
      case 'shoes':
      case 'bag':
        return item.category == typeKey;
      case 'accessory':
        return _isAccessory(item);
      case 'jewelry':
        return _isJewelry(item);
      default:
        return false;
    }
  }

  bool _isAccessory(ClosetItem item) {
    if (item.category != 'accessory') return false;
    return !_isJewelry(item);
  }

  bool _isJewelry(ClosetItem item) {
    if (item.category != 'accessory') return false;
    final text = '${item.subCategory} ${item.name}'.toLowerCase();
    const keywords = <String>[
      '\u9879\u94fe',
      '\u6212\u6307',
      '\u8033\u9970',
      '\u8033\u73af',
      '\u9996\u9970',
      '\u73e0\u5b9d',
      '\u624b\u94fe',
      '\u624b\u9556',
      '\u80f8\u9488',
    ];
    return keywords.any(text.contains);
  }

  String _labelFor(ClosetItem? item, String typeLabel) {
    if (byType) return typeLabel;
    final brand = item?.brand.trim() ?? '';
    return brand.isEmpty ? '\u672a\u8bbe\u7f6e\u54c1\u724c' : brand;
  }

  void _openList(
    BuildContext context, {
    required _VirtualIconType type,
    ClosetItem? item,
  }) {
    if (byType) {
      final title = '${type.label}\u5217\u8868';
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CategoryListPage(
            store: store,
            refresh: refresh,
            onRefresh: onRefresh,
            title: title,
            category: type.sourceCategory,
            itemMatcher: (item) => _matchesType(item, type.key),
            subOptions: type.subOptions,
          ),
        ),
      );
      return;
    }

    final brandValue = item?.brand.trim() ?? '';
    final display = brandValue.isEmpty ? '\u672a\u8bbe\u7f6e\u54c1\u724c' : brandValue;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CategoryListPage(
          store: store,
          refresh: refresh,
          onRefresh: onRefresh,
          title: '$display \u5217\u8868',
          brand: brandValue,
        ),
      ),
    );
  }
}

class _VirtualIconType {
  const _VirtualIconType({
    required this.key,
    required this.label,
    required this.icon,
    required this.sourceCategory,
    this.subOptions,
  });

  final String key;
  final String label;
  final IconData icon;
  final String sourceCategory;
  final List<String>? subOptions;
}

class _FloatIcon extends StatefulWidget {
  const _FloatIcon({
    required this.label,
    required this.icon,
    this.highlighted = false,
    this.onTap,
  });

  final String label;
  final IconData icon;
  final bool highlighted;
  final VoidCallback? onTap;

  @override
  State<_FloatIcon> createState() => _FloatIconState();
}

class _FloatIconState extends State<_FloatIcon> {
  bool _forward = true;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 2400),
      tween: Tween(begin: _forward ? -6 : 6, end: _forward ? 6 : -6),
      curve: Curves.easeInOut,
      onEnd: () => setState(() => _forward = !_forward),
      builder: (context, value, child) =>
          Transform.translate(offset: Offset(0, value), child: child),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: widget.highlighted ? 84 : 70,
              height: widget.highlighted ? 84 : 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: widget.highlighted
                    ? Border.all(color: const Color(0xFFF8C6C6), width: 3)
                    : null,
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                widget.icon,
                color: widget.highlighted ? DsColors.copper : DsColors.ink,
                size: widget.highlighted ? 40 : 34,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: widget.highlighted ? 32 : 26,
              height: 6,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0x1A000000), Color(0x05000000)],
                ),
                borderRadius: BorderRadius.all(Radius.circular(3)),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              widget.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: widget.highlighted ? DsColors.copper : DsColors.ink,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryListPage extends StatefulWidget {
  const CategoryListPage({
    super.key,
    required this.store,
    required this.refresh,
    required this.onRefresh,
    required this.title,
    this.category,
    this.brand,
    this.itemMatcher,
    this.subOptions,
  });

  final LocalStore store;
  final ValueNotifier<int> refresh;
  final VoidCallback onRefresh;
  final String title;
  final String? category;
  final String? brand;
  final bool Function(ClosetItem item)? itemMatcher;
  final List<String>? subOptions;

  @override
  State<CategoryListPage> createState() => _CategoryListPageState();
}

class _CategoryListPageState extends State<CategoryListPage> {
  final TextEditingController _search = TextEditingController();
  String _subFilter = '全部';

  @override
  void initState() {
    super.initState();
    _search.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: ValueListenableBuilder<int>(
          valueListenable: widget.refresh,
          builder: (context, value, _) {
            final items = _filteredItems();
            final subOptions = widget.subOptions ??
                (widget.category == null
                    ? const <String>[]
                    : LocalStore.subCategoryOptions(widget.category!));
            if (!subOptions.contains(_subFilter) && _subFilter != '全部') {
              _subFilter = '全部';
            }
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            widget.title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: DsColors.ink,
                            ),
                          ),
                          const SizedBox(height: 4),
                        ],
                      ),
                    ),
                    Text(
                      '共${items.length}件单品',
                      style: const TextStyle(color: DsColors.mutedInk),
                    ),
                  ],
                ),
                const SizedBox(height: DsSpace.md),
                _SearchField(controller: _search),
                if (subOptions.isNotEmpty) ...[
                  const SizedBox(height: DsSpace.sm),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _FilterChip(
                          label: '全部',
                          selected: _subFilter == '全部',
                          onSelected: () => setState(() => _subFilter = '全部'),
                        ),
                        ...subOptions.map(
                          (label) => _FilterChip(
                            label: label,
                            selected: _subFilter == label,
                            onSelected: () =>
                                setState(() => _subFilter = label),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: DsSpace.md),
                if (items.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 60),
                    child: EmptyState(
                      title: '暂无单品',
                      caption: '尝试更换筛选或先去添加新单品吧',
                    ),
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.74,
                        ),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return InkWell(
                        borderRadius: BorderRadius.circular(24),
                        onTap: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ClosetItemDetailPage(
                                itemId: item.id,
                                store: widget.store,
                                refresh: widget.refresh,
                                onRefresh: widget.onRefresh,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: const [
                              BoxShadow(
                                color: DsColors.shadow,
                                blurRadius: 16,
                                offset: Offset(0, 8),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: AppImage(
                                    path: item.imagePath,
                                    width: double.infinity,
                                    height: double.infinity,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                item.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<ClosetItem> _filteredItems() {
    final query = _search.text.trim().toLowerCase();
    final filtered = widget.store.closet.where((item) {
      if (widget.itemMatcher != null && !widget.itemMatcher!(item)) {
        return false;
      }
      if (widget.category != null && item.category != widget.category) {
        return false;
      }
      if (widget.brand != null && item.brand.trim() != widget.brand) {
        return false;
      }
      if (_subFilter != '全部' && item.subCategory != _subFilter) return false;
      if (query.isNotEmpty && !item.name.toLowerCase().contains(query)) {
        return false;
      }
      return true;
    }).toList();
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return filtered;
  }

}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: '搜索我的衣橱...',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onSelected(),
        selectedColor: DsColors.copper,
        labelStyle: TextStyle(
          color: selected ? Colors.white : DsColors.ink,
          fontWeight: FontWeight.w600,
        ),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );
  }
}
