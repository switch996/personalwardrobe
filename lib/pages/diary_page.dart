import 'package:flutter/material.dart';

import '../design/app_bottom_nav.dart';
import '../design/ds.dart';
import '../design/widgets.dart';
import '../models/outfit_entry.dart';
import '../pages/diary_outfit_detail_page.dart';
import '../pages/closet_page.dart';
import '../pages/me_page.dart';
import '../sheets/closet_item_editor_sheet.dart';
import '../store/local_store.dart';
import '../utils/date.dart';

class DiaryPage extends StatefulWidget {
  const DiaryPage({
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
  State<DiaryPage> createState() => _DiaryPageState();
}

class _DiaryPageState extends State<DiaryPage> {
  DateTime _month = monthStart(DateTime.now());
  DateTime _selectedDay = DateTime.now();
  int _bottomNavIndex = 1;

  OutfitEntry? _entryForSelectedDay() {
    final dayEntries = widget.store.outfitsOn(_selectedDay);
    if (dayEntries.isEmpty) return null;
    dayEntries.sort((a, b) {
      final dateCompare = b.date.compareTo(a.date);
      if (dateCompare != 0) return dateCompare;
      return b.id.compareTo(a.id);
    });
    return dayEntries.first;
  }

  void _shiftMonth(int delta) {
    final nextMonth = addMonth(_month, delta);
    final nextDay = _selectedDay.day.clamp(1, monthDays(nextMonth)).toInt();
    setState(() {
      _month = nextMonth;
      _selectedDay = DateTime(nextMonth.year, nextMonth.month, nextDay);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: widget.refresh,
      builder: (context, value, child) {
        final entry = _entryForSelectedDay();

        return Scaffold(
          backgroundColor: DsColors.paper,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Column(
                children: [
                  _CalendarView(
                    month: _month,
                    selectedDay: _selectedDay,
                    entries: widget.store.outfits,
                    onPrevMonth: () => _shiftMonth(-1),
                    onSelectDay: (date) {
                      setState(() {
                        _selectedDay = date;
                        _month = monthStart(date);
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  _SectionTitle(title: '当日穿搭'),
                  const SizedBox(height: 8),
                  Expanded(
                    child: _DailyOutfitCard(
                      entry: entry,
                      onTapDetail: entry == null
                          ? null
                          : () async {
                              await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => DiaryOutfitDetailPage(
                                    entryId: entry.id,
                                    store: widget.store,
                                    refresh: widget.refresh,
                                    onRefresh: widget.onRefresh,
                                  ),
                                ),
                              );
                            },
                    ),
                  ),
                ],
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
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ClosetPage(
                              store: widget.store,
                              refresh: widget.refresh,
                              onRefresh: widget.onRefresh,
                              showBottomNav: true,
                            ),
                          ),
                        );
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
        );
      },
    );
  }
}

class _CalendarView extends StatelessWidget {
  const _CalendarView({
    required this.month,
    required this.selectedDay,
    required this.entries,
    required this.onPrevMonth,
    required this.onSelectDay,
  });

  final DateTime month;
  final DateTime selectedDay;
  final List<OutfitEntry> entries;
  final VoidCallback onPrevMonth;
  final ValueChanged<DateTime> onSelectDay;

  @override
  Widget build(BuildContext context) {
    final first = monthStart(month);
    final total = monthDays(month);
    final weekOffset = (first.weekday + 6) % 7;
    final cells = <Widget>[];

    const weekdayLabels = <String>['日', '一', '二', '三', '四', '五', '六'];
    cells.addAll(
      weekdayLabels.map(
        (label) => Center(
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF9AA1AC),
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );

    for (var i = 0; i < weekOffset; i++) {
      cells.add(const SizedBox.shrink());
    }

    for (var day = 1; day <= total; day++) {
      final current = DateTime(month.year, month.month, day);
      final hasRecord = entries.any((e) => isSameDay(e.date, current));
      final isSelected = isSameDay(current, selectedDay);
      cells.add(
        InkWell(
          onTap: () => onSelectDay(current),
          borderRadius: BorderRadius.circular(20),
          child: SizedBox(
            height: 34,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (isSelected)
                  Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF07212),
                      shape: BoxShape.circle,
                    ),
                  ),
                Text(
                  '$day',
                  style: TextStyle(
                    color: isSelected ? Colors.white : DsColors.ink,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (hasRecord)
                  Positioned(
                    bottom: 3,
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFFFD6AF)
                            : const Color(0xFFF07212),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: onPrevMonth,
                visualDensity: VisualDensity.compact,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                iconSize: 18,
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Color(0xFFF07212),
                ),
              ),
              Expanded(
                child: Center(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () async {
                      final picked = await showModalBottomSheet<DateTime>(
                        context: context,
                        backgroundColor: Colors.white,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(24),
                          ),
                        ),
                        builder: (context) {
                          var year = month.year;
                          final currentMonth = month.month;
                          return StatefulBuilder(
                            builder: (context, setSheetState) {
                              return Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  16,
                                  16,
                                  20,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      children: [
                                        IconButton(
                                          onPressed: () =>
                                              setSheetState(() => year -= 1),
                                          icon: const Icon(
                                            Icons.chevron_left,
                                            color: Color(0xFFF07212),
                                          ),
                                        ),
                                        Expanded(
                                          child: Center(
                                            child: Text(
                                              '$year年',
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w800,
                                                color: Color(0xFFF07212),
                                              ),
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () =>
                                              setSheetState(() => year += 1),
                                          icon: const Icon(
                                            Icons.chevron_right,
                                            color: Color(0xFFF07212),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    GridView.count(
                                      crossAxisCount: 4,
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      childAspectRatio: 2.1,
                                      mainAxisSpacing: 8,
                                      crossAxisSpacing: 8,
                                      children: List.generate(12, (index) {
                                        final monthValue = index + 1;
                                        final selected =
                                            year == month.year &&
                                            monthValue == currentMonth;
                                        return InkWell(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                          onTap: () {
                                            Navigator.of(context).pop(
                                              DateTime(year, monthValue, 1),
                                            );
                                          },
                                          child: Container(
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              color: selected
                                                  ? const Color(0xFFF07212)
                                                  : const Color(0xFFF7F1E8),
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                            ),
                                            child: Text(
                                              '$monthValue月',
                                              style: TextStyle(
                                                color: selected
                                                    ? Colors.white
                                                    : DsColors.ink,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      );
                      if (picked == null) return;
                      onSelectDay(DateTime(picked.year, picked.month, 1));
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: Text(
                        monthLabel(month),
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFF07212),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 36),
            ],
          ),
          const SizedBox(height: 2),
          GridView.count(
            crossAxisCount: 7,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            childAspectRatio: 1.35,
            children: cells,
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: const Color(0xFFF07212),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: DsColors.ink,
          ),
        ),
      ],
    );
  }
}

class _DailyOutfitCard extends StatelessWidget {
  const _DailyOutfitCard({required this.entry, required this.onTapDetail});

  final OutfitEntry? entry;
  final VoidCallback? onTapDetail;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF8F4EE),
                borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
              ),
              child: AppImage(
                path: entry?.imagePath ?? '',
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.contain,
                radius: const BorderRadius.vertical(top: Radius.circular(26)),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(26)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        '北京',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: DsColors.ink,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '24℃ 晴天',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFF07212),
                        ),
                      ),
                    ],
                  ),
                ),
                FilledButton.icon(
                  onPressed: onTapDetail,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFF07B1B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  icon: const Icon(Icons.auto_awesome, size: 18),
                  label: const Text('查询穿搭详情'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
