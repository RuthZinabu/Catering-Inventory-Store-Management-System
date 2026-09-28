# Database Design Document
**Catering Inventory Store Management System**

## Overview
This document defines the PostgreSQL database schema for the catering inventory management system, based on analysis of the Flutter frontend models and requirements.

---

## 1. Confirmed Entities Analysis

### 1.1 Primary Entities (From Flutter Models)
- **Users** (`AppUser`) - System users with roles and permissions
- **Stores** (`Store`) - Physical store locations
- **Suppliers** (`Supplier`) - Vendor/supplier information
- **Stock Items** (`StockItem` hierarchy) - Unified inventory items
- **Recipes** (`RecipeItem`) - Dish recipes with ingredients
- **Purchase Orders** (`PurchaseRecord`) - Purchase transactions
- **Stock Movements** (`StockMovementEntry`) - Inventory transactions
- **Waste Records** (`WasteRecord`) - Loss tracking
- **Expiry Items** (`ExpiryItem`) - Expiration monitoring
- **Alerts** (`AlertItem`) - System notifications

### 1.2 Supporting Entities
- **Recipe Ingredients** (`RecipeIngredient`) - Recipe component details
- **Stock Batches** - Batch/lot tracking for food items
- **Purchase Order Items** - Line items within purchase orders

---

## 2. Entity Relationships

### 2.1 Core Relationships
```
Users (1) ──── (M) StockMovements [performedBy]
Users (1) ──── (M) WasteRecords [recordedBy]
Users (1) ──── (M) PurchaseOrders [createdBy]

Stores (1) ──── (M) StockItems [storeId]
Stores (1) ──── (M) Users [storeId] (optional)

Suppliers (1) ──── (M) StockItems [supplierId]
Suppliers (1) ──── (M) PurchaseOrders [supplierId]

StockItems (1) ──── (M) StockMovements [stockItemId]
StockItems (1) ──── (M) WasteRecords [stockItemId]
StockItems (1) ──── (M) ExpiryTracking [stockItemId]
StockItems (1) ──── (M) PurchaseOrderItems [stockItemId]

Recipes (1) ──── (M) RecipeIngredients [recipeId]
StockItems (1) ──── (M) RecipeIngredients [stockItemId]

PurchaseOrders (1) ──── (M) PurchaseOrderItems [purchaseOrderId]
```

### 2.2 Identified Contradictions in Flutter Models
1. **Duplicate Inventory Systems**: 
   - `InventoryItem` (legacy) vs `StockItem` (new) - **RESOLVED**: Use StockItem hierarchy
   - Different field names: `stockOnHand` vs `quantity`, `minStock` vs `minQuantity`

2. **Inconsistent Movement Tracking**:
   - `StockMovement` (legacy) vs `StockMovementEntry` (new) - **RESOLVED**: Use StockMovementEntry

3. **Recipe Duplication**:
   - `Recipe` (simple) vs `RecipeItem` (detailed) - **RESOLVED**: Use RecipeItem

4. **Purchase Model Confusion**:
   - `PurchaseRecord` (single item) vs `PurchaseViewModel` (multi-item display) - **RESOLVED**: Need proper PurchaseOrder + PurchaseOrderItems

---

## 3. PostgreSQL Schema Design

### 3.1 Users Table
```sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    name VARCHAR(255) NOT NULL,
    phone VARCHAR(50),
    role VARCHAR(50) NOT NULL,
    department VARCHAR(100),
    status VARCHAR(20) NOT NULL DEFAULT 'Active',
    permissions JSONB NOT NULL DEFAULT '[]',
    last_login_at TIMESTAMPTZ,
    email_verified_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ
);

-- Indexes
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_status ON users(status);
```

### 3.2 Stores Table
```sql
CREATE TABLE stores (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    code VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    location VARCHAR(255),
    phone VARCHAR(50),
    email VARCHAR(255),
    manager_id UUID REFERENCES users(id),
    store_type VARCHAR(50) NOT NULL, -- 'main_warehouse', 'dry_food', etc.
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ
);

-- Indexes
CREATE INDEX idx_stores_code ON stores(code);
CREATE INDEX idx_stores_type ON stores(store_type);
CREATE INDEX idx_stores_active ON stores(is_active);
```

