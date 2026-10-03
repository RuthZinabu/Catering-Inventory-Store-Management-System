import 'package:json_annotation/json_annotation.dart';

part 'auth_models.g.dart';

@JsonSerializable()
class LoginRequest {
  final String email;
  final String password;
  @JsonKey(name: 'device_name')
  final String deviceName;

  const LoginRequest({
    required this.email,
    required this.password,
    required this.deviceName,
  });

  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);

  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);
}

@JsonSerializable()
class AuthResponse {
  @JsonKey(name: 'access_token')
  final String accessToken;
  @JsonKey(name: 'token_type')
  final String tokenType;
  @JsonKey(name: 'expires_in')
  final int expiresIn;
  final AuthUser user;

  const AuthResponse({
    required this.accessToken,
    required this.tokenType,
    required this.expiresIn,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);
}

@JsonSerializable()
class AuthUser {
  final String id;
  final String name;
  final String email;
  final String role;
  final List<String> permissions;
  @JsonKey(name: 'assigned_stores')
  final List<AssignedStore> assignedStores;

  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.permissions,
    required this.assignedStores,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) =>
      _$AuthUserFromJson(json);

  Map<String, dynamic> toJson() => _$AuthUserToJson(this);

  /// Check if user has a specific permission
  bool hasPermission(String permission) {
    return permissions.contains(permission);
  }

  /// Check if user has any of the given permissions
  bool hasAnyPermission(List<String> permissionList) {
    return permissionList.any((permission) => permissions.contains(permission));
  }

  /// Check if user has all of the given permissions
  bool hasAllPermissions(List<String> permissionList) {
    return permissionList.every((permission) => permissions.contains(permission));
  }

  /// Check if user can access a specific store
  bool canAccessStore(String storeId) {
    return assignedStores.any((store) => store.storeId == storeId);
  }

  /// Check if user is admin
  bool get isAdmin => role == 'admin';

  /// Check if user is store manager
  bool get isStoreManager => role == 'store_manager';

  /// Get stores where user has manager role
  List<AssignedStore> get managedStores {
    return assignedStores
        .where((store) => store.roleInStore == 'manager')
        .toList();
  }
}

@JsonSerializable()
class AssignedStore {
  @JsonKey(name: 'store_id')
  final String storeId;
  @JsonKey(name: 'store_name')
  final String storeName;
  @JsonKey(name: 'store_code')
  final String storeCode;
  @JsonKey(name: 'role_in_store')
  final String roleInStore;
  @JsonKey(name: 'can_transfer_to')
  final bool canTransferTo;
  @JsonKey(name: 'can_transfer_from')
  final bool canTransferFrom;

  const AssignedStore({
    required this.storeId,
    required this.storeName,
    required this.storeCode,
    required this.roleInStore,
    required this.canTransferTo,
    required this.canTransferFrom,
  });

  factory AssignedStore.fromJson(Map<String, dynamic> json) =>
      _$AssignedStoreFromJson(json);

  Map<String, dynamic> toJson() => _$AssignedStoreToJson(this);
}

@JsonSerializable()
class RefreshTokenResponse {
  @JsonKey(name: 'access_token')
  final String accessToken;
  @JsonKey(name: 'token_type')
  final String tokenType;
  @JsonKey(name: 'expires_in')
  final int expiresIn;

  const RefreshTokenResponse({
    required this.accessToken,
    required this.tokenType,
    required this.expiresIn,
  });

  factory RefreshTokenResponse.fromJson(Map<String, dynamic> json) =>
      _$RefreshTokenResponseFromJson(json);

  Map<String, dynamic> toJson() => _$RefreshTokenResponseToJson(this);
}

/// Authentication state enum
enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}