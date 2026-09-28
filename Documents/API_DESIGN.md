# API Design Document
**Catering Inventory Store Management System**

## Overview
This document defines the Laravel API architecture for the catering inventory management system, based on analysis of the Flutter frontend requirements and database design.

---

## 1. API Architecture Principles

### 1.1 Laravel Framework Structure
```
app/
├── Models/           # Eloquent models matching database schema
├── Http/
│   ├── Controllers/  # API controllers (resourceful + custom actions)
│   ├── Requests/     # Form request validation
│   ├── Resources/    # API resource transformations
│   └── Middleware/   # Authentication, authorization, CORS
├── Services/         # Business logic services
├── Repositories/     # Data access layer (optional)
└── Events/           # Domain events for audit trails
```

### 1.2 API Design Standards
- **RESTful principles** with Laravel conventions
- **JSON API responses** with consistent structure
- **UUID primary keys** for all entities
- **Soft deletes** for data integrity
- **API versioning** via URL prefix (`/api/v1/`)
- **Rate limiting** and authentication middleware

---

## 2. Authentication & Authorization

### 2.1 Authentication System
```php
// Laravel Sanctum for SPA authentication
POST /api/v1/auth/login
POST /api/v1/auth/logout
POST /api/v1/auth/refresh
GET  /api/v1/auth/user
POST /api/v1/auth/forgot-password
POST /api/v1/auth/reset-password
```

### 2.2 Authorization Middleware
```php
// Custom middleware for permission-based access
class CheckPermission extends Middleware {
    // Check user permissions: inventory, suppliers, purchases, etc.
    // Allow role-based and permission-based access control
}

// Usage in routes
Route::middleware(['auth:sanctum', 'permission:inventory'])->group(function() {
    // Stock management routes
});
```

---

## 3. Core Entity APIs

### 3.1 Users Management
```php
GET    /api/v1/users                    # List users with filters
GET    /api/v1/users/{id}               # Get user profile
POST   /api/v1/users                    # Create user
PUT    /api/v1/users/{id}               # Update user
DELETE /api/v1/users/{id}               # Soft delete user
PATCH  /api/v1/users/{id}/status        # Change user status
GET    /api/v1/users/permissions        # List available permissions
GET    /api/v1/users/roles              # List available roles

// Response format
{
    "data": {
        "id": "uuid",
        "name": "string",
        "email": "string",
        "role": "string",
        "department": "string", 
        "status": "Active|Inactive|Suspended",
        "permissions": ["inventory", "suppliers"],
        "last_login_at": "datetime",
        "created_at": "datetime"
    }
}
```

### 3.2 Stock Items Management
```php
GET    /api/v1/stock/items              # List items with filters
GET    /api/v1/stock/items/{id}         # Get item details
POST   /api/v1/stock/items              # Create item
PUT    /api/v1/stock/items/{id}         # Update item
DELETE /api/v1/stock/items/{id}         # Soft delete item
PATCH  /api/v1/stock/items/{id}/quantity # Update quantity (creates movement)

// Category-specific endpoints
GET    /api/v1/stock/food               # Food items only
GET    /api/v1/stock/catering           # Catering items only  
GET    /api/v1/stock/electronics        # Electronics items only

// Bulk operations
POST   /api/v1/stock/items/bulk         # Bulk create/update
PATCH  /api/v1/stock/items/bulk-status  # Bulk status update

// Query parameters for filtering
?category=Meat&status=Low+Stock&store_id=uuid&search=chicken
?expiring_within=7               # Days until expiry
?maintenance_due=true            # Electronics maintenance due
?reserved=true                   # Catering items reserved
```

### 3.3 Stock Movements
```php
GET    /api/v1/stock/movements          # List movements with filters
POST   /api/v1/stock/movements          # Record manual movement
GET    /api/v1/stock/movements/item/{id} # Movements for specific item
GET    /api/v1/stock/movements/audit    # Audit trail report

// Movement types: 'Stock In', 'Stock Out', 'Transfer', 'Adjustment', 'Return'
POST /api/v1/stock/movements/transfer   # Inter-store transfer
POST /api/v1/stock/movements/adjustment # Stock adjustment

// Response includes before/after quantities for audit trail
{
    "data": {
        "id": "uuid",
        "stock_item": {...},
        "type": "Stock In",
        "quantity": 50,
        "quantity_before": 10,
        "quantity_after": 60,
        "performed_by": {...},
        "note": "string",
        "created_at": "datetime"
    }
}
```