### 3.3 Suppliers Table
```sql
CREATE TABLE suppliers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    company VARCHAR(255) NOT NULL,
    contact_person VARCHAR(255),
    phone VARCHAR(50),
    email VARCHAR(255),
    address TEXT,
    tax_number VARCHAR(50),
    status VARCHAR(20) NOT NULL DEFAULT 'Active',
    outstanding_balance DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    payment_terms VARCHAR(100),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ
);

-- Indexes
CREATE INDEX idx_suppliers_company ON suppliers(company);
CREATE INDEX idx_suppliers_status ON suppliers(status);
CREATE INDEX idx_suppliers_tax_number ON suppliers(tax_number);
```

### 3.4 Stock Items Table (Unified)
```sql
CREATE TYPE stock_category_enum AS ENUM ('food', 'catering', 'electronics');
CREATE TYPE stock_status_enum AS ENUM ('Healthy', 'Low Stock', 'Out of Stock');
CREATE TYPE catering_subtype_enum AS ENUM ('permanent', 'temporary');
CREATE TYPE maintenance_status_enum AS ENUM ('OK', 'Due', 'Overdue');

CREATE TABLE stock_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(100) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    category VARCHAR(100) NOT NULL, -- sub-category like 'Meat', 'Tables'
    stock_category stock_category_enum NOT NULL,
    unit VARCHAR(20) NOT NULL,
    
    -- Common fields
    purchase_price DECIMAL(15,2) NOT NULL,
    quantity DECIMAL(15,3) NOT NULL DEFAULT 0,
    min_quantity DECIMAL(15,3) NOT NULL DEFAULT 0,
    max_quantity DECIMAL(15,3) NOT NULL DEFAULT 0,
    reorder_point DECIMAL(15,3),
    
    -- References
    supplier_id UUID REFERENCES suppliers(id),
    store_id UUID REFERENCES stores(id),
    
    -- Status (calculated but cached for performance)
    status stock_status_enum NOT NULL DEFAULT 'Healthy',
    
    -- Food-specific fields
    expiry_date DATE,
    batch_number VARCHAR(100),
    requires_refrigeration BOOLEAN DEFAULT false,
    
    -- Catering-specific fields  
    catering_subtype catering_subtype_enum,
    condition VARCHAR(50), -- 'Good', 'Fair', 'Needs Repair'
    is_reserved BOOLEAN DEFAULT false,
    reserved_for VARCHAR(255),
    pack_size INTEGER,
    consumption_rate VARCHAR(100),
    
    -- Electronics-specific fields
    brand VARCHAR(100),
    model VARCHAR(100),
    serial_number VARCHAR(100),
    asset_tag VARCHAR(100),
    warranty_expiry DATE,
    maintenance_status maintenance_status_enum,
    last_maintenance_date DATE,
    
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ
);

-- Indexes
CREATE INDEX idx_stock_items_code ON stock_items(code);
CREATE INDEX idx_stock_items_category ON stock_items(stock_category, category);
CREATE INDEX idx_stock_items_supplier ON stock_items(supplier_id);
CREATE INDEX idx_stock_items_store ON stock_items(store_id);
CREATE INDEX idx_stock_items_status ON stock_items(status);
CREATE INDEX idx_stock_items_expiry ON stock_items(expiry_date) WHERE expiry_date IS NOT NULL;
CREATE INDEX idx_stock_items_batch ON stock_items(batch_number) WHERE batch_number IS NOT NULL;
CREATE INDEX idx_stock_items_serial ON stock_items(serial_number) WHERE serial_number IS NOT NULL;
```

### 3.5 Stock Movements Table
```sql
CREATE TYPE movement_type_enum AS ENUM ('Stock In', 'Stock Out', 'Transfer', 'Adjustment', 'Return');

CREATE TABLE stock_movements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    stock_item_id UUID NOT NULL REFERENCES stock_items(id),
    type movement_type_enum NOT NULL,
    quantity DECIMAL(15,3) NOT NULL,
    unit VARCHAR(20) NOT NULL,
    
    -- Before/after quantities for auditing
    quantity_before DECIMAL(15,3) NOT NULL,
    quantity_after DECIMAL(15,3) NOT NULL,
    
    -- Movement details
    reference_type VARCHAR(50), -- 'purchase_order', 'waste_record', 'manual', etc.
    reference_id UUID, -- ID of related record
    note TEXT,
    
    -- Transfer-specific
    from_store_id UUID REFERENCES stores(id),
    to_store_id UUID REFERENCES stores(id),
    
    -- Audit
    performed_by UUID NOT NULL REFERENCES users(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_stock_movements_item ON stock_movements(stock_item_id);
CREATE INDEX idx_stock_movements_type ON stock_movements(type);
CREATE INDEX idx_stock_movements_date ON stock_movements(created_at);
CREATE INDEX idx_stock_movements_user ON stock_movements(performed_by);
CREATE INDEX idx_stock_movements_reference ON stock_movements(reference_type, reference_id);
```

