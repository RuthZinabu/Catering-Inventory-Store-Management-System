import 'package:catering_inventory_store_management_system/services/api/base_api_service.dart';

import '../models/inventory_models.dart';
import '../models/stock_models.dart';
import '../models/store_model.dart';
import '../screens/stock_transfers/stock_transfer_models.dart';
import '../screens/kitchen_issues/kitchen_issue_models.dart';
import 'user_service.dart';
import 'store_service.dart';
import 'inventory_service.dart';
import 'supplier_service.dart';
import 'stock_service.dart';
import 'waste_service.dart';
import 'recipe_service.dart';
import 'transfer_service.dart';
import 'kitchen_issue_service.dart';
import 'api_service.dart' as direct_api;

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
  final TransferService _transferService = TransferService.instance;
  final KitchenIssueService _kitchenIssueService = KitchenIssueService.instance;

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

  Future<List<Map<String, dynamic>>> getUserActivities(String id) async {
    return _userService.getActivities(id);
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

  Future<List<Store>> getAllActiveStores() async {
    return _getAllPages<Store>(
      (page) => _storeService.getAll(
        queryParams: ListQueryParams(
          page: page,
          perPage: 100,
          filters: const {'active': true},
        ),
      ),
    );
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

  Future<List<InventoryItem>> searchInventoryItems(String barcode) {
    return _inventoryService.search(barcode, limit: 50).then(
          (items) => items.where((item) => item.code == barcode).toList(),
        );
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

  Future<List<Supplier>> getAllActiveSuppliers() async {
    return _getAllPages<Supplier>(
      (page) => _supplierService.getAll(
        queryParams: ListQueryParams(
          page: page,
          perPage: 100,
          filters: const {'status': 'Active'},
        ),
      ),
    );
  }

  Future<List<T>> _getAllPages<T>(
    Future<PaginatedResult<T>> Function(int page) fetchPage,
  ) async {
    final items = <T>[];
    var page = 1;
    var lastPage = 1;

    do {
      final result = await fetchPage(page);
      items.addAll(result.items);
      lastPage = result.lastPage;
      page++;
    } while (page <= lastPage);

    return items;
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
            if (category != null) 'item_type': category.name,
          },
        ),
      );
      return result.items;
    } else {
      final result = await _stockService.getAll(
        queryParams: ListQueryParams(
          search: search,
          filters: {
            if (category != null) 'item_type': category.name,
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

  Future<List<FoodStockItem>> getFoodStockPaginated({
    String? storeId,
    int page = 1,
    int perPage = 15,
  }) async {
    return await _stockService.getFoodStockPaginated(
      storeId: storeId,
      page: page,
      perPage: perPage,
    );
  }

  Future<List<CateringStockItem>> getCateringStock({String? storeId}) async {
    return await _stockService.getCateringStock(storeId: storeId);
  }

  Future<List<CateringStockItem>> getCateringStockPaginated({
    String? storeId,
    int page = 1,
    int perPage = 15,
  }) async {
    return await _stockService.getCateringStockPaginated(
      storeId: storeId,
      page: page,
      perPage: perPage,
    );
  }

  Future<List<ElectronicsStockItem>> getElectronicsStock(
      {String? storeId}) async {
    return await _stockService.getElectronicsStock(storeId: storeId);
  }

  Future<List<ElectronicsStockItem>> getElectronicsStockPaginated({
    String? storeId,
    int page = 1,
    int perPage = 15,
  }) async {
    return await _stockService.getElectronicsStockPaginated(
      storeId: storeId,
      page: page,
      perPage: perPage,
    );
  }

  // Stock Transfers
  Future<List<StockTransferViewModel>> getStockTransfers() {
    return _transferService.getAll();
  }

  Future<List<TransferStockItemViewModel>> getTransferStock(String storeId) {
    return _transferService.getStock(storeId);
  }

  Future<StockTransferViewModel> createStockTransfer(
      Map<String, dynamic> data) {
    return _transferService.create(data);
  }

  Future<void> approveStockTransfer(String id) => _transferService.approve(id);
  Future<void> shipStockTransfer(String id) => _transferService.ship(id);
  Future<void> receiveStockTransfer(String id, {String? notes}) =>
      _transferService.receive(id, notes: notes);
  Future<void> cancelStockTransfer(String id) => _transferService.cancel(id);

  // Kitchen Issues
  Future<List<KitchenIssueViewModel>> getKitchenIssues() =>
      _kitchenIssueService.getAll();

  Future<List<KitchenIssueIngredientViewModel>> getKitchenIssueStock(
    String storeId,
  ) =>
      _kitchenIssueService.getStoreStock(storeId);

  Future<KitchenIssueViewModel> createKitchenIssue(Map<String, dynamic> data) =>
      _kitchenIssueService.create(data);

  Future<void> approveKitchenIssue(String id, {String? notes}) =>
      _kitchenIssueService.approve(id, notes: notes);

  Future<void> issueKitchenIssue(String id) => _kitchenIssueService.issue(id);

  Future<void> cancelKitchenIssue(String id) => _kitchenIssueService.cancel(id);

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

  // Expiry Items
  Future<List<ExpiryItem>> getExpiryItems() async {
    final storeId = direct_api.ApiClient.instance.storeId;
    if (storeId == null) {
      throw StateError('Select a store before loading expiry batches.');
    }
    final path = Uri(
      path: '/inventory-batches',
      queryParameters: {'store_id': storeId, 'per_page': '100'},
    ).toString();
    final response = await direct_api.ApiClient.instance.get(path);
    final data = Map<String, dynamic>.from(response['data'] as Map);
    return (data['items'] as List? ?? const [])
        .map((item) =>
            ExpiryItem.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  Future<ExpiryItem> createInventoryBatch(Map<String, dynamic> data) async {
    final response =
        await direct_api.ApiClient.instance.post('/inventory-batches', data);
    return ExpiryItem.fromJson(
        Map<String, dynamic>.from(response['data'] as Map));
  }

  Future<ExpiryItem> updateInventoryBatch(
      String id, Map<String, dynamic> data) async {
    final response =
        await direct_api.ApiClient.instance.put('/inventory-batches/$id', data);
    return ExpiryItem.fromJson(
        Map<String, dynamic>.from(response['data'] as Map));
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