### 3.4 Suppliers Management
```php
GET    /api/v1/suppliers               # List suppliers
GET    /api/v1/suppliers/{id}          # Supplier details
POST   /api/v1/suppliers               # Create supplier
PUT    /api/v1/suppliers/{id}          # Update supplier
DELETE /api/v1/suppliers/{id}          # Soft delete supplier

GET    /api/v1/suppliers/{id}/items    # Items from this supplier
GET    /api/v1/suppliers/{id}/orders   # Purchase orders from supplier
GET    /api/v1/suppliers/performance   # Supplier performance metrics
```

### 3.5 Purchase Orders Management
```php
GET    /api/v1/purchase-orders         # List purchase orders
GET    /api/v1/purchase-orders/{id}    # Purchase order details  
POST   /api/v1/purchase-orders         # Create purchase order
PUT    /api/v1/purchase-orders/{id}    # Update purchase order
DELETE /api/v1/purchase-orders/{id}    # Cancel purchase order

// Purchase order workflow
POST   /api/v1/purchase-orders/{id}/approve   # Approve order
POST   /api/v1/purchase-orders/{id}/receive   # Goods receiving
POST   /api/v1/purchase-orders/{id}/return    # Process return
GET    /api/v1/purchase-orders/{id}/invoice   # Generate invoice PDF

// Purchase order items (nested resource)
GET    /api/v1/purchase-orders/{id}/items     # List order items
POST   /api/v1/purchase-orders/{id}/items     # Add item to order
PUT    /api/v1/purchase-orders/{id}/items/{itemId} # Update item
DELETE /api/v1/purchase-orders/{id}/items/{itemId} # Remove item
```

### 3.6 Recipes Management  
```php
GET    /api/v1/recipes                 # List recipes
GET    /api/v1/recipes/{id}            # Recipe details with costing
POST   /api/v1/recipes                 # Create recipe
PUT    /api/v1/recipes/{id}            # Update recipe
DELETE /api/v1/recipes/{id}            # Soft delete recipe

// Recipe ingredients (nested resource)
GET    /api/v1/recipes/{id}/ingredients # List ingredients
POST   /api/v1/recipes/{id}/ingredients # Add ingredient
PUT    /api/v1/recipes/{id}/ingredients/{ingredientId} # Update ingredient
DELETE /api/v1/recipes/{id}/ingredients/{ingredientId} # Remove ingredient

// Recipe costing and analysis
GET    /api/v1/recipes/{id}/costing    # Detailed cost breakdown
POST   /api/v1/recipes/{id}/recalculate # Recalculate costs from current prices
```

### 3.7 Waste Management
```php
GET    /api/v1/waste-records           # List waste records
GET    /api/v1/waste-records/{id}      # Waste record details
POST   /api/v1/waste-records           # Create waste record
PUT    /api/v1/waste-records/{id}      # Update waste record  
DELETE /api/v1/waste-records/{id}      # Delete waste record

PATCH  /api/v1/waste-records/{id}/approve # Approve waste record
PATCH  /api/v1/waste-records/{id}/reject  # Reject waste record

GET    /api/v1/waste-records/analytics # Waste analysis and reports
```

### 3.8 Stores Management
```php
GET    /api/v1/stores                  # List stores
GET    /api/v1/stores/{id}             # Store details
POST   /api/v1/stores                  # Create store
PUT    /api/v1/stores/{id}             # Update store
DELETE /api/v1/stores/{id}             # Soft delete store

GET    /api/v1/stores/{id}/inventory   # Store inventory
GET    /api/v1/stores/{id}/movements   # Store movement history
POST   /api/v1/stores/transfer         # Inter-store transfer
```

---

## 4. Dashboard & Analytics APIs

