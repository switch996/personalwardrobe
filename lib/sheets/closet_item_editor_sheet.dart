import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../design/ds.dart';
import '../design/widgets.dart';
import '../models/closet_item.dart';
import '../store/local_store.dart';
import '../utils/dialog.dart';

Future<bool?> showClosetItemEditorSheet(
  BuildContext context, {
  required LocalStore store,
  ClosetItem? editing,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _ClosetItemEditorSheet(store: store, editing: editing),
  );
}

class _ClosetItemEditorSheet extends StatefulWidget {
  const _ClosetItemEditorSheet({required this.store, this.editing});

  final LocalStore store;
  final ClosetItem? editing;

  @override
  State<_ClosetItemEditorSheet> createState() => _ClosetItemEditorSheetState();
}

class _ClosetItemEditorSheetState extends State<_ClosetItemEditorSheet> {
  late final TextEditingController _name;
  late final TextEditingController _brand;
  late final TextEditingController _color;
  late final TextEditingController _note;
  late final TextEditingController _price;
  late String _category;
  String _pickedImagePath = '';
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final editing = widget.editing;
    _name = TextEditingController(text: editing?.name ?? '');
    _brand = TextEditingController(text: editing?.brand ?? '');
    _color = TextEditingController(text: editing?.color ?? '');
    _note = TextEditingController(text: editing?.note ?? '');
    _price = TextEditingController(
      text: editing == null || editing.price == 0 ? '' : editing.price.toStringAsFixed(0),
    );
    _category = editing?.category ?? LocalStore.closetCategories.first;
  }

  @override
  void dispose() {
    _name.dispose();
    _brand.dispose();
    _color.dispose();
    _note.dispose();
    _price.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.editing;
    final previewPath = _pickedImagePath.isNotEmpty ? _pickedImagePath : (editing?.imagePath ?? '');
    final textTheme = Theme.of(context).textTheme;

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
              Text(editing == null ? '新增衣橱单品' : '编辑衣橱单品', style: textTheme.titleMedium),
              const SizedBox(height: DsSpace.sm),
              PaperCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ImagePreview(path: previewPath, onPick: _showImagePicker),
                    const SizedBox(height: DsSpace.sm),
                    _FieldBlock(
                      controller: _name,
                      label: '名称',
                      hint: '例如：奶油色针织开衫',
                    ),
                    const SizedBox(height: DsSpace.sm),
                    DropdownButtonFormField<String>(
                      initialValue: _category,
                      decoration: _fieldDecoration('分类'),
                      items: LocalStore.closetCategories
                          .map(
                            (value) => DropdownMenuItem<String>(
                              value: value,
                              child: Text(LocalStore.categoryLabel(value), style: const TextStyle(fontSize: 14)),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          _category = value;
                        });
                      },
                    ),
                    const SizedBox(height: DsSpace.sm),
                    _FieldBlock(
                      controller: _brand,
                      label: '品牌',
                      hint: '可留空',
                    ),
                    const SizedBox(height: DsSpace.sm),
                    _FieldBlock(
                      controller: _price,
                      label: '价格 (元)',
                      hint: '输入数字，如 899',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                    const SizedBox(height: DsSpace.sm),
                    _FieldBlock(
                      controller: _color,
                      label: '颜色',
                      hint: '如：烟粉 / 琥珀',
                    ),
                    const SizedBox(height: DsSpace.sm),
                    _FieldBlock(
                      controller: _note,
                      label: '备注',
                      hint: '质感、穿搭灵感等',
                      maxLines: 3,
                    ),
                  ],
                ),
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

  InputDecoration _fieldDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 13),
      hintStyle: const TextStyle(fontSize: 12, color: DsColors.mutedInk),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
  }

  Future<void> _showImagePicker() async {
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
    if (_name.text.trim().isEmpty) {
      showSnack(context, '请填写单品名称');
      return;
    }

    final priceValue = double.tryParse(_price.text.trim()) ?? 0;

    await widget.store.upsertClosetItem(
      existing: widget.editing,
      imageSourcePath: _pickedImagePath,
      name: _name.text,
      category: _category,
      subCategory: widget.editing?.subCategory ?? '',
      brand: _brand.text,
      color: _color.text,
      note: _note.text,
      price: priceValue,
    );
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }
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
        Text('图片', style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 8),
        SizedBox(
          height: 160,
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

class _FieldBlock extends StatelessWidget {
  const _FieldBlock({
    required this.controller,
    required this.label,
    required this.hint,
    this.maxLines = 1,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final int maxLines;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 13),
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 12, color: DsColors.mutedInk),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 12,
          vertical: maxLines == 1 ? 10 : 12,
        ),
      ),
    );
  }
}
