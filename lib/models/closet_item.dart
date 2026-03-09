class ClosetItem {
  const ClosetItem({
    required this.id,
    required this.imagePath,
    required this.name,
    required this.category,
    required this.brand,
    required this.color,
    required this.note,
    required this.createdAt,
  });

  final String id;
  final String imagePath;
  final String name;
  final String category;
  final String brand;
  final String color;
  final String note;
  final DateTime createdAt;

  ClosetItem copyWith({
    String? id,
    String? imagePath,
    String? name,
    String? category,
    String? brand,
    String? color,
    String? note,
    DateTime? createdAt,
  }) {
    return ClosetItem(
      id: id ?? this.id,
      imagePath: imagePath ?? this.imagePath,
      name: name ?? this.name,
      category: category ?? this.category,
      brand: brand ?? this.brand,
      color: color ?? this.color,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imagePath': imagePath,
      'name': name,
      'category': category,
      'brand': brand,
      'color': color,
      'note': note,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ClosetItem.fromJson(Map<String, dynamic> json) {
    return ClosetItem(
      id: json['id'] as String? ?? '',
      imagePath: json['imagePath'] as String? ?? '',
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? 'top',
      brand: json['brand'] as String? ?? '',
      color: json['color'] as String? ?? '',
      note: json['note'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