### 4.1 Dashboard KPIs
```php
GET /api/v1/dashboard/kpis
// Response
{
    "data": {
        "total_stock_items": 1284,
        "total_inventory_value": 48200.00,
        "low_stock_count": 23,
        "expiring_soon_count": 15,
        "recent_movements_count": 47,
        "pending_purchases_count": 8,
        "trends": {
            "inventory_value_change": "+3.2%",
            "stock_movements_change": "-8%"
        }
    }
}
```

### 4.2 Reports APIs
```php
GET /api/v1/reports/stock              # Stock reports
GET /api/v1/reports/purchases          # Purchase reports  
GET /api/v1/reports/waste              # Waste analysis
GET /api/v1/reports/expiry             # Expiry tracking
GET /api/v1/reports/consumption        # Consumption analysis
GET /api/v1/reports/suppliers          # Supplier performance

// Export capabilities
GET /api/v1/reports/{type}/export?format=pdf|excel|csv
```

### 4.3 Alerts System
```php
GET    /api/v1/alerts                  # User's alerts
GET    /api/v1/alerts/unread           # Unread alerts count
PATCH  /api/v1/alerts/{id}/read        # Mark as read
PATCH  /api/v1/alerts/{id}/resolve     # Mark as resolved
DELETE /api/v1/alerts/{id}             # Dismiss alert

POST   /api/v1/alerts/batch-read       # Mark multiple as read
```

---

## 5. Request/Response Formats

### 5.1 Standard Response Structure
```php
// Success Response
{
    "data": {
        // Entity data or collection
    },
    "meta": {
        "current_page": 1,
        "total": 150,
        "per_page": 20,
        "last_page": 8
    },
    "links": {
        "first": "url",
        "last": "url", 
        "next": "url",
        "prev": null
    }
}

// Error Response
{
    "error": {
        "code": "VALIDATION_ERROR",
        "message": "The given data was invalid.",
        "details": {
            "name": ["The name field is required."],
            "email": ["The email must be valid."]
        }
    }
}
```

### 5.2 Stock Item Request Format
```php
// Create/Update Stock Item
{
    "code": "FS-001",
    "name": "Chicken Breast", 
    "description": "Fresh boneless chicken",
    "category": "Meat",
    "stock_category": "food",
    "unit": "Kg",
    "purchase_price": 135.00,
    "quantity": 50.0,
    "min_quantity": 20.0,
    "max_quantity": 120.0,
    "supplier_id": "uuid",
    "store_id": "uuid",
    
    // Food-specific
    "expiry_date": "2026-08-05",
    "batch_number": "BT-CH01",
    "requires_refrigeration": true,
    
    // Catering-specific  
    "catering_subtype": "permanent",
    "condition": "Good",
    "is_reserved": false,
    
    // Electronics-specific
    "brand": "Samsung",
    "model": "ABC123",
    "serial_number": "SN001",
    "asset_tag": "AT001",
    "warranty_expiry": "2028-01-01"
}
```

### 5.3 Purchase Order Request Format
```php
{
    "supplier_id": "uuid",
    "order_date": "2026-07-24",
    "expected_delivery_date": "2026-07-30",
    "notes": "Urgent order for weekend event",
    "items": [
        {
            "stock_item_id": "uuid",
            "quantity": 50,
            "unit_price": 135.00
        },
        {
            "stock_item_id": "uuid", 
            "quantity": 25,
            "unit_price": 95.00
        }
    ]
}
```

---

## 6. Laravel Services Architecture

### 6.1 Service Layer Pattern
```php
// app/Services/StockService.php
class StockService {
    public function updateQuantity(StockItem $item, float $newQuantity, string $reason): void
    {
        // Create stock movement record
        // Update item quantity
        // Recalculate status
        // Generate alerts if needed
        // Dispatch events for audit trail
    }
    
    public function processReceiving(PurchaseOrder $po, array $receivingData): void
    {
        // Update purchase order items
        // Create stock movements
        // Update stock quantities
        // Update purchase order status
    }
}

// app/Services/RecipeService.php  
class RecipeService {
    public function recalculateCosting(Recipe $recipe): void
    {
        // Recalculate ingredient costs from current stock prices
        // Update cached totals and percentages
        // Generate alerts for high cost percentages
    }
}
```

