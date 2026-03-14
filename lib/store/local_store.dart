import 'dart:convert';

import '../models/closet_item.dart';
import '../models/outfit_entry.dart';
import '../utils/date.dart';
import 'backend_api.dart';

class LocalStore {
  LocalStore({BackendApi? api}) : _api = api ?? BackendApi();

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

  static const int _quickWearMaxItems = 12;
  static const String _closetMetaPrefix = '[PW_META]';

  final BackendApi _api;

  final List<OutfitEntry> outfits = <OutfitEntry>[];
  final List<ClosetItem> closet = <ClosetItem>[];
  final List<String> todaysQuickWearItemIds = <String>[];

  DateTime? _quickWearDate;

  static String categoryLabel(String category) {
    return closetCategoryLabels[category] ?? category;
  }

  static List<String> subCategoryOptions(String category) {
    return closetSubCategories[category] ?? const <String>[];
  }

  Future<void> loadAll() async {
    try {
      await _api.ensureAuthenticated();
      final outfitItems = await _api.listOutfits();
      final closetItems = await _api.listClosetItems();

      outfits
        ..clear()
        ..addAll(outfitItems.map(_outfitFromApi));
      closet
        ..clear()
        ..addAll(closetItems.map(_closetFromApi));
      _sortInPlace();
      _pruneQuickWearItems();
      _ensureQuickWearDate();
    } catch (_) {
      outfits.clear();
      closet.clear();
      todaysQuickWearItemIds.clear();
      _quickWearDate = DateTime.now();
    }
  }

  Future<void> saveAll() async {
    // No local persistence. UI state is memory-only and backend is source of truth.
  }

  Future<String> copyImageToOutfit(String sourcePath) => _uploadImage(sourcePath);

  Future<String> copyImageToCloset(String sourcePath) => _uploadImage(sourcePath);

  Future<String> _uploadImage(String sourcePath) async {
    final trimmed = sourcePath.trim();
    if (trimmed.isEmpty) return '';
    if (_isRemoteUrl(trimmed)) return trimmed;
    final media = await _api.uploadMedia(trimmed);
    return _api.normalizeMediaUrl(_asString(media['url']));
  }

  Future<void> upsertOutfit({
    OutfitEntry? existing,
    required String imageSourcePath,
    required DateTime date,
    required String note,
    required List<String> tags,
    required List<String> closetItemIds,
  }) async {
    var imageUrl = existing?.imagePath ?? '';
    final sourcePath = imageSourcePath.trim();
    if (sourcePath.isNotEmpty && sourcePath != imageUrl) {
      imageUrl = await copyImageToOutfit(sourcePath);
    }

    final payload = <String, dynamic>{
      'date': _ymd(date),
      'note': note.trim(),
      'tags': tags,
      'closetItemIds': closetItemIds,
    };
    if (imageUrl.isNotEmpty) {
      payload['imageUrl'] = imageUrl;
    }

    final response = existing == null
        ? await _api.createOutfit(payload)
        : await _api.updateOutfit(existing.id, payload);

    final saved = _outfitFromApi(response);
    final idx = outfits.indexWhere((e) => e.id == saved.id);
    if (idx == -1) {
      outfits.add(saved);
    } else {
      outfits[idx] = saved;
    }
    _sortInPlace();
  }

