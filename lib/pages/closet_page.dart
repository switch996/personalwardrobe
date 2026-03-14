import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../design/app_bottom_nav.dart';
import '../design/ds.dart';
import '../design/widgets.dart';
import '../models/closet_item.dart';
import '../sheets/closet_item_editor_sheet.dart';
import '../store/local_store.dart';
import 'closet_item_detail_page.dart';
import 'diary_page.dart';
import 'me_page.dart';
import 'virtual_closet_page.dart';

class ClosetPage extends StatefulWidget {
  const ClosetPage({
    super.key,
    required this.store,
    required this.refresh,
    required this.onRefresh,
    this.showBottomNav = false,
  });

  final LocalStore store;
  final ValueNotifier<int> refresh;
  final VoidCallback onRefresh;
  final bool showBottomNav;

  @override
  State<ClosetPage> createState() => _ClosetPageState();
}

class _ClosetPageState extends State<ClosetPage> {
  _ClosetViewMode _viewMode = _ClosetViewMode.closet;
  _OverviewMetric _metric = _OverviewMetric.count;
  int _bottomNavIndex = 3;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: widget.refresh,
      builder: (context, value, child) {
        final groups = _buildCategoryGroups(widget.store.closet);
        return Scaffold(
          appBar: AppBar(
            titleSpacing: DsSpace.md,
            automaticallyImplyLeading: false,
            title: SizedBox(
              width: 180,
              child: _ClosetHeaderSwitch(
                mode: _viewMode,
                onChanged: (mode) {
                  setState(() {
                    _viewMode = mode;
                  });
                },
              ),
            ),
          ),
          bottomNavigationBar: widget.showBottomNav
              ? AppBottomNav(
                  selectedIndex: _bottomNavIndex,
                  firstTab: AppBottomNavFirstTab.home,
                  onDestinationSelected: (value) async {
                    switch (value) {
                      case 0:
                        setState(() {
                          _bottomNavIndex = value;
                        });
                        Navigator.of(context).pop();
                        break;
                      case 1:
                        setState(() {
                          _bottomNavIndex = value;
                        });
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => DiaryPage(
                              store: widget.store,
                              refresh: widget.refresh,
                              onRefresh: widget.onRefresh,
                              showBottomNav: true,
                            ),
                          ),
                        );
                        break;
                      case 2:
                        final changed = await showClosetItemEditorSheet(
                          context,
                          store: widget.store,
                        );
                        if (changed == true) widget.onRefresh();
                        break;
                      case 3:
                        setState(() {
                          _bottomNavIndex = value;
                        });
                        break;
                      case 4:
                        setState(() {
                          _bottomNavIndex = value;
                        });
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => MePage(
                              store: widget.store,
                              refresh: widget.refresh,
                              onRefresh: widget.onRefresh,
                              showBottomNav: true,
                            ),
                          ),
                        );
                        break;
                    }
                  },
                )
              : null,
          body: SafeArea(
            top: false,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [DsColors.paper, Color(0xFFFCF9F2)],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(DsSpace.md),
                child: ListView(
                  children: [
                    if (widget.store.closet.isEmpty)
                      const EmptyState(
                        title: '衣橱还空着',
                        caption: '请使用底部加号添加第一件单品',
                      )
                    else if (_viewMode == _ClosetViewMode.chart)
                      _OverviewCard(
                        groups: groups,
                        metric: _metric,
                        onMetricChanged: (metric) {
                          setState(() {
                            _metric = metric;
                          });
                        },
                      )
                    else
                      ...groups.map(
                        (group) => Padding(
                          padding: const EdgeInsets.only(bottom: DsSpace.sm),
                          child: _CategoryRowCard(
                            label: group.label,
                            items: group.items,
                            onOpenList: () async {
                              await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => CategoryListPage(
                                    store: widget.store,
                                    refresh: widget.refresh,
                                    onRefresh: widget.onRefresh,
                                    title: '${group.label}列表',
                                    category: group.key,
                                  ),
                                ),
                              );
                            },
                            onTapItem: (item) async {
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
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

enum _ClosetViewMode { closet, chart }

enum _OverviewMetric { count, value }

class _CategoryGroup {
  const _CategoryGroup({
    required this.key,
    required this.label,
    required this.items,
  });

  final String key;
  final String label;
  final List<ClosetItem> items;
}

List<_CategoryGroup> _buildCategoryGroups(List<ClosetItem> allItems) {
  final baseOrder = LocalStore.closetCategories;
  final grouped = <String, List<ClosetItem>>{};
  for (final item in allItems) {
    grouped.putIfAbsent(item.category, () => <ClosetItem>[]).add(item);
  }

  final groups = <_CategoryGroup>[];
  for (final key in baseOrder) {
    groups.add(
      _CategoryGroup(
        key: key,
        label: LocalStore.categoryLabel(key),
        items: grouped[key] ?? const <ClosetItem>[],
      ),
    );
  }

  final extraKeys =
      grouped.keys.where((key) => !baseOrder.contains(key)).toList()..sort();
  for (final key in extraKeys) {
    groups.add(
      _CategoryGroup(
        key: key,
        label: LocalStore.categoryLabel(key),
        items: grouped[key] ?? const <ClosetItem>[],
      ),
    );
  }
  return groups;
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({
    required this.groups,
    required this.metric,
    required this.onMetricChanged,
  });

  final List<_CategoryGroup> groups;
  final _OverviewMetric metric;
  final ValueChanged<_OverviewMetric> onMetricChanged;

  @override
  Widget build(BuildContext context) {
    final slices = _buildSlices(groups, metric);
    final total = slices.fold<double>(0, (sum, e) => sum + e.value);
    final centerText = metric == _OverviewMetric.count
        ? total.toStringAsFixed(0)
        : '¥${total.toStringAsFixed(0)}';
    final subtitle = metric == _OverviewMetric.count ? '总件数' : '总价值';

    return PaperCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  '衣服总览图表',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
              ),
              SegmentedButton<_OverviewMetric>(
                segments: const [
                  ButtonSegment<_OverviewMetric>(
                    value: _OverviewMetric.count,
                    label: Text('数量'),
                  ),
                  ButtonSegment<_OverviewMetric>(
                    value: _OverviewMetric.value,
                    label: Text('价值'),
                  ),
                ],
                selected: <_OverviewMetric>{metric},
                onSelectionChanged: (selected) =>
                    onMetricChanged(selected.first),
              ),
            ],
          ),
          const SizedBox(height: DsSpace.sm),
          if (total <= 0)
            Container(
              height: 160,
              decoration: BoxDecoration(
                color: const Color(0xFFF6F1E9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: DsColors.line),
              ),
              alignment: Alignment.center,
              child: Text(
                metric == _OverviewMetric.count
                    ? '暂无可统计单品'
                    : '暂无可统计价格，请先填写单品价格',
                style: const TextStyle(color: DsColors.mutedInk),
              ),
            )
          else ...[
            Center(
              child: _DonutChart(
                slices: slices,
                centerValue: centerText,
                centerLabel: subtitle,
              ),
            ),
            const SizedBox(height: DsSpace.sm),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: slices.map((slice) {
                final ratio = total <= 0 ? 0.0 : slice.value / total * 100;
                final amount = metric == _OverviewMetric.count
                    ? '${slice.value.toStringAsFixed(0)}件'
                    : '¥${slice.value.toStringAsFixed(0)}';
                return _LegendChip(
                  color: slice.color,
                  label:
                      '${slice.label}  $amount  ${ratio.toStringAsFixed(1)}%',
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  List<_ChartSlice> _buildSlices(
    List<_CategoryGroup> groups,
    _OverviewMetric metric,
  ) {
    const palette = <Color>[
      Color(0xFF5B6EF5),
      Color(0xFF3F8CFF),
      Color(0xFF4AC2E0),
      Color(0xFF41B35D),
      Color(0xFFC2D93C),
      Color(0xFFF5A623),
      Color(0xFFFF7B54),
      Color(0xFFB37FEB),
    ];
    final nonEmptyGroups = groups.where((g) => g.items.isNotEmpty).toList();
    return List.generate(nonEmptyGroups.length, (index) {
      final group = nonEmptyGroups[index];
      final value = metric == _OverviewMetric.count
          ? group.items.length.toDouble()
          : group.items.fold<double>(
              0,
              (sum, item) => sum + (item.price > 0 ? item.price : 0),
            );
      return _ChartSlice(
        label: group.label,
        value: value,
        color: palette[index % palette.length],
      );
    }).where((slice) => slice.value > 0).toList();
  }
}

class _ClosetHeaderSwitch extends StatelessWidget {
  const _ClosetHeaderSwitch({required this.mode, required this.onChanged});

  final _ClosetViewMode mode;
  final ValueChanged<_ClosetViewMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F0E4),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: DsColors.line),
      ),
      child: Row(
        children: [
          _SwitchCell(
            label: '衣橱',
            selected: mode == _ClosetViewMode.closet,
            onTap: () => onChanged(_ClosetViewMode.closet),
          ),
          Container(width: 1, color: DsColors.line),
          _SwitchCell(
            label: '图表',
            selected: mode == _ClosetViewMode.chart,
            onTap: () => onChanged(_ClosetViewMode.chart),
          ),
        ],
      ),
    );
  }
}

class _SwitchCell extends StatelessWidget {
  const _SwitchCell({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
            boxShadow: selected
                ? const [
                    BoxShadow(
                      color: Color(0x12000000),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: selected ? DsColors.ink : DsColors.mutedInk,
            ),
          ),
        ),
      ),
    );
  }
}

