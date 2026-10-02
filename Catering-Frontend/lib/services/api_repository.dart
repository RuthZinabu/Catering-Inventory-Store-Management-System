import 'package:catering_inventory_store_management_system/services/api/base_api_service.dart';

import '../models/inventory_models.dart';
import '../models/stock_models.dart';
import '../models/store_model.dart';
import 'user_service.dart';
import 'store_service.dart';
import 'inventory_service.dart';
import 'supplier_service.dart';
import 'stock_service.dart';
import 'mock_repository.dart';

/// Main repository that coordinates between API services and mock data
/// This will gradually replace MockRepository as API integration progresses
class ApiRepository {
  static ApiRepository? _instance;
  static ApiRepository get instance {
    _instance ??= ApiRepository._internal();
    return _instance!;
  }

  ApiRepository._internal();

  // Service instances
  final UserService _userService = UserService.instance;
  final StoreService _storeService = StoreService.instance;
  final InventoryService _inventoryService = InventoryService.instance;
  final SupplierService _supplierService = SupplierService.instance;
  final StockService _stockService = StockService.instance;

  // Feature flags to control API vs Mock data usage
  bool _useApiForUsers = false;
  bool _useApiForStores = false;
  bool _useApiForInventory = false;
  bool _useApiForSuppliers = false;
  bool _useApiForStock = false;
  bool _useApiForPurchases = false;
  bool _useApiForWaste = false;

  // Feature flag setters (for gradual migration)
  void enableApiForUsers() => _useApiForUsers = true;
  void enableApiForStores() => _useApiForStores = true;
  void enableApiForInventory() => _useApiForInventory = true;
  void enableApiForSuppliers() => _useApiForSuppliers = true;
  void enableApiForStock() => _useApiForStock = true;
  void enableApiForPurchases() => _useApiForPurchases = true;
  void enableApiForWaste() => _useApiForWaste = true;

  void enableAllApis() {
    _useApiForUsers = true;
    _useApiForStores = true;
    _useApiForInventory = true;
    _useApiForSuppliers = true;
    _useApiForStock = true;
    _useApiForPurchases = true;
    _useApiForWaste = true;
  }

  // User Management
  Future<List<AppUser>> getUsers({
    String? search,
    String? role,
    String? status,
  }) async {
    if (_useApiForUsers) {
      final result = await _userService.getAll(
        queryParams: ListQueryParams(
          search: search,
          filters: {
            if (role != null) 'role': role,
            if (status != null) 'status': status,
          },
        ),
      );
      return result.items;
    } else {
      // Filter mock data
      var users = MockRepository.appUsers;
      if (search != null && search.isNotEmpty) {
        users = users
            .where((u) =>
                u.name.toLowerCase().contains(search.toLowerCase()) ||
                u.email.toLowerCase().contains(search.toLowerCase()))
            .toList();
      }
      if (role != null) {
        users = users.where((u) => u.role == role).toList();
      }
      if (status != null) {
        users = users.where((u) => u.status == status).toList();
      }
      return users;
    }
  }

  Future<AppUser?> getUserById(String id) async {
    if (_useApiForUsers) {
      return await _userService.getById(id);
    } else {
      return MockRepository.appUsers.cast<AppUser?>().firstWhere(
            (u) => u!.id == id,
            orElse: () => null,
          );
    }
  }

  // Store Management
  Future<List<Store>> getStores({
    String? search,
    String? type,
    bool? active,
  }) async {
    if (_useApiForStores) {
      final result = await _storeService.getAll(
        queryParams: ListQueryParams(
          search: search,
          filters: {
            if (type != null) 'type': type,
            if (active != null) 'active': active,
          },
        ),
      );
      return result.items;
    } else {
      // Return mock store data (convert from store repository)
      return []; // TODO: Add mock stores when needed
    }
  }

  Future<Store?> getStoreById(String id) async {
    if (_useApiForStores) {
      return await _storeService.getById(id);
    } else {
      return null; // TODO: Add mock store lookup
    }
  }

  // Inventory Management
  Future<List<InventoryItem>> getInventoryItems({
    String? search,
    String? category,
    String? type,
  }) async {
    if (_useApiForInventory) {
      final result = await _inventoryService.getAll(
        queryParams: ListQueryParams(
          search: search,
          filters: {
            if (category != null) 'category': category,
            if (type != null) 'type': type,
          },
        ),
      );
      return result.items;
    } else {
      // Filter mock data
      var items = MockRepository.items;
      if (search != null && search.isNotEmpty) {
        items = items
            .where((item) =>
                item.name.toLowerCase().contains(search.toLowerCase()) ||
                item.category.toLowerCase().contains(search.toLowerCase()))
            .toList();
      }
      if (category != null) {
        items = items.where((item) => item.category == category).toList();
      }
      return items;
    }
  }

  Future<InventoryItem?> getInventoryItemById(String id) async {
    if (_useApiForInventory) {
      return await _inventoryService.getById(id);
    } else {
      return MockRepository.items.cast<InventoryItem?>().firstWhere(
            (item) => item!.id == id,
            orElse: () => null,
          );
    }
  }

  Future<InventoryItem> createInventoryItem(InventoryItem item) async {
    if (_useApiForInventory) {
      return await _inventoryService.create(item.toJson());
    } else {
      // For mock, add to MockRepository
      final newItem = item.copyWith(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
      );
      MockRepository.items.add(newItem);
      return newItem;
    }
  }

