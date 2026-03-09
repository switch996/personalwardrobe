import 'package:flutter/material.dart';

String ymd(DateTime date) {
  final y = date.year.toString().padLeft(4, '0');
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

String md(DateTime date) {
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '$m/$d';
}

bool isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

DateTime monthStart(DateTime value) => DateTime(value.year, value.month);

DateTime monthEnd(DateTime value) => DateTime(value.year, value.month + 1, 0);

int monthDays(DateTime value) => monthEnd(value).day;

DateTime addMonth(DateTime value, int delta) => DateTime(value.year, value.month + delta, 1);

String monthLabel(DateTime date) {
  return '${date.year}-${date.month.toString().padLeft(2, '0')}';
}

List<Widget> weekdayHeaders(TextStyle? style) {
  const labels = <String>['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return labels.map((e) => Center(child: Text(e, style: style))).toList();
}