class _ChartSlice {
  const _ChartSlice({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final double value;
  final Color color;
}

class _DonutChart extends StatelessWidget {
  const _DonutChart({
    required this.slices,
    required this.centerValue,
    required this.centerLabel,
  });

  final List<_ChartSlice> slices;
  final String centerValue;
  final String centerLabel;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size.square(220),
            painter: _DonutPainter(slices),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                centerValue,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: DsColors.ink,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                centerLabel,
                style: const TextStyle(
                  fontSize: 12,
                  color: DsColors.mutedInk,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter(this.slices);

  final List<_ChartSlice> slices;

  @override
  void paint(Canvas canvas, Size size) {
    final total = slices.fold<double>(0, (sum, e) => sum + e.value);
    if (total <= 0) return;

    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 14;
    const stroke = 28.0;
    const gap = 0.03;

    final background = Paint()
      ..color = const Color(0xFFEDE7DC)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    canvas.drawCircle(center, radius, background);

    var start = -math.pi / 2;
    for (final slice in slices) {
      final sweep = slice.value / total * math.pi * 2;
      final drawSweep = math.max(0.0, sweep - gap);
      final paint = Paint()
        ..color = slice.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start + gap / 2,
        drawSweep,
        false,
        paint,
      );
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) {
    return oldDelegate.slices != slices;
  }
}

class _LegendChip extends StatelessWidget {
  const _LegendChip({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F1E9),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: DsColors.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: DsColors.ink),
          ),
        ],
      ),
    );
  }
}

