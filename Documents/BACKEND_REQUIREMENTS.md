# Backend Requirements Analysis
**Catering Inventory Store Management System**

## Overview
This document outlines the complete backend requirements for the Flutter-based Catering Inventory Store Management System. The analysis is based on examination of the complete Flutter frontend codebase.

---

## 1. Application Structure & Navigation

### 1.1 Main Navigation Flow
- **Bottom Navigation**: Dashboard, Stock, Suppliers, Purchases, More
- **More Page Modules**: Transfers, Kitchen Issues, Recipes, Waste, Expiry, Users, Reports, Barcode, Multi-Store
- **Authentication Status**: UNKNOWN - No authentication screens or login flows detected in the codebase

### 1.2 Screen Hierarchy
```
├── Dashboard (landing page with KPIs)
├── Stock Management (3 tabs: Food, Catering, Electronics)
├── Suppliers (list, detail, form screens)
├── Purchases (list, detail, create, receiving, returns, invoicing)
├── Stock Transfers (list, create, history)
├── Kitchen Issues (ingredient issuing to cooking departments)
├── Recipes (list, detail, create with food costing)
├── Waste Management (record, track, analyze losses)
├── Expiry Management (monitor near-expiry items)
├── User Management (roles, permissions, audit)
├── Reports (various business intelligence reports)
├── Barcode (generate, scan, print)
└── Multi-Store (manage multiple locations)
```

---

## 2. Data Models & Entities

### 2.1 Core Inventory Models

#### **InventoryItem** (Legacy Base Model)
```typescript
{
  id: string
  code: string                // SKU/item code
  name: string
  category: string           // sub-category
  unit: string              // measurement unit
  purchasePrice: number     // cost price
  internalCost: number      // calculated internal cost
  minStock: number          // minimum threshold
  maxStock: number          // maximum threshold
  description: string
  stockOnHand: number       // current quantity
  reorderPoint: number      // reorder threshold
  status: string            // 'Healthy' | 'Low Stock' | 'Out of Stock'
}
```

#### **StockItem** (New Unified Base)
```typescript
{
  id: string
  code: string
  name: string
  category: string              // sub-category
  stockCategory: 'food' | 'catering' | 'electronics'
  unit: string
  purchasePrice: number
  quantity: number              // current on hand
  minQuantity: number
  maxQuantity: number
  location: string              // store/shelf location
  supplier: string
  status: 'Healthy' | 'Low Stock' | 'Out of Stock'
  description: string
  lastUpdated: datetime
}
```

#### **FoodStockItem** (extends StockItem)
```typescript
{
  // ... base StockItem fields
  expiryDate?: datetime
  batchNumber: string
  requiresRefrigeration: boolean
}
```

#### **CateringStockItem** (extends StockItem)
```typescript
{
  // ... base StockItem fields
  subtype: 'permanent' | 'temporary'
  // Permanent items:
  condition?: 'Good' | 'Fair' | 'Needs Repair'
  isReserved?: boolean
  reservedFor?: string          // event name
  // Temporary items:
  packSize?: number            // units per pack
  consumptionRate?: string     // usage pattern
}
```

#### **ElectronicsStockItem** (extends StockItem)
```typescript
{
  // ... base StockItem fields
  brand: string
  model: string
  serialNumber: string
  warrantyExpiry?: datetime
  maintenanceStatus: 'OK' | 'Due' | 'Overdue'
  lastMaintenanceDate?: datetime
  assetTag: string
}
```

### 2.2 Store Management

#### **Store**
```typescript
{
  id: string
  name: string
  code: string
  description: string
  location: string
  phone: string
  email: string
  manager: string
  isActive: boolean
  createdAt: datetime
  updatedAt: datetime
}
```

**Store Types**: main_warehouse, dry_food, cold_room, freezer, beverage, kitchen, electronics, general

### 2.3 Supplier Management

#### **Supplier**
```typescript
{
  id: string
  name: string
  company: string
  contactPerson: string
  phone: string
  email: string
  address: string
  taxNumber: string
  status: 'Active' | 'Pending' | 'Inactive'
  outstandingBalance: number
}
```

### 2.4 Purchase Management

