import 'package:flutter/material.dart';

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
  late final TextEditingController _imagePath;
  late DateTime _date;
  late Set<String> _tags;
  late Set<String> _selectedItems;

  @override
  void initState() {
    super.initState();
    final editing = widget.editing;
    _note = TextEditingController(text: editing?.note ?? '');
    _imagePath = TextEditingController(text: editing?.imagePath ?? '');
    _date = editing?.date ?? widget.initialDate ?? DateTime.now();
    _tags = <String>{...(editing?.tags ?? const <String>[])};
    _selectedItems = <String>{...(editing?.closetItemIds ?? const <String>[])};
  }

  @override
  void dispose() {
    _note.dispose();
    _imagePath.dispose();
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
                editing == null ? 'New Outfit' : 'Edit Outfit',
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
                        hintText: 'Paste local image path (album import path)',
                      ),
                    ),
                    const SizedBox(height: DsSpace.sm),
                    Row(
                      children: [
                        Expanded(child: Text('Date: ${ymd(_date)}')),
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
                          child: const Text('Pick date'),
                        ),
                      ],
                    ),
                    const SizedBox(height: DsSpace.sm),
                    TextField(
                      controller: _note,
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: 'Note'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: DsSpace.md),
              Text('Tags', style: Theme.of(context).textTheme.titleMedium),
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
              Text(
                'Link Closet Items (multi-select)',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: DsSpace.sm),
              if (widget.store.closet.isEmpty)
                const EmptyState(
                  title: 'No closet item',
                  caption: 'Create closet item first in Closet tab.',
                )
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
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: DsSpace.sm),
                  Expanded(
                    child: CopperButton(
                      label: 'Save',
                      onPressed: () async {
                        await widget.store.upsertOutfit(
                          existing: editing,
                          imageSourcePath: _imagePath.text,
                          date: _date,
                          note: _note.text,
                          tags: _tags.toList(),
                          closetItemIds: _selectedItems.toList(),
                        );
                        if (!context.mounted) return;
                        showSnack(context, 'Outfit saved');
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
