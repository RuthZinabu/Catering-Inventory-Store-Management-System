class Store {
  final String id;
  final String name;
  final String code;
  final String description;
  final String location;
  final String phone;
  final String email;
  final String manager;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Store({
    required this.id,
    required this.name,
    required this.code,
    this.description = '',
    this.location = '',
    this.phone = '',
    this.email = '',
    this.manager = '',
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  static const List<Map<String, String>> storeTypes = [
    {'value': 'main_warehouse', 'label': 'Main Warehouse'},
    {'value': 'dry_food', 'label': 'Dry Food Store'},
    {'value': 'cold_room', 'label': 'Cold Room'},
    {'value': 'freezer', 'label': 'Freezer Store'},
    {'value': 'beverage', 'label': 'Beverage Store'},
    {'value': 'kitchen', 'label': 'Kitchen Store'},
    {'value': 'electronics', 'label': 'Electronics Store'},
    {'value': 'general', 'label': 'General Store'},
  ];

  Store copyWith({
    String? id,
    String? name,
    String? code,
    String? description,
    String? location,
    String? phone,
    String? email,
    String? manager,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Store(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      description: description ?? this.description,
      location: location ?? this.location,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      manager: manager ?? this.manager,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'code': code,
        'description': description,
        'location': location,
        'phone': phone,
        'email': email,
        'manager': manager,
        'isActive': isActive,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Store.fromJson(Map<String, dynamic> json) => Store(
        id: json['id'] as String,
        name: json['name'] as String,
        code: json['code'] as String,
        description: json['description'] as String? ?? '',
        location: json['location'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        email: json['email'] as String? ?? '',
        manager: json['manager'] as String? ?? '',
        isActive: json['isActive'] as bool? ?? true,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );
}
