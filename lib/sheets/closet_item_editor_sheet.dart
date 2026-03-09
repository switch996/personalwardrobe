import 'package:flutter/material.dart';

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
  const _ClosetItemEditorSheet({required this.store, required this.editing});

  final LocalStore store;
  final ClosetItem? editing;

  @override
  State<_ClosetItemEditorSheet> createState() => _ClosetItemEditorSheetState();
}

class _ClosetItemEditorSheetState extends State<_ClosetItemEditorSheet> {
  late final TextEditingController _imagePath;
  late final TextEditingController _name;
  late final TextEditingController _brand;
  late final TextEditingController _color;
  late final TextEditingController _note;
  late String _category;

  @override
  void initState() {
    super.initState();
    final editing = widget.editing;
    _imagePath = TextEditingController(text: editing?.imagePath ?? '');
    _name = TextEditingController(text: editing?.name ?? '');
    _brand = TextEditingController(text: editing?.brand ?? '');
    _color = TextEditingController(text: editing?.color ?? '');
    _note = TextEditingController(text: editing?.note ?? '');
    _category = editing?.category ?? LocalStore.closetCategories.first;
  }

  @override
  void dispose() {
    _imagePath.dispose();
    _name.dispose();
    _brand.dispose();
    _color.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.editing;

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
              Text(
                editing == null ? 'New Closet Item' : 'Edit Closet Item',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: DsSpace.sm),
              PaperCard(
                child: Column(
                  children: [
                    TextField(
                      controller: _imagePath,
                      decoration: const InputDecoration(
                        labelText: 'Image path',
                        hintText: 'Paste local image path',
                      ),
                    ),
                    const SizedBox(height: DsSpace.sm),
                    TextField(
                      controller: _name,
                      decoration: const InputDecoration(labelText: 'Name *'),
                    ),
                    const SizedBox(height: DsSpace.sm),
                    DropdownButtonFormField<String>(
                      initialValue: _category,
                      items: LocalStore.closetCategories
                          .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          _category = value;
                        });
                      },
                      decoration: const InputDecoration(labelText: 'Category'),
                    ),
                    const SizedBox(height: DsSpace.sm),
                    TextField(
                      controller: _brand,
                      decoration: const InputDecoration(labelText: 'Brand (optional)'),
                    ),
                    const SizedBox(height: DsSpace.sm),
                    TextField(
                      controller: _color,
                      decoration: const InputDecoration(labelText: 'Color (optional)'),
                    ),
                    const SizedBox(height: DsSpace.sm),
                    TextField(
                      controller: _note,
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: 'Note (optional)'),
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
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: DsSpace.sm),
                  Expanded(
                    child: CopperButton(
                      label: 'Save',
                      onPressed: () async {
                        if (_name.text.trim().isEmpty) {
                          showSnack(context, 'Name is required');
                          return;
                        }
                        await widget.store.upsertClosetItem(
                          existing: editing,
                          imageSourcePath: _imagePath.text,
                          name: _name.text,
                          category: _category,
                          brand: _brand.text,
                          color: _color.text,
                          note: _note.text,
                        );
                        if (!context.mounted) return;
                        showSnack(context, 'Closet item saved');
                        Navigator.of(context).pop(true);
                      },
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
}