  Future<void> deleteOutfit(String id) async {
    await _api.deleteOutfit(id);
    outfits.removeWhere((e) => e.id == id);
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
    var imageUrl = existing?.imagePath ?? '';
    final sourcePath = imageSourcePath.trim();
    if (sourcePath.isNotEmpty && sourcePath != imageUrl) {
      imageUrl = await copyImageToCloset(sourcePath);
    }

    final payload = <String, dynamic>{
      'name': name.trim(),
      'category': _normalizeCategory(category),
      'brand': brand.trim(),
      'color': color.trim(),
      'note': _composeClosetNote(
        note: note.trim(),
        subCategory: subCategory.trim(),
        price: price,
      ),
    };
    if (imageUrl.isNotEmpty) {
      payload['imageUrl'] = imageUrl;
    }

    final response = existing == null
        ? await _api.createClosetItem(payload)
        : await _api.updateClosetItem(existing.id, payload);

    final saved = _closetFromApi(response);
    final idx = closet.indexWhere((e) => e.id == saved.id);
    if (idx == -1) {
      closet.add(saved);
    } else {
      closet[idx] = saved;
    }
    closet.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> deleteClosetItem(String id) async {
    await _api.deleteClosetItem(id);

    closet.removeWhere((e) => e.id == id);
    for (var i = 0; i < outfits.length; i++) {
      final o = outfits[i];
      if (o.closetItemIds.contains(id)) {
        outfits[i] = o.copyWith(
          closetItemIds: o.closetItemIds.where((e) => e != id).toList(),
        );
      }
    }
    todaysQuickWearItemIds.remove(id);
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
    final exists = closet.any((e) => e.id == closetItemId);
    if (!exists) return;

    _ensureQuickWearDate();

    _pruneQuickWearItems();
    todaysQuickWearItemIds.remove(closetItemId);
    todaysQuickWearItemIds.insert(0, closetItemId);
    if (todaysQuickWearItemIds.length > _quickWearMaxItems) {
      todaysQuickWearItemIds.removeRange(_quickWearMaxItems, todaysQuickWearItemIds.length);
    }
  }

  Future<bool> removeQuickWearItem(String closetItemId) async {
    _ensureQuickWearDate();
    return todaysQuickWearItemIds.remove(closetItemId);
  }

  List<ClosetItem> quickWearItemsForToday() {
    _ensureQuickWearDate();
    if (todaysQuickWearItemIds.isEmpty) return const <ClosetItem>[];
    final lookup = <String, ClosetItem>{for (final item in closet) item.id: item};
    return todaysQuickWearItemIds.map((id) => lookup[id]).whereType<ClosetItem>().toList();
  }

  void _ensureQuickWearDate() {
    final now = DateTime.now();
    if (_quickWearDate == null || !isSameDay(_quickWearDate!, now)) {
      todaysQuickWearItemIds.clear();
      _quickWearDate = now;
    }
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

  OutfitEntry _outfitFromApi(Map<String, dynamic> json) {
    return OutfitEntry(
      id: _asString(json['id']),
      imagePath: _api.normalizeMediaUrl(_asString(json['imageUrl'])),
      date: DateTime.tryParse(_asString(json['date'])) ?? DateTime.now(),
      note: _asString(json['note']),
      tags: (_asList(json['tags'])).map((e) => '$e').toList(),
      closetItemIds: (_asList(json['closetItemIds'])).map((e) => '$e').toList(),
    );
  }

  ClosetItem _closetFromApi(Map<String, dynamic> json) {
    final parsedNote = _parseClosetNote(_asString(json['note']));
    return ClosetItem(
      id: _asString(json['id']),
      imagePath: _api.normalizeMediaUrl(_asString(json['imageUrl'])),
      name: _asString(json['name']),
      category: _normalizeCategory(_asString(json['category'])),
      subCategory: parsedNote.subCategory,
      brand: _asString(json['brand']),
      color: _asString(json['color']),
      note: parsedNote.note,
      price: parsedNote.price,
      createdAt: DateTime.tryParse(_asString(json['createdAt'])) ?? DateTime.now(),
    );
  }

  String _normalizeCategory(String category) {
    return closetCategories.contains(category) ? category : closetCategories.first;
  }

  String _composeClosetNote({
    required String note,
    required String subCategory,
    required double price,
  }) {
    if (subCategory.isEmpty && price <= 0) {
      return note;
    }

    final metaRaw = jsonEncode(<String, dynamic>{
      'subCategory': subCategory,
      'price': price,
    });
    final encoded = base64Url.encode(utf8.encode(metaRaw));

    if (note.isEmpty) {
      return '$_closetMetaPrefix$encoded';
    }
    return '$_closetMetaPrefix$encoded\n$note';
  }

  _ClosetNoteParsed _parseClosetNote(String raw) {
    if (!raw.startsWith(_closetMetaPrefix)) {
      return _ClosetNoteParsed(note: raw, subCategory: '', price: 0);
    }

    final firstLineBreak = raw.indexOf('\n');
    final metaEncoded = firstLineBreak == -1
        ? raw.substring(_closetMetaPrefix.length)
        : raw.substring(_closetMetaPrefix.length, firstLineBreak);
    final note = firstLineBreak == -1 ? '' : raw.substring(firstLineBreak + 1).trimLeft();

    try {
      final metaJson = utf8.decode(base64Url.decode(metaEncoded));
      final decoded = jsonDecode(metaJson);
      if (decoded is Map<String, dynamic>) {
        return _ClosetNoteParsed(
          note: note,
          subCategory: _asString(decoded['subCategory']),
          price: (decoded['price'] as num?)?.toDouble() ?? 0,
        );
      }
    } catch (_) {
      return _ClosetNoteParsed(note: raw, subCategory: '', price: 0);
    }

    return _ClosetNoteParsed(note: note, subCategory: '', price: 0);
  }

  bool _isRemoteUrl(String value) {
    return value.startsWith('http://') || value.startsWith('https://');
  }

  String _ymd(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  String _asString(Object? value) {
    return value == null ? '' : '$value';
  }

  List<dynamic> _asList(Object? value) {
    if (value is List<dynamic>) return value;
    return const <dynamic>[];
  }
}

class _ClosetNoteParsed {
  const _ClosetNoteParsed({
    required this.note,
    required this.subCategory,
    required this.price,
  });

  final String note;
  final String subCategory;
  final double price;
}

