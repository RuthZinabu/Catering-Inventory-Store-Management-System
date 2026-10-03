# JSON Parsing Fix for Flutter Models

## Problem
Flutter was receiving a runtime error when fetching items from the Laravel API:
```
ApiException: Failed to fetch items: TypeError: '280.00' type 'String' is not a subtype of type 'num'
```

## Root Cause
Laravel was returning decimal values as strings (e.g., `"280.00"`) due to the `decimal:2` casting in the Laravel models, but Flutter's generated JSON deserialization was expecting numeric types and failing with `(json['field'] as num).toDouble()`.

## Solution
1. **Added Robust Parsing Functions**: Created helper functions that can parse both string and numeric values:
   - `_parseDouble()` - converts strings like "280.00" to 280.0
   - `_parseDoubleOptional()` - handles nullable decimal fields  
   - `_parseInt()` - converts string numbers to integers
   - `_parseIntOptional()` - handles nullable integer fields
   - `_parseBoolOptional()` - handles nullable boolean fields

2. **Updated Model Fields**: Modified `inventory_models.dart` to use custom parsing:
   ```dart
   @JsonKey(name: 'default_purchase_price', fromJson: _parseDouble)
   final double purchasePrice;
   
   @JsonKey(name: 'internal_cost', fromJson: _parseDoubleOptional)
   final double? internalCost;
   ```

3. **Made Fields Optional**: Since the Flutter `InventoryItem` model expected fields that don't exist in the Laravel `Item` model (like `internal_cost`, `min_stock`, `max_stock`), made them nullable with sensible defaults.

4. **Added Computed Properties**: Created fallback properties for UI compatibility:
   ```dart
   String get status => isActive == true ? 'Active' : 'Inactive';
   int get minStockValue => minStock ?? 0;
   int get stockOnHandValue => stockOnHand ?? 0;
   double get internalCostValue => internalCost ?? purchasePrice;
   ```

## Files Modified
- `lib/models/inventory_models.dart` - Updated model definitions with custom parsing
- `lib/models/inventory_models.g.dart` - Updated generated JSON serialization code
- `lib/screens/dashboard_screen.dart` - Updated status checking logic

## Testing
Created and ran test cases that verify:
- ✅ String decimals like "280.00" parse correctly to 280.0
- ✅ Numeric values work as expected (150.75 → 150.75)
- ✅ Null values are handled gracefully (null → 0.0)
- ✅ Optional fields work with missing data

## API Compatibility
The fix maintains compatibility with:
- Laravel API responses (handles string decimals)
- Future numeric responses (handles actual numbers)
- Missing fields (graceful degradation)
- Both Flutter Web and Mobile platforms

## Next Steps
1. Test the actual Flutter app login and item fetching
2. Verify inventory list displays correctly
3. Check that all UI components work with the new model structure
4. Consider updating Laravel to return consistent numeric types if preferred