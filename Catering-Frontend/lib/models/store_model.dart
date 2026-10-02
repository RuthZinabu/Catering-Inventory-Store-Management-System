import 'package:json_annotation/json_annotation.dart';

part 'store_model.g.dart';

@JsonSerializable()
class Store {
  final String id;
  final String name;
  final String code;
  final String description;
  final String location;
  final String phone;
  final String email;
  final String manager;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  @JsonKey(name: 'store_type')
  final String? storeType;
  @JsonKey(name: 'store_level')
  final int? storeLevel;
  @JsonKey(name: 'parent_store_id')
  final String? parentStoreId;

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
    this.storeType,
    this.storeLevel,
    this.parentStoreId,
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
    String? storeType,
    int? storeLevel,
    String? parentStoreId,
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
      storeType: storeType ?? this.storeType,
      storeLevel: storeLevel ?? this.storeLevel,
      parentStoreId: parentStoreId ?? this.parentStoreId,
    );
  }

  factory Store.fromJson(Map<String, dynamic> json) => _$StoreFromJson(json);

  Map<String, dynamic> toJson() => _$StoreToJson(this);
}