class _CategoryRowCard extends StatelessWidget {
  const _CategoryRowCard({
    required this.label,
    required this.items,
    required this.onOpenList,
    required this.onTapItem,
  });

  final String label;
  final List<ClosetItem> items;
  final VoidCallback onOpenList;
  final ValueChanged<ClosetItem> onTapItem;

  @override
  Widget build(BuildContext context) {
    return PaperCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '$label · ${items.length}件',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: DsColors.ink,
                  ),
                ),
              ),
              Material(
                color: const Color(0xFFF7F0E4),
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  onTap: onOpenList,
                  borderRadius: BorderRadius.circular(10),
                  child: const SizedBox(
                    width: 34,
                    height: 34,
                    child: Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: DsColors.ink,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (items.isEmpty)
            Container(
              height: 74,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFF8F4ED),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text(
                '该分类暂无单品',
                style: TextStyle(color: DsColors.mutedInk),
              ),
            )
          else
            SizedBox(
              height: 136,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: items.length,
                separatorBuilder: (context, _) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return _CategoryPreviewTile(
                    item: item,
                    onTap: () => onTapItem(item),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _CategoryPreviewTile extends StatelessWidget {
  const _CategoryPreviewTile({required this.item, required this.onTap});

  final ClosetItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        width: 112,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: const Color(0xFFF3F3F3),
          ),
          child: AppImage(
            path: item.imagePath,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.contain,
            radius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
