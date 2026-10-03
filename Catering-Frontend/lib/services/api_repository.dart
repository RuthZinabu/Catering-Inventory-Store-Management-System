import 'package:catering_inventory_store_management_system/services/api/base_api_service.dart';

import '../models/inventory_models.dart';
import '../models/stock_models.dart';
import '../models/store_model.dart';
import 'user_service.dart';
import 'store_service.dart';
import 'inventory_service.dart';
import 'supplier_service.dart';
import 'stock_service.dart';
import 'waste_service.dart';
import 'recipe_service.dart';

/// Main repository that coordinates API services for all data operations
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
  final WasteService _wasteService = WasteService.instance;
  final RecipeService _recipeService = RecipeService();

  // User Management
  Future<List<AppUser>> getUsers({
    String? search,
    String? role,
    String? status,
  }) async {
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
  }

  Future<AppUser?> getUserById(String id) async {
    return await _userService.getById(id);
  }

  Future<AppUser> createUser(Map<String, dynamic> data) async {
    return await _userService.create(data);
  }

  Future<AppUser> updateUser(String id, Map<String, dynamic> data) async {
    return await _userService.update(id, data);
  }

  Future<void> deleteUser(String id) async {
    await _userService.delete(id);
  }

  // Store Management
  Future<List<Store>> getStores({
    String? search,
    String? type,
    bool? active,
  }) async {
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
  }

  Future<Store?> getStoreById(String id) async {
    return await _storeService.getById(id);
  }

  // Inventory Management
  Future<List<InventoryItem>> getInventoryItems({
    String? search,
    String? category,
    String? type,
  }) async {
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
  }

  Future<InventoryItem?> getInventoryItemById(String id) async {
    return await _inventoryService.getById(id);
  }

  Future<InventoryItem> createInventoryItem(InventoryItem item) async {
    return await _inventoryService.create(item.toJson());
  }

  Future<void> deleteInventoryItem(String id) async {
    await _inventoryService.delete(id);
  }

  // Supplier Management
  Future<List<Supplier>> getSuppliers({
    String? search,
    String? status,
  }) async {
    final result = await _supplierService.getAll(
      queryParams: ListQueryParams(
        search: search,
        filters: {
          if (status != null) 'status': status,
        },
      ),
    );
    return result.items;
  }

  // Stock Management
  Future<List<StockItem>> getStockItems({
    String? storeId,
    StockCategory? category,
    String? search,
  }) async {
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
  }

  Future<StockItem> createNewStockItemInStore(
    String storeId,
    Map<String, dynamic> data,
  ) {
    return _stockService.createNewItemInStore(storeId, data);
  }

  Future<List<FoodStockItem>> getFoodStock({String? storeId}) async {
    return await _stockService.getFoodStock(storeId: storeId);
  }

  Future<List<CateringStockItem>> getCateringStock({String? storeId}) async {
    return await _stockService.getCateringStock(storeId: storeId);
  }

  Future<List<ElectronicsStockItem>> getElectronicsStock(
      {String? storeId}) async {
    return await _stockService.getElectronicsStock(storeId: storeId);
  }

  // Purchase Orders - TODO: Implement API endpoints
  Future<List<PurchaseRecord>> getPurchaseRecords() async {
    // This will need to be implemented when purchase order API is available
    return [];
  }

  // Stock Movements
  Future<List<StockMovementEntry>> getStockMovements({
    String? storeId,
    String? itemId,
  }) async {
    final result = await _stockService.getStockMovements(
      storeId: storeId,
      itemId: itemId,
    );
    return result.items;
  }

  // Waste Records
  Future<List<WasteRecord>> getWasteRecords() async {
    return await _wasteService.getAll();
  }

  Future<WasteRecord> createWasteRecord(Map<String, dynamic> data) async {
    return await _wasteService.create(data);
  }

  Future<WasteRecord> updateWasteRecord(
      String id, Map<String, dynamic> data) async {
    return await _wasteService.update(id, data);
  }

  // Expiry Items - TODO: Implement API endpoints
  Future<List<ExpiryItem>> getExpiryItems() async {
    // This will need to be implemented when expiry API is available
    return [];
  }

  // Recipes
  Future<List<RecipeItem>> getRecipeItems() async {
    final result = await _recipeService.getAll();
    return result.items;
  }

  Future<RecipeItem> createRecipe(Map<String, dynamic> data) async {
    return _recipeService.create(data);
  }

  Future<RecipeItem> updateRecipe(String id, Map<String, dynamic> data) async {
    return _recipeService.update(id, data);
  }

  // Alerts - TODO: Implement API endpoints
  Future<List<AlertItem>> getAlerts() async {
    // This will need to be implemented when alerts API is available
    return [];
  }
}