  Future<void> deleteInventoryItem(String id) async {
    if (_useApiForInventory) {
      await _inventoryService.delete(id);
    } else {
      MockRepository.items.removeWhere((item) => item.id == id);
    }
  }

  // Supplier Management
  Future<List<Supplier>> getSuppliers({
    String? search,
    String? status,
  }) async {
    if (_useApiForSuppliers) {
      final result = await _supplierService.getAll(
        queryParams: ListQueryParams(
          search: search,
          filters: {
            if (status != null) 'status': status,
          },
        ),
      );
      return result.items;
    } else {
      // Filter mock data
      var suppliers = MockRepository.suppliers;
      if (search != null && search.isNotEmpty) {
        suppliers = suppliers
            .where((s) =>
                s.name.toLowerCase().contains(search.toLowerCase()) ||
                s.company.toLowerCase().contains(search.toLowerCase()))
            .toList();
      }
      if (status != null) {
        suppliers = suppliers.where((s) => s.status == status).toList();
      }
      return suppliers;
    }
  }

  // Stock Management
  Future<List<StockItem>> getStockItems({
    String? storeId,
    StockCategory? category,
    String? search,
  }) async {
    if (_useApiForStock) {
      if (storeId != null) {
        final result = await _stockService.getByStore(
          storeId,
          queryParams: ListQueryParams(
            search: search,
            filters: {
              if (category != null) 'category': category.name,
            },
          ),
        );
        return result.items;
      } else {
        final result = await _stockService.getAll(
          queryParams: ListQueryParams(
            search: search,
            filters: {
              if (category != null) 'category': category.name,
            },
          ),
        );
        return result.items;
      }
    } else {
      // Use mock data
      List<StockItem> items = [];

      if (category == null || category == StockCategory.food) {
        items.addAll(MockRepository.foodStock);
      }
      if (category == null || category == StockCategory.catering) {
        items.addAll(MockRepository.cateringStock);
      }
      if (category == null || category == StockCategory.electronics) {
        items.addAll(MockRepository.electronicsStock);
      }

      // Apply search filter
      if (search != null && search.isNotEmpty) {
        items = items
            .where((item) =>
                item.name.toLowerCase().contains(search.toLowerCase()) ||
                item.category.toLowerCase().contains(search.toLowerCase()))
            .toList();
      }

      return items;
    }
  }

  Future<List<FoodStockItem>> getFoodStock({String? storeId}) async {
    if (_useApiForStock) {
      return await _stockService.getFoodStock(storeId: storeId);
    } else {
      return MockRepository.foodStock;
    }
  }

  Future<List<CateringStockItem>> getCateringStock({String? storeId}) async {
    if (_useApiForStock) {
      return await _stockService.getCateringStock(storeId: storeId);
    } else {
      return MockRepository.cateringStock;
    }
  }

  Future<List<ElectronicsStockItem>> getElectronicsStock(
      {String? storeId}) async {
    if (_useApiForStock) {
      return await _stockService.getElectronicsStock(storeId: storeId);
    } else {
      return MockRepository.electronicsStock;
    }
  }

  // Purchase Orders (still using mock for now)
  List<PurchaseRecord> getPurchaseRecords() {
    return MockRepository.purchases;
  }

  // Stock Movements
  Future<List<StockMovementEntry>> getStockMovements({
    String? storeId,
    String? itemId,
  }) async {
    if (_useApiForStock) {
      final result = await _stockService.getStockMovements(
        storeId: storeId,
        itemId: itemId,
      );
      return result.items;
    } else {
      return MockRepository.stockMovements;
    }
  }

  // Waste Records (still using mock for now)
  List<WasteRecord> getWasteRecords() {
    return MockRepository.wasteRecords;
  }

  // Expiry Items (still using mock for now)
  List<ExpiryItem> getExpiryItems() {
    return MockRepository.expiryItems;
  }

  // Recipes (still using mock for now)
  List<RecipeItem> getRecipeItems() {
    return MockRepository.recipeItems;
  }

  // Alerts (still using mock for now)
  List<AlertItem> getAlerts() {
    return MockRepository.alerts;
  }

  // Utility methods for compatibility with existing screens
  static List<InventoryItem> get items => MockRepository.items;
  static List<Supplier> get suppliers => MockRepository.suppliers;
  static List<PurchaseRecord> get purchases => MockRepository.purchases;
  static List<StockMovement> get movements => MockRepository.movements;
  static List<Recipe> get recipes => MockRepository.recipes;
  static List<AlertItem> get alerts => MockRepository.alerts;
  static List<RecipeItem> get recipeItems => MockRepository.recipeItems;
  static List<WasteRecord> get wasteRecords => MockRepository.wasteRecords;
  static List<ExpiryItem> get expiryItems => MockRepository.expiryItems;
  static List<AppUser> get appUsers => MockRepository.appUsers;
  static List<FoodStockItem> get foodStock => MockRepository.foodStock;
  static List<CateringStockItem> get cateringStock =>
      MockRepository.cateringStock;
  static List<ElectronicsStockItem> get electronicsStock =>
      MockRepository.electronicsStock;
  static List<StockMovementEntry> get stockMovements =>
      MockRepository.stockMovements;
}