### 6.2 Event-Driven Architecture
```php
// Domain Events
class StockQuantityUpdated extends Event {
    public function __construct(
        public StockItem $item,
        public float $oldQuantity,
        public float $newQuantity
    ) {}
}

// Event Listeners
class CheckLowStockAlert extends Listener {
    public function handle(StockQuantityUpdated $event): void
    {
        // Generate low stock alert if needed
        // Update stock status
    }
}

class UpdateRecipeCosts extends Listener {
    public function handle(StockQuantityUpdated $event): void
    {
        // Find recipes using this ingredient
        // Recalculate recipe costs if price changed
    }
}
```

### 6.3 Repository Pattern (Optional)
```php
// app/Repositories/StockItemRepository.php
interface StockItemRepositoryInterface {
    public function findWithFilters(array $filters): Collection;
    public function findLowStock(): Collection;
    public function findExpiringSoon(int $days = 7): Collection;
}

class StockItemRepository implements StockItemRepositoryInterface {
    // Complex query logic
    // Database-specific optimizations
    // Caching layer
}
```

---

## 7. Validation & Business Rules

### 7.1 Form Request Validation
```php
// app/Http/Requests/StoreStockItemRequest.php
class StoreStockItemRequest extends FormRequest {
    public function rules(): array {
        return [
            'code' => 'required|string|unique:stock_items|max:100',
            'name' => 'required|string|max:255',
            'stock_category' => 'required|in:food,catering,electronics',
            'quantity' => 'required|numeric|min:0',
            'min_quantity' => 'required|numeric|min:0',
            'max_quantity' => 'required|numeric|gte:min_quantity',
            'purchase_price' => 'required|numeric|min:0',
            
            // Conditional validation based on stock_category
            'expiry_date' => 'required_if:stock_category,food|date|after:today',
            'batch_number' => 'required_if:stock_category,food|string',
            'brand' => 'required_if:stock_category,electronics|string',
            'serial_number' => 'required_if:stock_category,electronics|string|unique:stock_items',
        ];
    }
}
```

### 7.2 Business Rule Validation
```php
// Custom validation rules
class ValidStockMovement implements Rule {
    public function passes($attribute, $value): bool
    {
        // Validate that stock movement doesn't create negative quantities
        // Check movement permissions for user
        // Validate transfer between valid stores
    }
}

// Model observers for business rules
class StockItemObserver {
    public function updating(StockItem $item): void
    {
        // Prevent direct quantity updates (must go through movements)
        // Recalculate status based on new quantities
        // Validate stock category changes
    }
}
```

---

## 8. Caching Strategy

### 8.1 Query Caching
```php
// Dashboard KPIs with 5-minute cache
Cache::remember('dashboard.kpis', 300, function() {
    return [
        'total_items' => StockItem::count(),
        'total_value' => StockItem::sum(DB::raw('quantity * purchase_price')),
        'low_stock_count' => StockItem::where('status', 'Low Stock')->count(),
    ];
});

// Stock item lookup with tags for invalidation
Cache::tags(['stock_items'])->remember("stock_item.{$id}", 3600, function() use ($id) {
    return StockItem::with(['supplier', 'store'])->find($id);
});
```

### 8.2 Cache Invalidation
```php
// Clear relevant caches when stock items change
class InvalidateStockCaches extends Listener {
    public function handle(StockQuantityUpdated $event): void
    {
        Cache::tags(['stock_items', 'dashboard'])->flush();
        Cache::forget("stock_item.{$event->item->id}");
    }
}
```

---

## 9. Error Handling

### 9.1 Exception Handling
```php
// app/Exceptions/BusinessRuleException.php
class BusinessRuleException extends Exception {
    public static function insufficientStock(StockItem $item): self
    {
        return new self("Insufficient stock for {$item->name}. Available: {$item->quantity}");
    }
}

// app/Exceptions/Handler.php
class Handler extends ExceptionHandler {
    public function render($request, Throwable $exception)
    {
        if ($exception instanceof BusinessRuleException) {
            return response()->json([
                'error' => [
                    'code' => 'BUSINESS_RULE_VIOLATION',
                    'message' => $exception->getMessage()
                ]
            ], 422);
        }
        
        return parent::render($request, $exception);
    }
}
```

