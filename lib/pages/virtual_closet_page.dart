import 'package:flutter/material.dart';

import '../design/app_bottom_nav.dart';
import '../design/ds.dart';
import '../design/widgets.dart';
import '../models/closet_item.dart';
import '../pages/closet_item_detail_page.dart';
import '../sheets/closet_item_editor_sheet.dart';
import '../store/local_store.dart';

const List<_ClosetCategory> _closetCategories = <_ClosetCategory>[
  _ClosetCategory(key: 'top', label: '上装'),
  _ClosetCategory(key: 'bottom', label: '下装'),
  _ClosetCategory(key: 'shoes', label: '鞋子'),
  _ClosetCategory(key: 'outerwear', label: '外套'),
  _ClosetCategory(key: 'bag', label: '包袋'),
  _ClosetCategory(key: 'accessory', label: '配饰'),
  _ClosetCategory(key: 'jewelry', label: '首饰'),
];

class _ClosetCategory {
  const _ClosetCategory({
    required this.key,
    required this.label,
  });

  final String key;
  final String label;
}

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
  final TextEditingController _search = TextEditingController();
  final Set<String> _likedItemIds = <String>{};
  String _selectedCategoryKey = _closetCategories.first.key;

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
    return ValueListenableBuilder<int>(
      valueListenable: widget.refresh,
      builder: (context, value, child) {
        final items = _filteredItems();
        return Scaffold(
          backgroundColor: const Color(0xFFF6F6F6),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              children: [
                const Text(
                  '我的虚拟衣橱',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1F1F1F),
                  ),
                ),
                const SizedBox(height: 10),
                _StoreSearchBar(controller: _search),
                const SizedBox(height: 12),
                SizedBox(
                  height: 38,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _closetCategories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final category = _closetCategories[index];
                      return _CategoryPill(
                        category: category,
                        selected: category.key == _selectedCategoryKey,
                        onTap: () => setState(() {
                          _selectedCategoryKey = category.key;
                        }),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  '${_selectedCategoryLabel} · ${items.length}件',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1F1F1F),
                  ),
                ),
                const SizedBox(height: 12),
                if (items.isEmpty)
                  const _ClosetEmptyState()
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 14,
                      childAspectRatio: 0.72,
                    ),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final liked = _likedItemIds.contains(item.id);
                      return _ProductCard(
                        item: item,
                        liked: liked,
                        onLikeTap: () => setState(() {
                          if (liked) {
                            _likedItemIds.remove(item.id);
                          } else {
                            _likedItemIds.add(item.id);
                          }
                        }),
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
                      );
                    },
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

  String get _selectedCategoryLabel {
    return _closetCategories
        .firstWhere((category) => category.key == _selectedCategoryKey)
        .label;
  }

  List<ClosetItem> _filteredItems() {
    final query = _search.text.trim().toLowerCase();
    final filtered = widget.store.closet.where((item) {
      if (item.category != _selectedCategoryKey) return false;
      final searchable = '${item.name} ${item.brand} ${item.subCategory}'.toLowerCase();
      if (query.isNotEmpty && !searchable.contains(query)) return false;
      return true;
    }).toList();
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return filtered;
  }
}

class _StoreSearchBar extends StatelessWidget {
  const _StoreSearchBar({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E5E5)),
      ),
      alignment: Alignment.center,
      child: TextField(
        controller: controller,
        decoration: const InputDecoration(
          hintText: '搜索我的单品',
          hintStyle: TextStyle(color: Color(0xFF9A9A9A), fontSize: 14),
          prefixIcon: Icon(Icons.search, color: Color(0xFF8D8D8D)),
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}

class _CategoryPill extends StatelessWidget {
  const _CategoryPill({
    required this.category,
    required this.selected,
    required this.onTap,
  });

  final _ClosetCategory category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bgColor = selected ? const Color(0xFFD32F2F) : const Color(0xFFEBEBEB);
    final textColor = selected ? Colors.white : const Color(0xFF4F4F4F);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          category.label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.item,
    required this.liked,
    required this.onLikeTap,
    required this.onTap,
  });

  final ClosetItem item;
  final bool liked;
  final VoidCallback onLikeTap;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x12000000),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(8),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: AppImage(
                      path: item.imagePath,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      radius: BorderRadius.circular(16),
                    ),
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: GestureDetector(
                      onTap: onLikeTap,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          color: Color(0xEFFFFFFF),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          liked ? Icons.favorite : Icons.favorite_border,
                          size: 18,
                          color: liked ? const Color(0xFFD32F2F) : const Color(0xFF444444),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: Text(
              item.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F1F1F),
              ),
            ),
          ),
          const SizedBox(height: 2),
          SizedBox(
            width: double.infinity,
            child: Text(
              item.brand.trim().isEmpty ? '未设置品牌' : item.brand,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF8A8A8A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ClosetEmptyState extends StatelessWidget {
  const _ClosetEmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 44),
      child: const Column(
        children: [
          Icon(Icons.inventory_2_outlined, size: 42, color: Color(0xFFB0B0B0)),
          SizedBox(height: 12),
          Text(
            '还没有单品',
            style: TextStyle(
              color: Color(0xFF2C2C2C),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 4),
          Text(
            '去添加第一件 →',
            style: TextStyle(
              color: Color(0xFF8C8C8C),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
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
                          childAspectRatio: 0.68,
                        ),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return InkWell(
                        borderRadius: BorderRadius.circular(18),
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEDEDED),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: AppImage(
                                  path: item.imagePath,
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                  radius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: Text(
                                item.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
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
