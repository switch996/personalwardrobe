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
  return Navigator.of(context).push<bool>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => _ClosetItemEditorPage(store: store, editing: editing),
    ),
  );
}

class _ClosetItemEditorPage extends StatefulWidget {
  const _ClosetItemEditorPage({required this.store, this.editing});

  final LocalStore store;
  final ClosetItem? editing;

  @override
  State<_ClosetItemEditorPage> createState() => _ClosetItemEditorPageState();
}

class _ClosetItemEditorPageState extends State<_ClosetItemEditorPage> {
  late final TextEditingController _name;
  late final TextEditingController _brand;
  late final TextEditingController _color;
  late final TextEditingController _note;
  late final TextEditingController _price;
  late final TextEditingController _customSpec;
  late String _category;
  late String _specValue;
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
      text: editing == null || editing.price == 0
          ? ''
          : editing.price.toStringAsFixed(0),
    );
    _category = editing?.category ?? LocalStore.closetCategories.first;
    final storedSpec = (editing?.subCategory ?? '').trim();
    final initialOptions = _specOptionsForCategory(_category);
    final isCustom = storedSpec.isNotEmpty && !initialOptions.contains(storedSpec);
    _customSpec = TextEditingController(text: isCustom ? storedSpec : '');
    _specValue = storedSpec.isNotEmpty ? storedSpec : initialOptions.first;
  }

  @override
  void dispose() {
    _name.dispose();
    _brand.dispose();
    _color.dispose();
    _note.dispose();
    _price.dispose();
    _customSpec.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.editing;
    final previewPath =
        _pickedImagePath.isNotEmpty ? _pickedImagePath : (editing?.imagePath ?? '');

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F5),
        foregroundColor: DsColors.ink,
        elevation: 0,
        centerTitle: true,
        leadingWidth: 74,
        leading: TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text(
            '取消',
            style: TextStyle(
              color: Color(0xFF4F4F4F),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        title: Text(
          editing == null ? '新建单品' : '编辑单品',
          style: const TextStyle(
            color: DsColors.ink,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _handleSubmit,
            child: const Text(
              '保存',
              style: TextStyle(
                color: Color(0xFFD32F2F),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      body: AnimatedPadding(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
            children: [
              _PhotoBlock(path: previewPath, onPick: _showImagePicker),
              const SizedBox(height: 18),
              _GroupCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _UnderlinedField(
                      controller: _name,
                      label: '名称',
                      hint: '例如：奶油色针织开衫',
                    ),
                    const SizedBox(height: 16),
                    _CategorySelector(
                      value: _category,
                      onChanged: _handleCategoryChange,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _GroupCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SpecSelector(
                      label: _specLabelForCategory(_category),
                      options: _specOptionsForCategory(_category),
                      value: _specValue,
                      customController: _customSpec,
                      onChanged: (value) => setState(() {
                        _specValue = value;
                        if (_customSpec.text.isNotEmpty) {
                          _customSpec.clear();
                        }
                      }),
                      onCustomChanged: _handleCustomSpecChanged,
                    ),
                    const SizedBox(height: 16),
                    _UnderlinedField(
                      controller: _brand,
                      label: '品牌',
                      hint: '可留空',
                    ),
                    const SizedBox(height: 16),
                    _UnderlinedField(
                      controller: _price,
                      label: '价格 (元)',
                      hint: '输入数字，如 899',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _UnderlinedField(
                      controller: _color,
                      label: '颜色',
                      hint: '如：烟粉 / 琥珀',
                    ),
                    const SizedBox(height: 16),
                    _UnderlinedField(
                      controller: _note,
                      label: '备注',
                      hint: '质感、穿搭灵感等',
                      maxLines: 3,
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
      subCategory: _specValue,
      brand: _brand.text,
      color: _color.text,
      note: _note.text,
      price: priceValue,
    );
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  void _handleCategoryChange(String value) {
    final options = _specOptionsForCategory(value);
    setState(() {
      _category = value;
      _customSpec.clear();
      _specValue = options.first;
    });
  }

  void _handleCustomSpecChanged(String value) {
    final text = value.trim();
    final options = _specOptionsForCategory(_category);
    setState(() {
      if (text.isNotEmpty) {
        _specValue = text;
      } else if (!options.contains(_specValue)) {
        _specValue = options.first;
      }
    });
  }

  String _specLabelForCategory(String category) {
    switch (category) {
      case 'top':
      case 'bottom':
      case 'outerwear':
        return '尺码';
      case 'shoes':
        return '鞋码';
      case 'bag':
        return '包型';
      case 'accessory':
        return '配饰类型';
      case 'jewelry':
        return '首饰类型';
      default:
        return '细分类';
    }
  }

  List<String> _specOptionsForCategory(String category) {
    final fromStore = List<String>.from(LocalStore.subCategoryOptions(category));
    List<String> options;
    switch (category) {
      case 'top':
      case 'bottom':
      case 'outerwear':
        options = <String>['S', 'M', 'L', 'XL', 'XXL', '均码'];
        break;
      case 'shoes':
        options = <String>[
          '35',
          '36',
          '37',
          '38',
          '39',
          '40',
          '41',
          '42',
          '43',
          '44',
        ];
        break;
      case 'bag':
      case 'accessory':
      case 'jewelry':
        options = fromStore.isNotEmpty ? fromStore : <String>['常规'];
        break;
      default:
        options = fromStore.isNotEmpty ? fromStore : <String>['常规'];
        break;
    }
    return options;
  }
}

class _PhotoBlock extends StatelessWidget {
  const _PhotoBlock({required this.path, required this.onPick});

  final String path;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPick,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: const Color(0xFFECECEC),
          borderRadius: BorderRadius.circular(20),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned.fill(
              child: path.isEmpty
                  ? const _PhotoPlaceholder()
                  : AppImage(
                      path: path,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      radius: BorderRadius.circular(20),
                    ),
            ),
            Positioned(
              right: 12,
              bottom: 12,
              child: Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  color: Color(0xF2FFFFFF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera_alt_outlined,
                  size: 18,
                  color: Color(0xFF3A3A3A),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoPlaceholder extends StatelessWidget {
  const _PhotoPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.add_a_photo_outlined, color: Color(0xFF8B8B8B), size: 26),
          SizedBox(height: 8),
          Text(
            '点击添加照片',
            style: TextStyle(
              color: Color(0xFF7A7A7A),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  const _GroupCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFECECEC)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _UnderlinedField extends StatelessWidget {
  const _UnderlinedField({
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF666666),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 15, color: DsColors.ink),
          decoration: InputDecoration(
            isDense: true,
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFFA0A0A0), fontSize: 13),
            contentPadding: EdgeInsets.only(bottom: maxLines == 1 ? 8 : 10),
            border: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFDADADA)),
            ),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFDADADA)),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFD32F2F), width: 1.2),
            ),
          ),
        ),
      ],
    );
  }
}