#### **PurchaseRecord**
```typescript
{
  id: string
  number: string              // PO number
  supplier: string
  date: datetime
  item: string
  quantity: number
  unitPrice: number
  vat: number
  discount: number
  total: number
}
```

#### **PurchaseViewModel** (Frontend Display Model)
```typescript
{
  number: string              // PO-1048
  supplier: string
  date: string               // formatted date
  items: number              // item count
  amount: string             // formatted total
  expectedDelivery: string   // formatted date
  status: 'Pending' | 'Approved' | 'Received'
  paymentStatus: 'Pending' | 'Partially Paid' | 'Paid'
}
```

### 2.5 Stock Movement Tracking

#### **StockMovement** (Legacy)
```typescript
{
  id: string
  item: string               // item name
  type: string               // movement type
  quantity: number
  date: datetime
  note: string
}
```

#### **StockMovementEntry** (New Detailed)
```typescript
{
  id: string
  stockItemId: string
  type: 'Stock In' | 'Stock Out' | 'Transfer' | 'Adjustment' | 'Return'
  quantity: number
  unit: string
  performedBy: string        // user who performed action
  date: datetime
  note: string
}
```

### 2.6 Recipe Management

#### **RecipeIngredient**
```typescript
{
  name: string
  quantity: number
  unit: string
  unitCost: number
}
```

#### **RecipeItem**
```typescript
{
  id: string
  name: string
  category: string
  description: string
  servings: number
  ingredients: RecipeIngredient[]
  sellingPrice: number
  prepTime: string
  status: 'Active' | 'Inactive'
}
```

**Calculated Fields**: totalFoodCost, foodCostPercentage

### 2.7 Waste Management

#### **WasteRecord**
```typescript
{
  id: string
  number: string             // WS-3001
  item: string
  category: string
  unit: string
  quantity: number
  estimatedCost: number
  reason: string             // 'Spoilage' | 'Damaged Packaging' | 'Cooking Overproduction' | 'Expired' | 'Over-ripened'
  recordedBy: string         // user name
  date: datetime
  status: 'Confirmed' | 'Pending Review'
  notes: string
}
```

### 2.8 Expiry Management

#### **ExpiryItem**
```typescript
{
  id: string
  item: string
  category: string
  unit: string
  quantity: number
  expiryDate: datetime
  batchNumber: string
  location: string
  status: 'Expired' | 'Expiring Soon' | 'OK'
}
```

### 2.9 User Management

#### **AppUser**
```typescript
{
  id: string
  name: string
  email: string
  phone: string
  role: string               // 'Admin' | 'Store Manager' | 'Kitchen Supervisor' | 'Cashier' | 'Storekeeper' | 'Chef'
  department: string         // 'Management' | 'Main Store' | 'Main Kitchen' | 'Finance' | 'Branch 2 Store' | 'Prep Kitchen'
  status: 'Active' | 'Inactive' | 'Suspended'
  createdAt: datetime
  lastLogin: string          // formatted string
  permissions: string[]      // ['inventory', 'suppliers', 'purchases', 'recipes', 'waste', 'expiry', 'users', 'reports']
}
```

### 2.10 Alerts & Notifications

#### **AlertItem**
```typescript
{
  id: string
  title: string
  detail: string
  date: datetime
  severity: 'High' | 'Medium' | 'Low'
}
```

---

## 3. CRUD Operations by Entity

### 3.1 Stock Items
- **Create**: Add new food/catering/electronics items with category-specific fields
- **Read**: List with filtering (category, status, search), detailed view
- **Update**: Edit item details, update quantities, change status
- **Delete**: Remove items (with confirmation)

### 3.2 Suppliers
- **Create**: Add new supplier with company details
- **Read**: List with search/filter, supplier detail view
- **Update**: Edit supplier information, update status
- **Delete**: Remove supplier (with confirmation)

### 3.3 Purchases
- **Create**: Create purchase orders, goods receiving
- **Read**: List with filters, detailed purchase view
- **Update**: Update purchase status, receive goods, process returns
- **Delete**: Cancel/delete purchase orders

### 3.4 Users
- **Create**: Add team members with roles and permissions
- **Read**: List with role filtering, user profiles
- **Update**: Edit user details, change roles/permissions, update status
- **Delete**: Deactivate/remove users