### 3.6 Purchase Orders Table
```sql
CREATE TYPE purchase_status_enum AS ENUM ('Draft', 'Pending', 'Approved', 'Received', 'Cancelled');
CREATE TYPE payment_status_enum AS ENUM ('Pending', 'Partially Paid', 'Paid', 'Overdue');

CREATE TABLE purchase_orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    number VARCHAR(50) UNIQUE NOT NULL, -- PO-1048
    supplier_id UUID NOT NULL REFERENCES suppliers(id),
    
    -- Dates
    order_date DATE NOT NULL,
    expected_delivery_date DATE,
    received_date DATE,
    
    -- Amounts (calculated from line items)
    subtotal DECIMAL(15,2) NOT NULL DEFAULT 0,
    vat_amount DECIMAL(15,2) NOT NULL DEFAULT 0,
    discount_amount DECIMAL(15,2) NOT NULL DEFAULT 0,
    total_amount DECIMAL(15,2) NOT NULL DEFAULT 0,
    
    -- Status
    status purchase_status_enum NOT NULL DEFAULT 'Draft',
    payment_status payment_status_enum NOT NULL DEFAULT 'Pending',
    
    -- Audit
    created_by UUID NOT NULL REFERENCES users(id),
    approved_by UUID REFERENCES users(id),
    received_by UUID REFERENCES users(id),
    
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ
);

-- Indexes
CREATE INDEX idx_purchase_orders_number ON purchase_orders(number);
CREATE INDEX idx_purchase_orders_supplier ON purchase_orders(supplier_id);
CREATE INDEX idx_purchase_orders_status ON purchase_orders(status);
CREATE INDEX idx_purchase_orders_date ON purchase_orders(order_date);
```

### 3.7 Purchase Order Items Table
```sql
CREATE TABLE purchase_order_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    purchase_order_id UUID NOT NULL REFERENCES purchase_orders(id) ON DELETE CASCADE,
    stock_item_id UUID NOT NULL REFERENCES stock_items(id),
    
    quantity DECIMAL(15,3) NOT NULL,
    unit_price DECIMAL(15,2) NOT NULL,
    line_total DECIMAL(15,2) NOT NULL,
    
    -- Receiving tracking
    quantity_received DECIMAL(15,3) NOT NULL DEFAULT 0,
    quantity_remaining DECIMAL(15,3) NOT NULL,
    
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_purchase_order_items_po ON purchase_order_items(purchase_order_id);
CREATE INDEX idx_purchase_order_items_item ON purchase_order_items(stock_item_id);
```

### 3.8 Recipes Table
```sql
CREATE TABLE recipes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    category VARCHAR(100) NOT NULL,
    description TEXT,
    servings INTEGER NOT NULL DEFAULT 1,
    prep_time VARCHAR(50),
    selling_price DECIMAL(15,2) NOT NULL DEFAULT 0,
    status VARCHAR(20) NOT NULL DEFAULT 'Active',
    
    -- Calculated fields (cached for performance)
    total_food_cost DECIMAL(15,2) NOT NULL DEFAULT 0,
    food_cost_percentage DECIMAL(5,2) NOT NULL DEFAULT 0,
    
    created_by UUID NOT NULL REFERENCES users(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ
);

-- Indexes
CREATE INDEX idx_recipes_category ON recipes(category);
CREATE INDEX idx_recipes_status ON recipes(status);
CREATE INDEX idx_recipes_cost_pct ON recipes(food_cost_percentage);
```

### 3.9 Recipe Ingredients Table
```sql
CREATE TABLE recipe_ingredients (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    recipe_id UUID NOT NULL REFERENCES recipes(id) ON DELETE CASCADE,
    stock_item_id UUID REFERENCES stock_items(id), -- NULL for non-inventory ingredients
    ingredient_name VARCHAR(255) NOT NULL, -- For display, even if linked to stock_item
    quantity DECIMAL(15,3) NOT NULL,
    unit VARCHAR(20) NOT NULL,
    unit_cost DECIMAL(15,2) NOT NULL,
    total_cost DECIMAL(15,2) NOT NULL, -- calculated: quantity * unit_cost
    
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_recipe_ingredients_recipe ON recipe_ingredients(recipe_id);
CREATE INDEX idx_recipe_ingredients_stock_item ON recipe_ingredients(stock_item_id);
```

