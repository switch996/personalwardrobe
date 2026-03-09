import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/closet_item.dart';
import '../models/outfit_entry.dart';
import '../utils/date.dart';

class LocalStore {
  static const List<String> outfitTagPresets = <String>[
    'Work',
    'Casual',
    'Date',
    'Travel',
    'Vintage',
    'Street',
    'Formal',
  ];

  static const List<String> closetCategories = <String>[
    'top',
    'bottom',
    'shoes',
    'accessory',
    'outerwear',
    'dress',
    'bag',
  ];

  final List<OutfitEntry> outfits = <OutfitEntry>[];
  final List<ClosetItem> closet = <ClosetItem>[];

  Directory? _root;

  Future<void> loadAll() async {
    _root = await _ensureRoot();
    outfits
      ..clear()
      ..addAll(await _loadOutfits());
    closet
      ..clear()
      ..addAll(await _loadCloset());
    _sortInPlace();
  }

  Future<Directory> _ensureRoot() async {
    Directory parent;
    try {
      parent = await getApplicationDocumentsDirectory();
    } on MissingPlatformDirectoryException {
      parent = Directory.systemTemp;
    }
    final base = Directory('${parent.path}${Platform.pathSeparator}app_documents');
    if (!await base.exists()) {
      await base.create(recursive: true);
    }
    await Directory('${base.path}${Platform.pathSeparator}outfit_images').create(recursive: true);
    await Directory('${base.path}${Platform.pathSeparator}closet_images').create(recursive: true);
    return base;
  }

  File get _outfitsFile => File('${_root!.path}${Platform.pathSeparator}outfits.json');
  File get _closetFile => File('${_root!.path}${Platform.pathSeparator}closet.json');

  Future<List<OutfitEntry>> _loadOutfits() async {
    if (!await _outfitsFile.exists()) {
      await _outfitsFile.writeAsString('[]');
      return <OutfitEntry>[];
    }
    final text = await _outfitsFile.readAsString();
    final decoded = jsonDecode(text);
    if (decoded is! List<dynamic>) return <OutfitEntry>[];
    return decoded
        .whereType<Map>()
        .map((e) => OutfitEntry.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<List<ClosetItem>> _loadCloset() async {
    if (!await _closetFile.exists()) {
      await _closetFile.writeAsString('[]');
      return <ClosetItem>[];
    }
    final text = await _closetFile.readAsString();
    final decoded = jsonDecode(text);
    if (decoded is! List<dynamic>) return <ClosetItem>[];
    return decoded
        .whereType<Map>()
        .map((e) => ClosetItem.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> saveAll() async {
    await Future.wait(<Future<void>>[
      _outfitsFile.writeAsString(jsonEncode(outfits.map((e) => e.toJson()).toList())),
      _closetFile.writeAsString(jsonEncode(closet.map((e) => e.toJson()).toList())),
    ]);
  }

  String _id() => '${DateTime.now().microsecondsSinceEpoch}_${DateTime.now().millisecondsSinceEpoch % 1000}';

  Future<String> copyImageToOutfit(String sourcePath) => _copyImage(sourcePath, 'outfit_images');

  Future<String> copyImageToCloset(String sourcePath) => _copyImage(sourcePath, 'closet_images');

  Future<String> _copyImage(String sourcePath, String folder) async {
    if (sourcePath.trim().isEmpty) return '';
    final source = File(sourcePath.trim());
    if (!await source.exists()) return '';
    final hasExt = source.path.contains('.');
    final ext = hasExt ? source.path.substring(source.path.lastIndexOf('.')) : '.jpg';
    final target = File('${_root!.path}${Platform.pathSeparator}$folder${Platform.pathSeparator}${_id()}$ext');
    await source.copy(target.path);
    return target.path;
  }

  Future<void> upsertOutfit({
    OutfitEntry? existing,
    required String imageSourcePath,
    required DateTime date,
    required String note,
    required List<String> tags,
    required List<String> closetItemIds,
  }) async {
    var imagePath = existing?.imagePath ?? '';
    if (imageSourcePath.trim().isNotEmpty && imageSourcePath.trim() != imagePath) {
      imagePath = await copyImageToOutfit(imageSourcePath);
    }

    final entry = OutfitEntry(
      id: existing?.id ?? _id(),
      imagePath: imagePath,
      date: date,
      note: note.trim(),
      tags: tags,
      closetItemIds: closetItemIds,
    );

    final idx = outfits.indexWhere((e) => e.id == entry.id);
    if (idx == -1) {
      outfits.add(entry);
    } else {
      outfits[idx] = entry;
    }
    _sortInPlace();
    await _outfitsFile.writeAsString(jsonEncode(outfits.map((e) => e.toJson()).toList()));
  }

  Future<void> deleteOutfit(String id) async {
    outfits.removeWhere((e) => e.id == id);
    await _outfitsFile.writeAsString(jsonEncode(outfits.map((e) => e.toJson()).toList()));
  }

  Future<void> upsertClosetItem({
    ClosetItem? existing,
    required String imageSourcePath,
    required String name,
    required String category,
    required String brand,
    required String color,
    required String note,
  }) async {
    var imagePath = existing?.imagePath ?? '';
    if (imageSourcePath.trim().isNotEmpty && imageSourcePath.trim() != imagePath) {
      imagePath = await copyImageToCloset(imageSourcePath);
    }

    final item = ClosetItem(
      id: existing?.id ?? _id(),
      imagePath: imagePath,
      name: name.trim(),
      category: category,
      brand: brand.trim(),
      color: color.trim(),
      note: note.trim(),
      createdAt: existing?.createdAt ?? DateTime.now(),
    );

    final idx = closet.indexWhere((e) => e.id == item.id);
    if (idx == -1) {
      closet.add(item);
    } else {
      closet[idx] = item;
    }
    closet.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    await _closetFile.writeAsString(jsonEncode(closet.map((e) => e.toJson()).toList()));
  }

  Future<void> deleteClosetItem(String id) async {
    closet.removeWhere((e) => e.id == id);
    for (var i = 0; i < outfits.length; i++) {
      final o = outfits[i];
      if (o.closetItemIds.contains(id)) {
        outfits[i] = o.copyWith(closetItemIds: o.closetItemIds.where((e) => e != id).toList());
      }
    }
    await saveAll();
  }

  List<OutfitEntry> outfitsOn(DateTime day) {
    return outfits.where((e) => isSameDay(e.date, day)).toList();
  }

  List<OutfitEntry> outfitsUsingItem(String closetItemId) {
    return outfits.where((e) => e.closetItemIds.contains(closetItemId)).toList();
  }

  void _sortInPlace() {
    outfits.sort((a, b) => b.date.compareTo(a.date));
    closet.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }
}