### 3.5 Recipes
- **Create**: Create recipes with ingredient lists and costing
- **Read**: List with category filters, recipe details with cost analysis
- **Update**: Edit recipes, update ingredients, change status
- **Delete**: Remove recipes

### 3.6 Waste Records
- **Create**: Record new waste events with details
- **Read**: List with status filters, waste analysis reports
- **Update**: Update waste status, add notes
- **Delete**: Remove waste records

### 3.7 Stock Movements
- **Create**: Record stock in/out/transfers automatically and manually
- **Read**: Movement history with filters, audit trails
- **Update**: UNKNOWN - movement correction capabilities unclear
- **Delete**: UNKNOWN - movement deletion policies unclear

---

## 4. Authentication & Authorization

### 4.1 Authentication Requirements
**STATUS: UNKNOWN**
- No login screens detected in codebase
- No authentication flows implemented
- Current app appears to run without authentication

### 4.2 Authorization Model
**Role-Based Permissions**: Based on AppUser.permissions array
- **inventory**: Stock management access
- **suppliers**: Supplier management access  
- **purchases**: Purchase order access
- **recipes**: Recipe management access
- **waste**: Waste recording access
- **expiry**: Expiry monitoring access
- **users**: User management access
- **reports**: Reporting access

### 4.3 User Roles Identified
- **Admin**: Full system access
- **Store Manager**: Inventory, suppliers, purchases, waste, expiry
- **Kitchen Supervisor**: Inventory, recipes, waste
- **Cashier**: Purchases, reports
- **Storekeeper**: Inventory, waste, expiry
- **Chef**: Recipes, waste

---

## 5. API Endpoints Required

### 5.1 Stock Management APIs

#### Stock Items
```
GET    /api/stock/items                 # List all stock items with filters
GET    /api/stock/items/:id            # Get specific item details
POST   /api/stock/items                # Create new stock item
PUT    /api/stock/items/:id            # Update stock item
DELETE /api/stock/items/:id            # Delete stock item
GET    /api/stock/items/food           # List food stock items
GET    /api/stock/items/catering       # List catering stock items
GET    /api/stock/items/electronics    # List electronics stock items
```

#### Stock Movements  
```
GET    /api/stock/movements            # List movements with filters
POST   /api/stock/movements            # Record new movement
GET    /api/stock/movements/:itemId    # Get movements for specific item
```

### 5.2 Supplier Management APIs
```
GET    /api/suppliers                  # List suppliers with search/filter
GET    /api/suppliers/:id             # Get supplier details
POST   /api/suppliers                 # Create new supplier
PUT    /api/suppliers/:id             # Update supplier
DELETE /api/suppliers/:id             # Delete supplier
```

### 5.3 Purchase Management APIs
```
GET    /api/purchases                 # List purchases with filters
GET    /api/purchases/:id            # Get purchase details
POST   /api/purchases                # Create purchase order
PUT    /api/purchases/:id            # Update purchase
DELETE /api/purchases/:id            # Cancel/delete purchase
POST   /api/purchases/:id/receive    # Goods receiving
POST   /api/purchases/:id/return     # Purchase returns
GET    /api/purchases/:id/invoice    # Generate invoice
```

### 5.4 Recipe Management APIs
```
GET    /api/recipes                  # List recipes with category filter
GET    /api/recipes/:id             # Get recipe with costing details
POST   /api/recipes                 # Create new recipe
PUT    /api/recipes/:id             # Update recipe
DELETE /api/recipes/:id             # Delete recipe
```

### 5.5 Waste Management APIs
```
GET    /api/waste                   # List waste records with filters
GET    /api/waste/:id              # Get waste record details
POST   /api/waste                  # Create waste record
PUT    /api/waste/:id              # Update waste record
DELETE /api/waste/:id              # Delete waste record
```

### 5.6 Expiry Management APIs
```
GET    /api/expiry                 # List expiring items
GET    /api/expiry/alerts          # Get expiry alerts
PUT    /api/expiry/:id             # Update expiry status
```

### 5.7 User Management APIs
```
GET    /api/users                  # List users with role filters
GET    /api/users/:id             # Get user profile
POST   /api/users                 # Create new user
PUT    /api/users/:id             # Update user
DELETE /api/users/:id             # Deactivate user
GET    /api/users/permissions     # List available permissions
```

