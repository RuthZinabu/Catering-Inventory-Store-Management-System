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
