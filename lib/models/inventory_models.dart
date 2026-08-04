class InventoryItem {
  final String id;
  final String code;
  final String name;
  final String category;
  final String unit;
  final double purchasePrice;
  final double internalCost;
  final int minStock;
  final int maxStock;
  final String description;
  final int stockOnHand;
  final int reorderPoint;
  final String status;

  const InventoryItem({
    required this.id,
    required this.code,
    required this.name,
    required this.category,
    required this.unit,
    required this.purchasePrice,
    required this.internalCost,
    required this.minStock,
    required this.maxStock,
    required this.description,
    required this.stockOnHand,
    required this.reorderPoint,
    required this.status,
  });
}

class Supplier {
  final String id;
  final String name;
  final String company;
  final String contactPerson;
  final String phone;
  final String email;
  final String address;
  final String taxNumber;
  final String status;
  final double outstandingBalance;

  const Supplier({
    required this.id,
    required this.name,
    required this.company,
    required this.contactPerson,
    required this.phone,
    required this.email,
    required this.address,
    required this.taxNumber,
    required this.status,
    required this.outstandingBalance,
  });
}

class PurchaseRecord {
  final String id;
  final String number;
  final String supplier;
  final DateTime date;
  final String item;
  final int quantity;
  final double unitPrice;
  final double vat;
  final double discount;
  final double total;

  const PurchaseRecord({
    required this.id,
    required this.number,
    required this.supplier,
    required this.date,
    required this.item,
    required this.quantity,
    required this.unitPrice,
    required this.vat,
    required this.discount,
    required this.total,
  });
}

class StockMovement {
  final String id;
  final String item;
  final String type;
  final int quantity;
  final DateTime date;
  final String note;

  const StockMovement({
    required this.id,
    required this.item,
    required this.type,
    required this.quantity,
    required this.date,
    required this.note,
  });
}

class Recipe {
  final String id;
  final String name;
  final String description;
  final List<String> ingredients;
  final double foodCost;

  const Recipe({
    required this.id,
    required this.name,
    required this.description,
    required this.ingredients,
    required this.foodCost,
  });
}

class AlertItem {
  final String id;
  final String title;
  final String detail;
  final DateTime date;
  final String severity;

  const AlertItem({
    required this.id,
    required this.title,
    required this.detail,
    required this.date,
    required this.severity,
  });
}

class WasteRecord {
  final String id;
  final String number;
  final String item;
  final String category;
  final String unit;
  final double quantity;
  final double estimatedCost;
  final String reason;
  final String recordedBy;
  final DateTime date;
  final String status;
  final String notes;

  const WasteRecord({
    required this.id,
    required this.number,
    required this.item,
    required this.category,
    required this.unit,
    required this.quantity,
    required this.estimatedCost,
    required this.reason,
    required this.recordedBy,
    required this.date,
    required this.status,
    required this.notes,
  });
}

class ExpiryItem {
  final String id;
  final String item;
  final String category;
  final String unit;
  final double quantity;
  final DateTime expiryDate;
  final String batchNumber;
  final String location;
  final String status; // 'Expired', 'Expiring Soon', 'OK'

  const ExpiryItem({
    required this.id,
    required this.item,
    required this.category,
    required this.unit,
    required this.quantity,
    required this.expiryDate,
    required this.batchNumber,
    required this.location,
    required this.status,
  });
}

class AppUser {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String department;
  final String status; // 'Active', 'Inactive', 'Suspended'
  final DateTime createdAt;
  final String lastLogin;
  final List<String> permissions;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.department,
    required this.status,
    required this.createdAt,
    required this.lastLogin,
    required this.permissions,
  });
}

class RecipeIngredient {
  final String name;
  final double quantity;
  final String unit;
  final double unitCost;

  const RecipeIngredient({
    required this.name,
    required this.quantity,
    required this.unit,
    required this.unitCost,
  });

  double get totalCost => quantity * unitCost;
}

class RecipeItem {
  final String id;
  final String name;
  final String category;
  final String description;
  final int servings;
  final List<RecipeIngredient> ingredients;
  final double sellingPrice;
  final String prepTime;
  final String status; // 'Active', 'Inactive'

  const RecipeItem({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.servings,
    required this.ingredients,
    required this.sellingPrice,
    required this.prepTime,
    required this.status,
  });

  double get totalFoodCost =>
      ingredients.fold(0, (sum, i) => sum + i.totalCost);

  double get foodCostPercentage =>
      sellingPrice > 0 ? (totalFoodCost / sellingPrice) * 100 : 0;
}