### 5.8 Store Management APIs  
```
GET    /api/stores                 # List all stores
GET    /api/stores/:id            # Get store details
POST   /api/stores                # Create new store
PUT    /api/stores/:id            # Update store
DELETE /api/stores/:id            # Delete store
```

### 5.9 Dashboard & Analytics APIs
```
GET    /api/dashboard/kpis         # Dashboard KPI data
GET    /api/dashboard/alerts       # System alerts
GET    /api/reports/stock          # Stock reports
GET    /api/reports/purchases      # Purchase reports
GET    /api/reports/waste          # Waste analysis
GET    /api/reports/expiry         # Expiry reports
GET    /api/reports/consumption    # Consumption reports
```

### 5.10 Authentication APIs
**STATUS: UNKNOWN** - No auth implementation detected
```
POST   /api/auth/login             # User login (REQUIRED)
POST   /api/auth/logout            # User logout (REQUIRED)
GET    /api/auth/profile           # Current user profile (REQUIRED)
POST   /api/auth/refresh           # Token refresh (REQUIRED)
```

---

## 6. Hardcoded/Mock Data Analysis

### 6.1 Current Mock Data Location
**File**: `lib/services/mock_repository.dart`

### 6.2 Mock Data Categories
- **InventoryItem**: 3 sample items (Chicken Breast, Basmati Rice, Milk Powder)
- **Supplier**: 2 suppliers (Fresh Foods PLC, Urban Pantry)
- **PurchaseRecord**: 2 purchase orders
- **StockMovement**: 3 movement records  
- **Recipe**: 2 basic recipes
- **AlertItem**: 2 sample alerts
- **RecipeItem**: 5 detailed recipes with costing
- **WasteRecord**: 5 waste records
- **ExpiryItem**: 7 expiry tracking items
- **AppUser**: 6 users with different roles
- **FoodStockItem**: 6 food items
- **CateringStockItem**: 8 items (4 permanent, 4 temporary)
- **ElectronicsStockItem**: 4 electronic items
- **StockMovementEntry**: 6 detailed movements

### 6.3 Data That Needs Persistent Storage
**ALL** mock data entities require database persistence:
- Stock items (all categories)
- Suppliers and purchase records
- Recipes with ingredients
- Waste and expiry records  
- Users and permissions
- Stores and locations
- Stock movements and audit trails
- System alerts and notifications

---

## 7. Business Logic Requirements

### 7.1 Stock Level Management
- **Automatic Status Calculation**: Based on quantity vs min/max thresholds
- **Low Stock Alerts**: When quantity falls below reorder point
- **Stock Fraction Calculation**: Safe division handling (quantity/maxQuantity)

### 7.2 Food Cost Calculation
- **Recipe Costing**: Automatic calculation of total food cost from ingredients
- **Food Cost Percentage**: (totalFoodCost / sellingPrice) * 100
- **Cost Analysis**: Color coding based on cost percentage thresholds

### 7.3 Expiry Management
- **Status Determination**: Auto-calculate 'Expired', 'Expiring Soon', 'OK' based on dates
- **Alert Generation**: Proactive notifications for expiring items

### 7.4 Warranty Tracking
- **Electronics Warranty Status**: 'Active', 'Expiring Soon', 'Expired', 'No Warranty'
- **Maintenance Scheduling**: Track due dates and overdue maintenance

### 7.5 Movement Auditing
- **Stock Movement Logging**: All stock changes must be recorded
- **User Attribution**: Track who performed each movement
- **Automatic Movements**: System-generated movements for purchases, waste, etc.

---

## 8. Images & Assets

### 8.1 Asset Requirements
**STATUS: UNKNOWN** - No image upload/storage functionality detected in codebase

### 8.2 Potential Asset Needs
- User profile photos
- Item/product images  
- Store location photos
- Supplier company logos
- Recipe dish photos
- Waste evidence photos

**RECOMMENDATION**: Asset management system needed if visual inventory tracking is required

---

## 9. Reporting Requirements

### 9.1 Dashboard KPIs
- Total stock count with trend
- Inventory value with percentage change
- Low stock alerts count
- Expiring items count  
- Daily purchase value with trend
- Stock out count
- Recent transactions count

