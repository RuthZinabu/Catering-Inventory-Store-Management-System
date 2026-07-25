class KitchenIssueViewModel {
  String number;
  String department;
  String kitchen;
  String requestedBy;
  String approvedBy;
  String issueDate;
  String status;
  int itemsIssued;
  int totalQuantity;
  List<KitchenIssueIngredientViewModel> ingredients;

  KitchenIssueViewModel({
    required this.number,
    required this.department,
    required this.kitchen,
    required this.requestedBy,
    required this.approvedBy,
    required this.issueDate,
    required this.status,
    required this.itemsIssued,
    required this.totalQuantity,
    required this.ingredients,
  });
}

class KitchenIssueIngredientViewModel {
  String name;
  String category;
  String unit;
  int availableStock;
  int quantity;

  KitchenIssueIngredientViewModel({
    required this.name,
    required this.category,
    required this.unit,
    required this.availableStock,
    required this.quantity,
  });
}
