import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/closet_item.dart';
import '../models/outfit_entry.dart';
import '../utils/date.dart';

class LocalStore {
  static const List<String> outfitTagPresets = <String>[
    '通勤',
    '约会',
    '休闲',
    '运动',
    '度假',
    '聚会',
    '极简',
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

  static const Map<String, String> closetCategoryLabels = <String, String>{
    'top': '上装',
    'bottom': '下装',
    'shoes': '鞋子',
    'accessory': '配饰',
    'outerwear': '外套',
    'dress': '连衣裙',
    'bag': '包袋',
  };

  static const Map<String, List<String>> closetSubCategories = <String, List<String>>{
    'top': ['长袖', '短袖', 'T恤', '衬衫'],
    'bottom': ['长裤', '短裤', '半身裙', '牛仔'],
    'shoes': ['运动鞋', '乐福鞋', '高跟鞋', '靴子'],
    'accessory': ['项链', '耳饰', '帽子', '腰带'],
    'outerwear': ['风衣', '西装', '大衣', '披肩'],
    'dress': ['连衣裙', '半裙', '礼服'],
    'bag': ['手提包', '斜挎包', '托特包', '双肩包'],
  };

  static String categoryLabel(String category) {
    return closetCategoryLabels[category] ?? category;
  }

  static List<String> subCategoryOptions(String category) {
    return closetSubCategories[category] ?? const <String>[];
  }

  static const int _quickWearMaxItems = 12;

  final List<OutfitEntry> outfits = <OutfitEntry>[];
  final List<ClosetItem> closet = <ClosetItem>[];
  final List<String> todaysQuickWearItemIds = <String>[];

  Directory? _root;
  DateTime? _quickWearDate;

  Future<void> loadAll() async {
    _root = await _ensureRoot();
    outfits
      ..clear()
      ..addAll(await _loadOutfits());
    closet
      ..clear()
      ..addAll(await _loadCloset());
    _sortInPlace();
    await _loadQuickWear();
  }

  Future<Directory> _ensureRoot() async {
    Directory base = await _documentsBase();
    try {
      await base.create(recursive: true);
    } on FileSystemException {
      final fallback = Directory('${Directory.systemTemp.path}${Platform.pathSeparator}app_documents');
      await fallback.create(recursive: true);
      base = fallback;
    }

    await Directory('${base.path}${Platform.pathSeparator}outfit_images').create(recursive: true);
    await Directory('${base.path}${Platform.pathSeparator}closet_images').create(recursive: true);
    return base;
  }

  Future<Directory> _documentsBase() async {
    Directory? parent;
    try {
      parent = await getApplicationDocumentsDirectory();
    } on MissingPlatformDirectoryException {
      parent = null;
    }

    parent ??= await getTemporaryDirectory();
    if (_isInvalidPath(parent.path)) {
      parent = Directory.systemTemp;
    }

    final normalized = parent.path.endsWith(Platform.pathSeparator)
        ? parent.path.substring(0, parent.path.length - 1)
        : parent.path;
    return Directory('$normalized${Platform.pathSeparator}app_documents');
  }

  bool _isInvalidPath(String path) {
    final trimmed = path.trim();
    return trimmed.isEmpty || trimmed == '/' || trimmed == '\\';
  }

  File get _outfitsFile => File('${_root!.path}${Platform.pathSeparator}outfits.json');
  File get _closetFile => File('${_root!.path}${Platform.pathSeparator}closet.json');
  File get _quickWearFile => File('${_root!.path}${Platform.pathSeparator}quick_wear.json');

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
    required String subCategory,
    required String brand,
    required String color,
    required String note,
    required double price,
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
      subCategory: subCategory,
      brand: brand.trim(),
      color: color.trim(),
      note: note.trim(),
      price: price,
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
    final removed = todaysQuickWearItemIds.remove(id);
    await saveAll();
    if (removed) {
      await _persistQuickWear();
    }
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

  Future<void> markItemAsWornToday(String closetItemId) async {
    if (_root == null) return;
    final exists = closet.any((e) => e.id == closetItemId);
    if (!exists) return;

    final now = DateTime.now();
    if (_quickWearDate == null || !isSameDay(_quickWearDate!, now)) {
      todaysQuickWearItemIds.clear();
      _quickWearDate = now;
    }

    _pruneQuickWearItems();
    todaysQuickWearItemIds.remove(closetItemId);
    todaysQuickWearItemIds.insert(0, closetItemId);
    if (todaysQuickWearItemIds.length > _quickWearMaxItems) {
      todaysQuickWearItemIds.removeRange(_quickWearMaxItems, todaysQuickWearItemIds.length);
    }

    await _persistQuickWear();
  }

  Future<bool> removeQuickWearItem(String closetItemId) async {
    if (_quickWearDate == null || !isSameDay(_quickWearDate!, DateTime.now())) {
      todaysQuickWearItemIds.clear();
      _quickWearDate = null;
      await _persistQuickWear();
      return false;
    }
    final removed = todaysQuickWearItemIds.remove(closetItemId);
    if (removed) {
      await _persistQuickWear();
    }
    return removed;
  }

  List<ClosetItem> quickWearItemsForToday() {
    if (_quickWearDate == null || !isSameDay(_quickWearDate!, DateTime.now())) {
      return const <ClosetItem>[];
    }
    if (todaysQuickWearItemIds.isEmpty) return const <ClosetItem>[];
    final lookup = <String, ClosetItem>{for (final item in closet) item.id: item};
    return todaysQuickWearItemIds.map((id) => lookup[id]).whereType<ClosetItem>().toList();
  }

  Future<void> _loadQuickWear() async {
    todaysQuickWearItemIds.clear();
    _quickWearDate = null;
    if (!await _quickWearFile.exists()) {
      await _quickWearFile.writeAsString(jsonEncode({'date': '', 'itemIds': <String>[]}));
      return;
    }

    try {
      final text = await _quickWearFile.readAsString();
      final decoded = jsonDecode(text);
      if (decoded is Map) {
        final data = Map<String, dynamic>.from(decoded);
        final date = DateTime.tryParse(data['date'] as String? ?? '');
        final items = (data['itemIds'] as List?)?.whereType<String>().toList() ?? <String>[];
        if (date != null && isSameDay(date, DateTime.now())) {
          todaysQuickWearItemIds.addAll(items);
          _quickWearDate = date;
          _pruneQuickWearItems();
        }
      }
    } catch (_) {
      await _quickWearFile.writeAsString(jsonEncode({'date': '', 'itemIds': <String>[]}));
    }
  }

  Future<void> _persistQuickWear() async {
    await _quickWearFile.writeAsString(
      jsonEncode({
        'date': _quickWearDate?.toIso8601String() ?? '',
        'itemIds': todaysQuickWearItemIds,
      }),
    );
  }

  void _pruneQuickWearItems() {
    if (todaysQuickWearItemIds.isEmpty) return;
    final closetIds = closet.map((e) => e.id).toSet();
    final seen = <String>{};
    final filtered = <String>[];
    for (final id in todaysQuickWearItemIds) {
      if (!closetIds.contains(id)) continue;
      if (seen.add(id)) filtered.add(id);
    }
    todaysQuickWearItemIds
      ..clear()
      ..addAll(filtered);
  }
}