### 9.2 Stock Reports
- Current stock levels by category
- Inventory valuation by item
- Low stock alerts list
- Stock movement history
- Location-wise stock distribution

### 9.3 Financial Reports  
- Purchase spend analysis
- Supplier performance metrics
- Cost analysis by category
- Waste cost tracking
- Recipe profitability analysis

### 9.4 Operational Reports
- Expiry tracking and alerts  
- Waste analysis by reason/category
- User activity audit trails
- Consumption pattern analysis
- Supplier delivery performance

---

## 10. Integration Requirements

### 10.1 Barcode System
**Frontend Features Detected**:
- Barcode generation
- Barcode scanning  
- Label printing
- QR code support

**Backend Requirements**:
- Barcode format standardization
- Unique code generation
- Barcode-to-item mapping
- Print queue management

### 10.2 Multi-Store Support  
**Frontend Features**:
- Store creation and management
- Store-specific stock tracking
- Inter-store transfers

**Backend Requirements**:
- Store hierarchy management
- Cross-store inventory visibility
- Transfer workflow management
- Store-level access controls

### 10.3 External Integrations
**STATUS: UNKNOWN**
- Payment gateway integration
- Accounting software integration
- Supplier API connections
- Email/SMS notification services

---

## 11. Performance & Scalability Considerations

### 11.1 Data Volume Estimates
**Based on Mock Data Scale**:
- Stock Items: 1,000-10,000 items
- Daily Movements: 100-1,000 transactions
- Users: 10-100 team members  
- Suppliers: 50-500 vendors
- Monthly Purchases: 500-5,000 orders

### 11.2 Query Optimization Needs
- Stock item searches with filters
- Movement history queries by date range
- Expiry alerts calculation
- Dashboard KPI aggregations
- Report generation performance

### 11.3 Real-time Requirements
- Stock level updates
- Low stock alerts
- Expiry notifications  
- Movement tracking
- User activity monitoring

---

## 12. Security Requirements

### 12.1 Data Protection
- User credential security (REQUIRED - not implemented)
- Role-based data access  
- Audit trail integrity
- Financial data protection

### 12.2 Access Control
- Permission-based feature access
- Store-level data isolation
- User session management
- API endpoint protection

### 12.3 Compliance Requirements
**STATUS: UNKNOWN**
- Food safety regulations compliance
- Financial audit requirements  
- Data retention policies
- Export/import documentation

---

## 13. Critical Implementation Notes

### 13.1 Missing Authentication
**CRITICAL**: The entire application currently runs without authentication. This is a security risk for production deployment.

### 13.2 Data Model Evolution  
The codebase shows two inventory systems:
- **Legacy**: `InventoryItem` model
- **New**: `StockItem` hierarchy (Food/Catering/Electronics)

Backend should support **both models** during transition period.

### 13.3 Ethiopian Context
- **Currency**: ETB (Ethiopian Birr)
- **Date Formats**: DD/MM/YYYY pattern detected
- **Business Context**: Catering/restaurant industry focus
- **Sample Data**: Ethiopian names and business contexts

### 13.4 Mobile-First Design
- Responsive layouts for mobile devices
- Touch-friendly interfaces
- Offline capability needs assessment (UNKNOWN)

---

## 14. Immediate Development Priorities

### 14.1 Phase 1 (Critical)
1. **Authentication System**: Login/logout/session management
2. **Core Stock API**: CRUD operations for stock items
3. **User Management**: Role-based access control
4. **Basic Reporting**: Dashboard KPIs and stock reports

### 14.2 Phase 2 (Important)  
1. **Purchase Management**: Full purchase order workflow
2. **Movement Tracking**: Complete audit trail system
3. **Recipe Management**: Food costing calculations
4. **Waste/Expiry Management**: Loss tracking and alerts

### 14.3 Phase 3 (Enhanced)
1. **Multi-Store**: Location-based inventory
2. **Barcode Integration**: Generation and scanning
3. **Advanced Reporting**: Business intelligence features  
4. **External Integrations**: Payment, accounting, notifications

---

**Document Status**: Complete frontend analysis based on Flutter codebase examination  
**Last Updated**: Analysis based on current codebase state  
**Missing Information**: Items marked as UNKNOWN require clarification from stakeholders