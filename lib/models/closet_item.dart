class ClosetItem {
  const ClosetItem({
    required this.id,
    required this.imagePath,
    required this.name,
    required this.category,
    required this.subCategory,
    required this.brand,
    required this.color,
    required this.note,
    required this.price,
    required this.createdAt,
  });

  final String id;
  final String imagePath;
  final String name;
  final String category;
  final String subCategory;
  final String brand;
  final String color;
  final String note;
  final double price;
  final DateTime createdAt;

  ClosetItem copyWith({
    String? id,
    String? imagePath,
    String? name,
    String? category,
    String? subCategory,
    String? brand,
    String? color,
    String? note,
    double? price,
    DateTime? createdAt,
  }) {
    return ClosetItem(
      id: id ?? this.id,
      imagePath: imagePath ?? this.imagePath,
      name: name ?? this.name,
      category: category ?? this.category,
      subCategory: subCategory ?? this.subCategory,
      brand: brand ?? this.brand,
      color: color ?? this.color,
      note: note ?? this.note,
      price: price ?? this.price,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imagePath': imagePath,
      'name': name,
      'category': category,
      'subCategory': subCategory,
      'brand': brand,
      'color': color,
      'note': note,
      'price': price,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ClosetItem.fromJson(Map<String, dynamic> json) {
    return ClosetItem(
      id: json['id'] as String? ?? '',
      imagePath: json['imagePath'] as String? ?? '',
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? 'top',
      subCategory: json['subCategory'] as String? ?? '',
      brand: json['brand'] as String? ?? '',
      color: json['color'] as String? ?? '',
      note: json['note'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