### 9.2 API Response Codes
```php
200 OK           - Successful GET, PUT, PATCH
201 Created      - Successful POST
204 No Content   - Successful DELETE
400 Bad Request  - Invalid request format
401 Unauthorized - Authentication required
403 Forbidden    - Insufficient permissions  
404 Not Found    - Resource not found
422 Unprocessable Entity - Validation errors
429 Too Many Requests - Rate limit exceeded
500 Internal Server Error - Server error
```

---

## 10. File Upload & Asset Management

### 10.1 File Storage (UNKNOWN Requirements)
```php
// If image/file upload is needed (not detected in Flutter frontend)
POST /api/v1/stock/items/{id}/image    # Upload item image
POST /api/v1/users/{id}/avatar         # Upload user avatar  
POST /api/v1/waste-records/{id}/evidence # Upload waste evidence

// File handling service
class FileService {
    public function storeStockItemImage(StockItem $item, UploadedFile $file): string
    {
        // Validate file type and size
        // Generate unique filename
        // Store in configured disk (local/S3/etc)
        // Create thumbnail if needed
        // Return file URL
    }
}
```

---

## 11. Multi-Store Architecture

### 11.1 Store-Aware Queries
```php
// Middleware to filter by user's assigned stores
class FilterByUserStores extends Middleware {
    public function handle($request, Closure $next) {
        // Add store_id filter to queries based on user permissions
        // Admin users see all stores
        // Store managers see only their assigned stores
    }
}

// Store-specific endpoints
GET /api/v1/stores/{storeId}/stock     # Stock for specific store
POST /api/v1/stock/transfer            # Transfer between stores
```

### 11.2 Multi-Store Business Logic
```php
class StoreTransferService {
    public function transferStock(
        StockItem $item,
        Store $fromStore, 
        Store $toStore,
        float $quantity
    ): void {
        // Validate sufficient stock at source
        // Create outbound movement at source store
        // Create inbound movement at destination store
        // Update quantities at both stores
        // Generate transfer documentation
    }
}
```

---

## 12. Testing Strategy

### 12.1 API Testing Structure
```php
// Feature tests for API endpoints
class StockItemApiTest extends TestCase {
    public function test_can_create_food_stock_item(): void
    {
        $response = $this->actingAs($user)
            ->postJson('/api/v1/stock/items', [
                'code' => 'TEST-001',
                'name' => 'Test Food Item',
                'stock_category' => 'food',
                // ... other fields
            ]);
            
        $response->assertStatus(201)
            ->assertJsonStructure(['data' => ['id', 'code', 'name']]);
    }
}

// Unit tests for business logic
class StockServiceTest extends TestCase {
    public function test_updates_quantity_and_creates_movement(): void
    {
        // Test business logic in isolation
    }
}
```

---

## 13. UNKNOWN API Requirements

### 13.1 Missing Authentication Details
**STATUS: UNKNOWN**
- Password reset flow requirements
- Email verification needed?
- Multi-factor authentication requirements?  
- Session management preferences?
- Token expiration policies?

### 13.2 Integration APIs
**STATUS: UNKNOWN**
- Accounting system integration endpoints needed?
- Supplier API connection requirements?
- Payment gateway integration needs?
- External reporting system APIs?
- Barcode generation service requirements?

### 13.3 Notification Systems  
**STATUS: UNKNOWN**
- Email notification preferences and templates?
- SMS notification requirements?
- Push notification needs?
- Webhook endpoints for external systems?

### 13.4 File Upload Requirements
**STATUS: UNKNOWN**
- Image upload for stock items needed?
- Document attachments for purchase orders?
- User avatar upload requirements?
- File size and type restrictions?
- Image processing needs (thumbnails, compression)?

---

**Document Version**: 1.0  
**Based on**: Flutter frontend analysis, DATABASE_DESIGN.md, and Laravel best practices  
**Framework**: Laravel 10+ with Sanctum authentication  
**Unknown Items**: Marked as UNKNOWN - require stakeholder clarification