### 3.10 Waste Records Table
```sql
CREATE TYPE waste_status_enum AS ENUM ('Pending Review', 'Confirmed', 'Rejected');

CREATE TABLE waste_records (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    number VARCHAR(50) UNIQUE NOT NULL, -- WS-3001
    stock_item_id UUID NOT NULL REFERENCES stock_items(id),
    
    quantity DECIMAL(15,3) NOT NULL,
    estimated_cost DECIMAL(15,2) NOT NULL,
    reason VARCHAR(100) NOT NULL,
    notes TEXT,
    
    status waste_status_enum NOT NULL DEFAULT 'Pending Review',
    
    -- Audit
    recorded_by UUID NOT NULL REFERENCES users(id),
    approved_by UUID REFERENCES users(id),
    
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ
);

-- Indexes
CREATE INDEX idx_waste_records_number ON waste_records(number);
CREATE INDEX idx_waste_records_item ON waste_records(stock_item_id);
CREATE INDEX idx_waste_records_status ON waste_records(status);
CREATE INDEX idx_waste_records_date ON waste_records(created_at);
CREATE INDEX idx_waste_records_reason ON waste_records(reason);
```

### 3.11 Alerts Table
```sql
CREATE TYPE alert_severity_enum AS ENUM ('Low', 'Medium', 'High', 'Critical');

CREATE TABLE alerts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(255) NOT NULL,
    detail TEXT,
    severity alert_severity_enum NOT NULL DEFAULT 'Medium',
    
    -- Optional associations
    stock_item_id UUID REFERENCES stock_items(id),
    user_id UUID REFERENCES users(id),
    
    -- Alert metadata
    alert_type VARCHAR(50) NOT NULL, -- 'low_stock', 'expiry', 'maintenance', etc.
    is_read BOOLEAN NOT NULL DEFAULT false,
    is_resolved BOOLEAN NOT NULL DEFAULT false,
    
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    resolved_at TIMESTAMPTZ,
    resolved_by UUID REFERENCES users(id)
);

-- Indexes
CREATE INDEX idx_alerts_type ON alerts(alert_type);
CREATE INDEX idx_alerts_severity ON alerts(severity);
CREATE INDEX idx_alerts_unread ON alerts(is_read) WHERE is_read = false;
CREATE INDEX idx_alerts_unresolved ON alerts(is_resolved) WHERE is_resolved = false;
CREATE INDEX idx_alerts_stock_item ON alerts(stock_item_id) WHERE stock_item_id IS NOT NULL;
```

---

## 4. Fields for PostgreSQL vs Calculated Fields

### 4.1 Database-Stored Fields
**All entity fields EXCEPT:**
- Stock status (calculated from quantity vs min/max but cached)
- Recipe total costs and percentages (calculated but cached)
- Expiry status (calculated from expiry_date vs current date)
- Warranty status (calculated from warranty_expiry vs current date)
- Stock value (quantity * purchase_price - always calculated)
- Outstanding balances (calculated from transactions)

### 4.2 Calculated/Derived Fields (NOT Stored)
```sql
-- Stock Item Calculations
stock_value = quantity * purchase_price
stock_fraction = quantity / NULLIF(max_quantity, 0)
days_to_expiry = expiry_date - CURRENT_DATE
warranty_days_remaining = warranty_expiry - CURRENT_DATE

-- Recipe Calculations (cached but recalculated on ingredient changes)
total_food_cost = SUM(quantity * unit_cost) FROM recipe_ingredients
food_cost_percentage = (total_food_cost / NULLIF(selling_price, 0)) * 100

-- Purchase Order Calculations
subtotal = SUM(quantity * unit_price) FROM purchase_order_items
total_amount = subtotal + vat_amount - discount_amount

-- Supplier Calculations
outstanding_balance = SUM(amounts from unpaid invoices)

-- Dashboard KPIs (always calculated)
total_inventory_value = SUM(quantity * purchase_price) FROM stock_items
low_stock_count = COUNT(*) FROM stock_items WHERE status = 'Low Stock'
expiring_soon_count = COUNT(*) FROM stock_items WHERE expiry_date <= CURRENT_DATE + INTERVAL '7 days'
```

---

## 5. Database Constraints and Business Rules

