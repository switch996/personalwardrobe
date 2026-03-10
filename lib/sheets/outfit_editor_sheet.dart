import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../design/ds.dart';
import '../design/widgets.dart';
import '../models/outfit_entry.dart';
import '../store/local_store.dart';
import '../utils/date.dart';
import '../utils/dialog.dart';

Future<bool?> showOutfitEditorSheet(
  BuildContext context, {
  required LocalStore store,
  OutfitEntry? editing,
  DateTime? initialDate,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) {
      return _OutfitEditorSheet(store: store, editing: editing, initialDate: initialDate);
    },
  );
}

class _OutfitEditorSheet extends StatefulWidget {
  const _OutfitEditorSheet({
    required this.store,
    required this.editing,
    required this.initialDate,
  });

  final LocalStore store;
  final OutfitEntry? editing;
  final DateTime? initialDate;

  @override
  State<_OutfitEditorSheet> createState() => _OutfitEditorSheetState();
}

class _OutfitEditorSheetState extends State<_OutfitEditorSheet> {
  late final TextEditingController _note;
  late DateTime _date;
  late Set<String> _tags;
  late Set<String> _selectedItems;
  String _pickedImagePath = '';
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final editing = widget.editing;
    _note = TextEditingController(text: editing?.note ?? '');
    _date = editing?.date ?? widget.initialDate ?? DateTime.now();
    _tags = <String>{...(editing?.tags ?? const <String>[])};
    _selectedItems = <String>{...(editing?.closetItemIds ?? const <String>[])};
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.editing;
    final previewPath = _pickedImagePath.isNotEmpty ? _pickedImagePath : (editing?.imagePath ?? '');

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: DsSpace.md,
          right: DsSpace.md,
          top: DsSpace.sm,
          bottom: MediaQuery.of(context).viewInsets.bottom + DsSpace.md,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(editing == null ? '记录今日穿搭' : '编辑穿搭记录', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: DsSpace.sm),
              PaperCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ImagePreview(path: previewPath, onPick: _pickImage),
                    const SizedBox(height: DsSpace.sm),
                    Row(
                      children: [
                        Expanded(child: Text('记录日期：${ymd(_date)}')),
                        TextButton(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                              initialDate: _date,
                            );
                            if (picked != null) {
                              setState(() {
                                _date = picked;
                              });
                            }
                          },
                          child: const Text('选择日期'),
                        ),
                      ],
                    ),
                    const SizedBox(height: DsSpace.sm),
                    TextField(
                      controller: _note,
                      maxLines: 3,
                      style: const TextStyle(fontSize: 14),
                      decoration: const InputDecoration(
                        labelText: '穿搭笔记',
                        hintText: '记录灵感、场合或心情',
                        labelStyle: TextStyle(fontSize: 13),
                        hintStyle: TextStyle(fontSize: 12, color: DsColors.mutedInk),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: DsSpace.md),
              Text('标签', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: DsSpace.sm),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: LocalStore.outfitTagPresets.map((tag) {
                  final selected = _tags.contains(tag);
                  return FilterChip(
                    label: Text(tag),
                    selected: selected,
                    onSelected: (_) {
                      setState(() {
                        if (selected) {
                          _tags.remove(tag);
                        } else {
                          _tags.add(tag);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: DsSpace.md),
              Text('关联衣橱单品（多选）', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: DsSpace.sm),
              if (widget.store.closet.isEmpty)
                const EmptyState(title: '还没有衣橱单品', caption: '先去衣橱页添加，再回来关联吧～')
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: widget.store.closet.map((item) {
                    final selected = _selectedItems.contains(item.id);
                    return FilterChip(
                      label: Text(item.name),
                      selected: selected,
                      onSelected: (_) {
                        setState(() {
                          if (selected) {
                            _selectedItems.remove(item.id);
                          } else {
                            _selectedItems.add(item.id);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              const SizedBox(height: DsSpace.md),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('取消'),
                    ),
                  ),
                  const SizedBox(width: DsSpace.sm),
                  Expanded(
                    child: CopperButton(
                      label: '保存',
                      onPressed: _handleSubmit,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final action = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('从相册选择'),
                onTap: () => Navigator.of(context).pop('gallery'),
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('打开相机'),
                onTap: () => Navigator.of(context).pop('camera'),
              ),
            ],
          ),
        );
      },
    );

    if (!mounted || action == null) return;
    final source = action == 'camera' ? ImageSource.camera : ImageSource.gallery;
    final file = await _picker.pickImage(source: source, imageQuality: 85);
    if (file != null) {
      setState(() {
        _pickedImagePath = file.path;
      });
    }
  }

  Future<void> _handleSubmit() async {
    if ((_pickedImagePath.isEmpty && widget.editing?.imagePath.isNullOrEmpty == true)) {
      showSnack(context, '请选择一张穿搭照片');
      return;
    }

    await widget.store.upsertOutfit(
      existing: widget.editing,
      imageSourcePath: _pickedImagePath,
      date: _date,
      note: _note.text,
      tags: _tags.toList(),
      closetItemIds: _selectedItems.toList(),
    );
    if (!mounted) return;
    showSnack(context, '穿搭已保存');
    Navigator.of(context).pop(true);
  }
}

extension on String? {
  bool get isNullOrEmpty => this == null || this!.trim().isEmpty;
}

class _ImagePreview extends StatelessWidget {
  const _ImagePreview({required this.path, required this.onPick});

  final String path;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('照片', style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 8),
        SizedBox(
          height: 220,
          child: Stack(
            children: [
              Positioned.fill(
                child: AppImage(path: path, radius: DsRadius.lg),
              ),
              Positioned(
                right: 12,
                bottom: 12,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: DsColors.copper,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: onPick,
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: const Text('选择'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
