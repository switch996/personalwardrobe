import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../design/ds.dart';
import '../design/widgets.dart';
import '../pages/virtual_closet_page.dart';
import '../store/local_store.dart';

class TodayPage extends StatelessWidget {
  const TodayPage({
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
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: refresh,
      builder: (context, value, child) {
        final now = DateTime.now();
        final todays = store.outfitsOn(now);
        final heroImage = todays.isNotEmpty
            ? todays.first.imagePath
            : (store.outfits.isNotEmpty ? store.outfits.first.imagePath : '');
        final heroHeight =
            (MediaQuery.of(context).size.width - DsSpace.md * 2) * 0.95;

        return Scaffold(
          backgroundColor: DsColors.paper,
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(DsSpace.md),
              children: [
                _HeaderRow(date: now),
                const SizedBox(height: DsSpace.md),
                _HeroCard(
                  imagePath: heroImage,
                  height: heroHeight.clamp(280, 460).toDouble(),
                  onCameraTap: () => _pickImageAndSave(context, now),
                ),
                const SizedBox(height: DsSpace.md),
                _VirtualClosetDoorCard(
                  store: store,
                  refresh: refresh,
                  onRefresh: onRefresh,
                  onNavigateTab: onNavigateTab,
                ),
                const SizedBox(height: DsSpace.md),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickImageAndSave(BuildContext context, DateTime date) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('拍照'),
                onTap: () => Navigator.of(context).pop('camera'),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('从相册选择'),
                onTap: () => Navigator.of(context).pop('gallery'),
              ),
            ],
          ),
        );
      },
    );
    if (action == null || !context.mounted) return;

    final source = action == 'camera'
        ? ImageSource.camera
        : ImageSource.gallery;
    final picker = ImagePicker();
    final file = await picker.pickImage(source: source, imageQuality: 85);
    if (file == null) return;

    await store.upsertOutfit(
      imageSourcePath: file.path,
      date: date,
      note: '',
      tags: const <String>[],
      closetItemIds: const <String>[],
    );
    onRefresh();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已保存今日穿搭')),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${date.year}年${date.month}月${date.day}日',
                style: const TextStyle(
                  color: DsColors.ink,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              const Row(
                children: [
                  Icon(
                    Icons.wb_sunny_rounded,
                    color: Color(0xFFD32F2F),
                    size: 24,
                  ),
                  SizedBox(width: 4),
                  Text(
                    '晴 24°C',
                    style: TextStyle(
                      color: Color(0xFFD32F2F),
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFDDDDDD)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('通知中心即将开放')),
              );
            },
            icon: const Icon(Icons.notifications, color: Color(0xFF4D4D4D)),
          ),
        ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.imagePath,
    required this.height,
    required this.onCameraTap,
  });

  final String imagePath;
  final double height;
  final VoidCallback onCameraTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: DsRadius.lg,
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF171717), Color(0xFF0F0F0F)],
                  ),
                ),
                child: AppImage(
                  path: imagePath,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.scaleDown,
                ),
              ),
            ),
          ),
          Positioned(
            right: 12,
            bottom: 14,
            child: InkWell(
              onTap: onCameraTap,
              borderRadius: BorderRadius.circular(32),
              child: Container(
                width: 58,
                height: 58,
                decoration: const BoxDecoration(
                  color: Color(0xFFD32F2F),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x30D32F2F),
                      blurRadius: 18,
                      offset: Offset(0, 9),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.camera_alt_outlined,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VirtualClosetDoorCard extends StatefulWidget {
  const _VirtualClosetDoorCard({
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
  State<_VirtualClosetDoorCard> createState() => _VirtualClosetDoorCardState();
}

class _VirtualClosetDoorCardState extends State<_VirtualClosetDoorCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _opening = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 40),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    if (_opening) return;
    _opening = true;

    await _controller.forward();
    if (!mounted) return;

    final targetTab = await Navigator.of(context).push<int>(
      MaterialPageRoute(
        builder: (_) => VirtualClosetPage(
          store: widget.store,
          refresh: widget.refresh,
          onRefresh: widget.onRefresh,
          onNavigateTab: widget.onNavigateTab,
        ),
      ),
    );

    if (!mounted) return;
    if (targetTab != null) {
      widget.onNavigateTab?.call(targetTab);
    }
    _controller.value = 0;
    _opening = false;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _handleTap,
      borderRadius: DsRadius.lg,
      child: Container(
        height: 260,
        decoration: BoxDecoration(
          borderRadius: DsRadius.lg,
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF151515), Color(0xFF0D0D0D)],
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 24,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: DsRadius.lg,
                  border: Border.all(color: const Color(0x33FFFFFF)),
                ),
              ),
            ),
            const Positioned(
              left: 20,
              right: 20,
              top: 18,
              child: Text(
                'ENTER VIRTUAL CLOSET',
                textAlign: TextAlign.center,
                style: TextStyle(
                  letterSpacing: 1.2,
                  color: Color(0xFFEEEEEE),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Positioned(
              left: 20,
              right: 20,
              bottom: 18,
              child: Text(
                '点击推开门进入',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFD32F2F),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 46, 22, 46),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: DecoratedBox(
                    decoration: const BoxDecoration(color: Color(0xFF101010)),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final panelWidth = constraints.maxWidth / 2;
                        return AnimatedBuilder(
                          animation: _controller,
                          builder: (context, child) {
                            final t = Curves.easeOutCubic.transform(
                              _controller.value,
                            );
                            return Stack(
                              children: [
                                Positioned.fill(
                                  child: Container(
                                    color: const Color(0xFF050505),
                                    alignment: Alignment.center,
                                    child: const Icon(
                                      Icons.checkroom_rounded,
                                      color: Color(0xFFD32F2F),
                                      size: 64,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: -panelWidth * 0.55 * t,
                                  top: 0,
                                  bottom: 0,
                                  width: panelWidth,
                                  child: Transform(
                                    alignment: Alignment.centerRight,
                                    transform: Matrix4.identity()
                                      ..setEntry(3, 2, 0.0012)
                                      ..rotateY(-0.8 * t),
                                    child: const _DoorPanel(left: true),
                                  ),
                                ),
                                Positioned(
                                  right: -panelWidth * 0.55 * t,
                                  top: 0,
                                  bottom: 0,
                                  width: panelWidth,
                                  child: Transform(
                                    alignment: Alignment.centerLeft,
                                    transform: Matrix4.identity()
                                      ..setEntry(3, 2, 0.0012)
                                      ..rotateY(0.8 * t),
                                    child: const _DoorPanel(left: false),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DoorPanel extends StatelessWidget {
  const _DoorPanel({required this.left});

  final bool left;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: left ? Alignment.centerLeft : Alignment.centerRight,
          end: left ? Alignment.centerRight : Alignment.centerLeft,
          colors: const [Color(0xFF2B2B2B), Color(0xFF171717)],
        ),
        border: Border.all(color: const Color(0xFF3C3C3C)),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 8,
            right: 8,
            top: 10,
            bottom: 10,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF474747)),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          Align(
            alignment: left ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: 8,
              height: 44,
              margin: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFD32F2F),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
