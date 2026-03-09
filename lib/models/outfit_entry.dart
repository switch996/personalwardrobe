class OutfitEntry {
  const OutfitEntry({
    required this.id,
    required this.imagePath,
    required this.date,
    required this.note,
    required this.tags,
    required this.closetItemIds,
  });

  final String id;
  final String imagePath;
  final DateTime date;
  final String note;
  final List<String> tags;
  final List<String> closetItemIds;

  OutfitEntry copyWith({
    String? id,
    String? imagePath,
    DateTime? date,
    String? note,
    List<String>? tags,
    List<String>? closetItemIds,
  }) {
    return OutfitEntry(
      id: id ?? this.id,
      imagePath: imagePath ?? this.imagePath,
      date: date ?? this.date,
      note: note ?? this.note,
      tags: tags ?? this.tags,
      closetItemIds: closetItemIds ?? this.closetItemIds,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imagePath': imagePath,
      'date': date.toIso8601String(),
      'note': note,
      'tags': tags,
      'closetItemIds': closetItemIds,
    };
  }

  factory OutfitEntry.fromJson(Map<String, dynamic> json) {
    return OutfitEntry(
      id: json['id'] as String? ?? '',
      imagePath: json['imagePath'] as String? ?? '',
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
      note: json['note'] as String? ?? '',
      tags: (json['tags'] as List<dynamic>? ?? const <dynamic>[])
          .map((e) => '$e')
          .toList(),
      closetItemIds: (json['closetItemIds'] as List<dynamic>? ?? const <dynamic>[])
          .map((e) => '$e')
          .toList(),
    );
  }
}
