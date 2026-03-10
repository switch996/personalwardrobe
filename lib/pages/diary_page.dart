import 'package:flutter/material.dart';

import '../design/ds.dart';
import '../design/widgets.dart';
import '../models/outfit_entry.dart';
import '../pages/outfit_detail_page.dart';
import '../store/local_store.dart';
import '../utils/date.dart';

class DiaryPage extends StatefulWidget {
  const DiaryPage({
    super.key,
    required this.store,
    required this.refresh,
    required this.onRefresh,
  });

  final LocalStore store;
  final ValueNotifier<int> refresh;
  final VoidCallback onRefresh;

  @override
  State<DiaryPage> createState() => _DiaryPageState();
}

class _DiaryPageState extends State<DiaryPage> {
  bool _calendarMode = true;
  DateTime _month = monthStart(DateTime.now());
  DateTime _selectedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: widget.refresh,
      builder: (context, value, child) {
        final dayEntries = widget.store.outfitsOn(_selectedDay);

        return AppScaffold(
          title: '日历',
          body: ListView(
            padding: const EdgeInsets.all(DsSpace.md),
            children: [
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment<bool>(value: true, label: Text('月历视图')),
                  ButtonSegment<bool>(value: false, label: Text('时间线')),
                ],
                selected: <bool>{_calendarMode},
                onSelectionChanged: (values) {
                  setState(() {
                    _calendarMode = values.first;
                  });
                },
              ),
              const SizedBox(height: DsSpace.md),
              if (_calendarMode) ...[
                _CalendarView(
                  month: _month,
                  selectedDay: _selectedDay,
                  entries: widget.store.outfits,
                  onPrevMonth: () {
                    setState(() {
                      _month = addMonth(_month, -1);
                    });
                  },
                  onNextMonth: () {
                    setState(() {
                      _month = addMonth(_month, 1);
                    });
                  },
                  onSelectDay: (date) {
                    setState(() {
                      _selectedDay = date;
                    });
                  },
                ),
                const SizedBox(height: DsSpace.md),
                SectionTitle('选中日期：${ymd(_selectedDay)}'),
                const SizedBox(height: DsSpace.sm),
                if (dayEntries.isEmpty)
                  const EmptyState(title: '这一天还没有记录', caption: '回到“今日”页即可马上记录')
                else
                  ...dayEntries.map(
                    (e) => _TimelineCard(
                      entry: e,
                      store: widget.store,
                      onRefresh: widget.onRefresh,
                      refresh: widget.refresh,
                    ),
                  ),
              ] else ...[
                if (widget.store.outfits.isEmpty)
                  const EmptyState(title: '暂无时间线', caption: '先去记录第一条穿搭吧')
                else
                  ...widget.store.outfits.map(
                    (e) => _TimelineCard(
                      entry: e,
                      store: widget.store,
                      onRefresh: widget.onRefresh,
                      refresh: widget.refresh,
                    ),
                  ),
              ],
            ],
          ),
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
    required this.onNextMonth,
    required this.onSelectDay,
  });

  final DateTime month;
  final DateTime selectedDay;
  final List<OutfitEntry> entries;
  final VoidCallback onPrevMonth;
  final VoidCallback onNextMonth;
  final ValueChanged<DateTime> onSelectDay;

  @override
  Widget build(BuildContext context) {
    final first = monthStart(month);
    final total = monthDays(month);
    final weekOffset = (first.weekday + 6) % 7;
    final cells = <Widget>[];

    cells.addAll(weekdayHeaders(Theme.of(context).textTheme.bodySmall));

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
          borderRadius: DsRadius.md,
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? const Color(0x1AAD7E45) : Colors.transparent,
              borderRadius: DsRadius.md,
            ),
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('$day'),
                const SizedBox(height: 2),
                if (hasRecord)
                  Container(
                    width: 5,
                    height: 5,
                    decoration: const BoxDecoration(
                      color: DsColors.copper,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return PaperCard(
      child: Column(
        children: [
          Row(
            children: [
              IconButton(onPressed: onPrevMonth, icon: const Icon(Icons.chevron_left)),
              Expanded(
                child: Center(
                  child: Text(monthLabel(month), style: Theme.of(context).textTheme.titleMedium),
                ),
              ),
              IconButton(onPressed: onNextMonth, icon: const Icon(Icons.chevron_right)),
            ],
          ),
          const SizedBox(height: DsSpace.xs),
          GridView.count(
            crossAxisCount: 7,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            childAspectRatio: 0.85,
            children: cells,
          ),
        ],
      ),
    );
  }
}

class _TimelineCard extends StatelessWidget {
  const _TimelineCard({
    required this.entry,
    required this.store,
    required this.onRefresh,
    required this.refresh,
  });

  final OutfitEntry entry;
  final LocalStore store;
  final VoidCallback onRefresh;
  final ValueNotifier<int> refresh;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: DsSpace.sm),
      child: InkWell(
        borderRadius: DsRadius.md,
        onTap: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => OutfitDetailPage(
                entryId: entry.id,
                store: store,
                refresh: refresh,
                onRefresh: onRefresh,
              ),
            ),
          );
        },
        child: PaperCard(
          child: Row(
            children: [
              AppImage(path: entry.imagePath, width: 92, height: 92),
              const SizedBox(width: DsSpace.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ymd(entry.date), style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 4),
                    Text(
                      entry.note.isEmpty ? '（暂无备注）' : entry.note,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: entry.tags.map((e) => Chip(label: Text(e))).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
