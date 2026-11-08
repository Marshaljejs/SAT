class Category {
  const Category({required this.id, required this.name, this.order = 0});

  final String id;
  final String name;
  final int order;

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'order': order};

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      order: (json['order'] as num?)?.toInt() ?? 0,
    );
  }
}