### 5.1 Check Constraints
```sql
-- Stock Items
ALTER TABLE stock_items ADD CONSTRAINT chk_positive_quantities 
    CHECK (quantity >= 0 AND min_quantity >= 0 AND max_quantity >= 0);
    
ALTER TABLE stock_items ADD CONSTRAINT chk_min_max_quantities 
    CHECK (min_quantity <= max_quantity);

-- Stock Movements
ALTER TABLE stock_movements ADD CONSTRAINT chk_positive_movement_quantity 
    CHECK (quantity > 0);

-- Purchase Orders
ALTER TABLE purchase_orders ADD CONSTRAINT chk_positive_amounts 
    CHECK (subtotal >= 0 AND vat_amount >= 0 AND discount_amount >= 0 AND total_amount >= 0);

-- Recipe Ingredients
ALTER TABLE recipe_ingredients ADD CONSTRAINT chk_positive_recipe_quantities 
    CHECK (quantity > 0 AND unit_cost >= 0);
```

### 5.2 Unique Constraints
```sql
-- Prevent duplicate recipe ingredients
ALTER TABLE recipe_ingredients ADD CONSTRAINT uk_recipe_ingredient 
    UNIQUE (recipe_id, stock_item_id, ingredient_name);

-- Unique asset tags for electronics
CREATE UNIQUE INDEX uk_electronics_asset_tag ON stock_items(asset_tag) 
    WHERE asset_tag IS NOT NULL;

-- Unique serial numbers for electronics  
CREATE UNIQUE INDEX uk_electronics_serial ON stock_items(serial_number) 
    WHERE serial_number IS NOT NULL;
```

---

## 6. UNKNOWN Requirements

### 6.1 Data Retention Policies
**STATUS: UNKNOWN**
- How long to retain stock movement history?
- Waste record retention requirements?
- User activity audit trail retention?
- Soft delete vs hard delete policies?

### 6.2 Multi-tenancy Requirements
**STATUS: UNKNOWN**
- Single-tenant per deployment vs multi-tenant database?
- Organization/company isolation needed?
- Data sharing between related companies?

### 6.3 Compliance Requirements
**STATUS: UNKNOWN**  
- Food safety regulation compliance fields needed?
- Financial audit trail requirements?
- GDPR/data protection compliance needs?
- Export/import documentation requirements?

### 6.4 Integration Requirements
**STATUS: UNKNOWN**
- Accounting system integration data needs?
- Supplier API integration requirements?
- Barcode format standardization needs?
- External reporting system requirements?

---

## 7. Performance Considerations

### 7.1 Partitioning Strategy
```sql
-- Stock movements by date (monthly partitions)
CREATE TABLE stock_movements_template (LIKE stock_movements INCLUDING ALL);
-- Implement monthly partitions for stock_movements

-- Alerts by date (monthly partitions for historical data)
-- Keep recent alerts in main table, archive older ones
```

### 7.2 Materialized Views for Reports
```sql
-- Daily stock summary
CREATE MATERIALIZED VIEW daily_stock_summary AS
SELECT 
    DATE(created_at) as date,
    stock_category,
    COUNT(*) as total_items,
    SUM(quantity * purchase_price) as total_value,
    COUNT(*) FILTER (WHERE status = 'Low Stock') as low_stock_count
FROM stock_items 
WHERE deleted_at IS NULL
GROUP BY DATE(created_at), stock_category;

-- Refresh daily
CREATE INDEX ON daily_stock_summary(date, stock_category);
```

### 7.3 Indexing Strategy
- **Composite indexes** for common filter combinations
- **Partial indexes** for soft-deleted records  
- **Expression indexes** for calculated fields used in queries
- **Foreign key indexes** for join performance

---

## 8. Migration Strategy

### 8.1 Legacy Data Migration
```sql
-- Migration from InventoryItem to StockItem
INSERT INTO stock_items (
    code, name, category, stock_category, unit,
    purchase_price, quantity, min_quantity, max_quantity,
    -- Map legacy fields to new structure
    -- Handle stockOnHand -> quantity, minStock -> min_quantity
);

-- Migration from old movement tracking
-- Migrate StockMovement to StockMovementEntry with proper relationships
```

### 8.2 Data Consistency Rules
1. **Stock quantities must be updated via stock_movements table**
2. **Recipe costs must be recalculated when ingredient prices change**  
3. **Purchase order totals must match sum of line items**
4. **Supplier balances must be maintained via transaction triggers**

---

**Document Version**: 1.0  
**Based on**: Flutter frontend analysis and BACKEND_REQUIREMENTS.md  
**Database**: PostgreSQL 14+  
**Unknown Items**: Marked as UNKNOWN - require stakeholder clarification