class _CategorySelector extends StatelessWidget {
  const _CategorySelector({required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '分类',
          style: TextStyle(
            color: Color(0xFF666666),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: LocalStore.closetCategories.map((category) {
              final selected = category == value;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => onChanged(category),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFFFFECEC)
                          : const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: selected
                            ? const Color(0xFFD32F2F)
                            : const Color(0xFFE0E0E0),
                      ),
                    ),
                    child: Text(
                      LocalStore.categoryLabel(category),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: selected
                            ? const Color(0xFFD32F2F)
                            : const Color(0xFF555555),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _SpecSelector extends StatelessWidget {
  const _SpecSelector({
    required this.label,
    required this.options,
    required this.value,
    required this.customController,
    required this.onChanged,
    required this.onCustomChanged,
  });

  final String label;
  final List<String> options;
  final String value;
  final TextEditingController customController;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onCustomChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF666666),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final selected = option == value;
            return GestureDetector(
              onTap: () => onChanged(option),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFFFFECEC)
                      : const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: selected
                        ? const Color(0xFFD32F2F)
                        : const Color(0xFFE0E0E0),
                  ),
                ),
                child: Text(
                  option,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: selected
                        ? const Color(0xFFD32F2F)
                        : const Color(0xFF555555),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: customController,
          onChanged: onCustomChanged,
          style: const TextStyle(fontSize: 14, color: DsColors.ink),
          decoration: InputDecoration(
            labelText: '自定义$label（可选）',
            labelStyle: const TextStyle(
              color: Color(0xFF7A7A7A),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            hintText: _customHint(label),
            hintStyle: const TextStyle(color: Color(0xFFA0A0A0), fontSize: 13),
            isDense: true,
            contentPadding: const EdgeInsets.only(bottom: 8),
            border: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFDADADA)),
            ),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFDADADA)),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFD32F2F), width: 1.2),
            ),
          ),
        ),
      ],
    );
  }

  String _customHint(String label) {
    switch (label) {
      case '鞋码':
        return '例如：45、46、45.5';
      case '包型':
        return '例如：医生包、水桶包';
      case '首饰类型':
      case '配饰类型':
        return '例如：脚链、发夹、袖扣';
      default:
        return '例如：其他规格';
    }
  }
}
