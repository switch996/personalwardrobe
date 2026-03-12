import 'dart:io';

import 'package:flutter/material.dart';

import '../design/ds.dart';
import '../store/local_store.dart';
import '../utils/dialog.dart';

class MePage extends StatelessWidget {
  const MePage({super.key, required this.store, required this.refresh});

  final LocalStore store;
  final ValueNotifier<int> refresh;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: refresh,
      builder: (context, value, child) {
        final closetCount = store.closet.length;
        final outfitDays = _outfitDaysCount(store);
        final mostWorn = _mostWornItemName(store);
        final usedStorageLabel =
            '${_storageUsageMb(store).toStringAsFixed(0)}MB / 2GB';

        return Scaffold(
          backgroundColor: DsColors.paper,
          body: SafeArea(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [DsColors.paper, Color(0xFFFCF9F2)],
                ),
              ),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                children: [
                  const _ProfileHeader(),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(value: '$closetCount', label: '衣物总数'),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _StatCard(value: '$outfitDays', label: '穿搭天数'),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _StatCard(value: mostWorn, label: '最常穿搭'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: Text(
                      '应用管理',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF90A0B6),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _SettingTile(
                    icon: Icons.cloud_upload_outlined,
                    iconBg: const Color(0xFFE8F0FF),
                    iconColor: const Color(0xFF3E7CE8),
                    title: '数据备份与导出',
                    onTap: () => showSnack(context, '数据备份与导出功能即将上线'),
                  ),
                  const SizedBox(height: 10),
                  _SettingTile(
                    icon: Icons.notifications_none_rounded,
                    iconBg: const Color(0xFFF7EFE3),
                    iconColor: const Color(0xFFFF8A00),
                    title: '通知设置',
                    onTap: () => showSnack(context, '通知设置功能即将上线'),
                  ),
                  const SizedBox(height: 10),
                  _SettingTile(
                    icon: Icons.storage_rounded,
                    iconBg: const Color(0xFFF2EBFF),
                    iconColor: const Color(0xFF9A56F0),
                    title: '存储空间管理',
                    trailing: usedStorageLabel,
                    onTap: () => showSnack(context, '存储管理功能即将上线'),
                  ),
                  const SizedBox(height: 10),
                  _SettingTile(
                    icon: Icons.info_outline_rounded,
                    iconBg: const Color(0xFFE7F6ED),
                    iconColor: const Color(0xFF2BBF5F),
                    title: '关于应用',
                    trailing: 'v2.4.0',
                    onTap: () => showSnack(context, '衣橱日记 本地版'),
                  ),
                  const SizedBox(height: 10),
                  _SettingTile(
                    icon: Icons.logout_rounded,
                    iconBg: const Color(0xFFFFECEC),
                    iconColor: const Color(0xFFE25A5A),
                    title: '退出登录',
                    titleColor: const Color(0xFFE25A5A),
                    onTap: () async {
                      final ok = await confirmDialog(
                        context,
                        title: '退出登录',
                        message: '确定退出当前账号吗？',
                      );
                      if (!ok || !context.mounted) return;
                      showSnack(context, '已退出登录');
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    '您的数据仅保存在本地设备中',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9AADC5),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static int _outfitDaysCount(LocalStore store) {
    final days = <DateTime>{};
    for (final outfit in store.outfits) {
      days.add(DateTime(outfit.date.year, outfit.date.month, outfit.date.day));
    }
    return days.length;
  }

  static String _mostWornItemName(LocalStore store) {
    final counts = <String, int>{};
    for (final outfit in store.outfits) {
      for (final id in outfit.closetItemIds) {
        counts[id] = (counts[id] ?? 0) + 1;
      }
    }
    if (counts.isEmpty) return '暂无';
    String? mostId;
    var maxCount = 0;
    counts.forEach((id, count) {
      if (count > maxCount) {
        maxCount = count;
        mostId = id;
      }
    });
    final item = store.closet.where((e) => e.id == mostId).firstOrNull;
    if (item == null || item.name.trim().isEmpty) return '暂无';
    return item.name;
  }

  static double _storageUsageMb(LocalStore store) {
    final paths = <String>{};
    for (final item in store.closet) {
      if (item.imagePath.isNotEmpty) paths.add(item.imagePath);
    }
    for (final entry in store.outfits) {
      if (entry.imagePath.isNotEmpty) paths.add(entry.imagePath);
    }

    var bytes = 0;
    for (final path in paths) {
      final file = File(path);
      if (!file.existsSync()) continue;
      bytes += file.lengthSync();
    }
    return bytes / (1024 * 1024);
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 112,
          height: 112,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 112,
                height: 112,
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Color(0xFFF0EFF0),
                  shape: BoxShape.circle,
                ),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFEDE8DD),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.local_florist_outlined,
                    size: 40,
                    color: DsColors.copper,
                  ),
                ),
              ),
              Positioned(
                right: -2,
                bottom: 6,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF9300),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: const Icon(Icons.edit, color: Colors.white, size: 16),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          '林小悦',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0E1731),
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          '本地智能衣橱管家',
          style: TextStyle(
            fontSize: 15,
            color: Color(0xFF7E92AA),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 96,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 18,
              color: Color(0xFFFF8A00),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF7A8BA4),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  const _SettingTile({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.onTap,
    this.trailing,
    this.titleColor = const Color(0xFF101731),
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String? trailing;
  final Color titleColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 84,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: titleColor,
                  ),
                ),
              ),
              if (trailing != null) ...[
                Text(
                  trailing!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF8EA0B6),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              const Icon(
                Icons.chevron_right_rounded,
                size: 26,
                color: Color(0xFFD2DBE8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
