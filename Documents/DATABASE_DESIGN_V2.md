# Database Design V2
**Catering Inventory Store Management System - Updated Schema**

## Overview
This document defines the updated PostgreSQL database schema based on stakeholder decisions and modern backend requirements. Key improvements include proper separation of canonical items vs store-specific stock levels, enhanced multi-store support, comprehensive audit trails, and offline synchronization capabilities.

---

## 1. Architecture Principles

### 1.1 Canonical Items vs Store-Specific Stock
**CHANGED**: Separated item definitions from store-specific quantities
- **items** table: Canonical item definitions shared across all stores  
- **store_stock** table: Store-specific quantities, thresholds, and locations
- Benefits: Eliminates duplicate item definitions, enables proper multi-store operations

### 1.2 Enhanced Multi-Store Support
**NEW**: Proper store hierarchy and granular permissions
- Store parent-child relationships
- User-store assignments with role-based access
- Cross-store transfer management with approval workflows

### 1.3 Comprehensive Audit & Security
**NEW**: Complete audit trail and enhanced security features
- All data modifications logged with user attribution
- Soft deletes with reason tracking
- Two-factor authentication support
- Account lockout protection

### 1.4 Offline-First Design
**NEW**: Mobile offline synchronization support
- Sync queues for offline operations
- Device registration and management
- Conflict resolution capabilities

---

## 2. Core Schema Tables

### 2.1 Users Table (Enhanced)
```sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    name VARCHAR(255) NOT NULL,
    phone VARCHAR(50),
    
    -- Role & Department
    role VARCHAR(50) NOT NULL,
    department VARCHAR(100),
    status VARCHAR(20) NOT NULL DEFAULT 'Active',
    permissions JSONB NOT NULL DEFAULT '[]',
    
    -- Enhanced Security
    two_factor_enabled BOOLEAN DEFAULT false,
    two_factor_secret VARCHAR(255),
    failed_login_attempts INTEGER DEFAULT 0,
    locked_until TIMESTAMPTZ,
    password_changed_at TIMESTAMPTZ,
    must_change_password BOOLEAN DEFAULT false,
    
    -- Audit Timestamps
    last_login_at TIMESTAMPTZ,
    email_verified_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ
);

-- Indexes
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_status ON users(status) WHERE deleted_at IS NULL;
CREATE INDEX idx_users_locked ON users(locked_until) WHERE locked_until IS NOT NULL;
```
### 2.2 Stores Table (Enhanced)
```sql
CREATE TABLE stores (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    code VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    location VARCHAR(255),
    phone VARCHAR(50),
    email VARCHAR(255),
    
    -- Store Hierarchy
    parent_store_id UUID REFERENCES stores(id),
    store_level INTEGER DEFAULT 0, -- 0=main, 1=branch, 2=sub-branch
    
    -- Management
    manager_id UUID REFERENCES users(id),
    store_type VARCHAR(50) NOT NULL, -- 'main_warehouse', 'dry_food', etc.
    
    -- Operations
    timezone VARCHAR(50) DEFAULT 'UTC',
    operating_hours JSONB,
    settings JSONB DEFAULT '{}',
    
    -- Status
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ
);

-- Indexes
CREATE INDEX idx_stores_code ON stores(code);
CREATE INDEX idx_stores_type ON stores(store_type);
CREATE INDEX idx_stores_parent ON stores(parent_store_id);
CREATE INDEX idx_stores_level ON stores(store_level);
CREATE INDEX idx_stores_active ON stores(is_active) WHERE deleted_at IS NULL;
```

### 2.3 User-Store Assignments (NEW)
```sql
CREATE TABLE user_store_assignments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    store_id UUID NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
    
    -- Store-specific role
    role_in_store VARCHAR(50) NOT NULL, -- 'manager', 'supervisor', 'staff'
    
    -- Transfer permissions
    can_transfer_to BOOLEAN DEFAULT false,
    can_transfer_from BOOLEAN DEFAULT false,
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, store_id)
);

CREATE INDEX idx_user_store_user ON user_store_assignments(user_id);
CREATE INDEX idx_user_store_store ON user_store_assignments(store_id);
```

### 2.4 Canonical Items Table (NEW)
```sql
CREATE TYPE item_type_enum AS ENUM ('food', 'catering', 'electronics');
CREATE TYPE catering_subtype_enum AS ENUM ('permanent', 'temporary');

CREATE TABLE items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(100) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    category VARCHAR(100) NOT NULL, -- 'Meat', 'Tables', 'Laptops', etc.
    item_type item_type_enum NOT NULL,
    unit VARCHAR(20) NOT NULL,
    
    -- Default pricing (can be overridden per store)
    default_purchase_price DECIMAL(15,2),
    
    -- Food-specific canonical attributes
    shelf_life_days INTEGER,
    requires_refrigeration BOOLEAN DEFAULT false,
    
    -- Catering-specific canonical attributes  
    catering_subtype catering_subtype_enum,
    
    -- Electronics-specific canonical attributes
    brand VARCHAR(100),
    model VARCHAR(100),
    warranty_period_months INTEGER,
    
    -- Metadata
    is_active BOOLEAN DEFAULT true,
    created_by UUID NOT NULL REFERENCES users(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ
);

-- Indexes
CREATE INDEX idx_items_code ON items(code) WHERE deleted_at IS NULL;
CREATE INDEX idx_items_type_category ON items(item_type, category) WHERE deleted_at IS NULL;
CREATE INDEX idx_items_name ON items USING gin(to_tsvector('english', name));
CREATE INDEX idx_items_active ON items(is_active) WHERE deleted_at IS NULL;
```
### 2.5 Store-Specific Stock Levels (NEW)
```sql
CREATE TYPE stock_status_enum AS ENUM ('Healthy', 'Low Stock', 'Out of Stock', 'Expired', 'Expiring Soon');

CREATE TABLE store_stock (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    item_id UUID NOT NULL REFERENCES items(id),
    store_id UUID NOT NULL REFERENCES stores(id),
    
    -- Quantities
    quantity DECIMAL(15,3) NOT NULL DEFAULT 0,
    reserved_quantity DECIMAL(15,3) NOT NULL DEFAULT 0,
    available_quantity DECIMAL(15,3) GENERATED ALWAYS AS (quantity - reserved_quantity) STORED,
    
    -- Store-specific thresholds
    min_quantity DECIMAL(15,3) NOT NULL DEFAULT 0,
    max_quantity DECIMAL(15,3) NOT NULL DEFAULT 0,
    reorder_point DECIMAL(15,3),
    
    -- Location within store
    location_code VARCHAR(50), -- A1-B2, FREEZER-01, etc.
    location_description VARCHAR(255),
    
    -- Store-specific pricing
    current_cost DECIMAL(15,2),
    last_cost DECIMAL(15,2),
    
    -- Status & Tracking
    status stock_status_enum NOT NULL DEFAULT 'Healthy',
    last_counted_at TIMESTAMPTZ,
    last_counted_by UUID REFERENCES users(id),
    
    -- Audit
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    UNIQUE(item_id, store_id)
);

-- Indexes
CREATE INDEX idx_store_stock_store ON store_stock(store_id);
CREATE INDEX idx_store_stock_item ON store_stock(item_id);
CREATE INDEX idx_store_stock_store_item ON store_stock(store_id, item_id);
CREATE INDEX idx_store_stock_status ON store_stock(store_id, status);
CREATE INDEX idx_store_stock_low ON store_stock(store_id) WHERE status = 'Low Stock';
CREATE INDEX idx_store_stock_location ON store_stock(store_id, location_code) WHERE location_code IS NOT NULL;
```

### 2.6 Stock Movements (Enhanced)
```sql
CREATE TYPE movement_type_enum AS ENUM ('Stock In', 'Stock Out', 'Transfer', 'Adjustment', 'Return', 'Correction');

CREATE TABLE stock_movements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    item_id UUID NOT NULL REFERENCES items(id),
    store_id UUID NOT NULL REFERENCES stores(id),
    
    type movement_type_enum NOT NULL,
    quantity DECIMAL(15,3) NOT NULL,
    unit VARCHAR(20) NOT NULL,
    
    -- Before/after quantities for auditing
    quantity_before DECIMAL(15,3) NOT NULL,
    quantity_after DECIMAL(15,3) NOT NULL,
    
    -- Movement details
    reference_type VARCHAR(50), -- 'purchase_order', 'transfer', 'waste_record', 'manual'
    reference_id UUID, -- ID of related record
    note TEXT,
    
    -- Transfer-specific fields
    from_store_id UUID REFERENCES stores(id),
    to_store_id UUID REFERENCES stores(id),
    
    -- Correction capabilities
    is_correction BOOLEAN DEFAULT false,
    corrects_movement_id UUID REFERENCES stock_movements(id),
    correction_reason TEXT,
    
    -- Approval workflow
    requires_approval BOOLEAN DEFAULT false,
    approved_by UUID REFERENCES users(id),
    approved_at TIMESTAMPTZ,
    rejection_reason TEXT,
    
    -- Soft delete
    deleted_at TIMESTAMPTZ,
    deleted_by UUID REFERENCES users(id),
    deletion_reason TEXT,
    
    -- Offline sync support
    offline_sync_id UUID UNIQUE,
    offline_created_at TIMESTAMPTZ,
    sync_status VARCHAR(20) DEFAULT 'synced', -- 'synced', 'pending', 'conflict'
    
    -- Audit
    performed_by UUID NOT NULL REFERENCES users(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_stock_movements_item_store ON stock_movements(item_id, store_id);
CREATE INDEX idx_stock_movements_store_date ON stock_movements(store_id, created_at);
CREATE INDEX idx_stock_movements_type ON stock_movements(type);
CREATE INDEX idx_stock_movements_user ON stock_movements(performed_by);
CREATE INDEX idx_stock_movements_reference ON stock_movements(reference_type, reference_id);
CREATE INDEX idx_stock_movements_correction ON stock_movements(corrects_movement_id) WHERE corrects_movement_id IS NOT NULL;
CREATE INDEX idx_stock_movements_sync ON stock_movements(sync_status) WHERE sync_status != 'synced';
```
### 2.7 Suppliers Table (Minor Updates)
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
    
    -- Business details
    status VARCHAR(20) NOT NULL DEFAULT 'Active',
    payment_terms VARCHAR(100),
    credit_limit DECIMAL(15,2),
    
    -- Calculated balances (maintained via triggers)
    outstanding_balance DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ
);

-- Indexes (unchanged from V1)
CREATE INDEX idx_suppliers_company ON suppliers(company) WHERE deleted_at IS NULL;
CREATE INDEX idx_suppliers_status ON suppliers(status);
CREATE INDEX idx_suppliers_tax_number ON suppliers(tax_number) WHERE tax_number IS NOT NULL;
```

### 2.8 Transfer Management (NEW)
```sql
CREATE TYPE transfer_status_enum AS ENUM ('pending', 'approved', 'in_transit', 'received', 'cancelled');

CREATE TABLE transfers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    transfer_number VARCHAR(50) UNIQUE NOT NULL, -- TRF-2024-001
    
    from_store_id UUID NOT NULL REFERENCES stores(id),
    to_store_id UUID NOT NULL REFERENCES stores(id),
    
    status transfer_status_enum NOT NULL DEFAULT 'pending',
    priority VARCHAR(20) DEFAULT 'normal', -- 'low', 'normal', 'high', 'urgent'
    
    -- Workflow tracking
    requested_by UUID NOT NULL REFERENCES users(id),
    approved_by UUID REFERENCES users(id),
    shipped_by UUID REFERENCES users(id),
    received_by UUID REFERENCES users(id),
    
    -- Important dates
    requested_date DATE NOT NULL,
    required_date DATE,
    approved_date DATE,
    shipped_date DATE,
    received_date DATE,
    
    -- Notes
    notes TEXT,
    shipping_notes TEXT,
    
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE transfer_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    transfer_id UUID NOT NULL REFERENCES transfers(id) ON DELETE CASCADE,
    item_id UUID NOT NULL REFERENCES items(id),
    
    -- Quantity tracking through workflow
    quantity_requested DECIMAL(15,3) NOT NULL,
    quantity_approved DECIMAL(15,3),
    quantity_shipped DECIMAL(15,3),
    quantity_received DECIMAL(15,3),
    
    -- Costing
    unit_cost DECIMAL(15,2),
    
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_transfers_from_store ON transfers(from_store_id, status);
CREATE INDEX idx_transfers_to_store ON transfers(to_store_id, status);
CREATE INDEX idx_transfers_status_date ON transfers(status, requested_date);
CREATE INDEX idx_transfer_items_transfer ON transfer_items(transfer_id);
```

### 2.9 Purchase Orders (Enhanced)
```sql
CREATE TYPE purchase_status_enum AS ENUM ('Draft', 'Pending', 'Approved', 'Received', 'Cancelled');
CREATE TYPE payment_status_enum AS ENUM ('Pending', 'Partially Paid', 'Paid', 'Overdue');

CREATE TABLE purchase_orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    number VARCHAR(50) UNIQUE NOT NULL, -- PO-1048
    supplier_id UUID NOT NULL REFERENCES suppliers(id),
    destination_store_id UUID NOT NULL REFERENCES stores(id), -- NEW: Where items will be received
    
    -- Dates
    order_date DATE NOT NULL,
    expected_delivery_date DATE,
    received_date DATE,
    
    -- Amounts (calculated from line items)
    subtotal DECIMAL(15,2) NOT NULL DEFAULT 0,
    vat_amount DECIMAL(15,2) NOT NULL DEFAULT 0,
    discount_amount DECIMAL(15,2) NOT NULL DEFAULT 0,
    total_amount DECIMAL(15,2) NOT NULL DEFAULT 0,
    
    -- Status tracking
    status purchase_status_enum NOT NULL DEFAULT 'Draft',
    payment_status payment_status_enum NOT NULL DEFAULT 'Pending',
    
    -- Approval workflow (NEW)
    requires_approval BOOLEAN DEFAULT false,
    approval_threshold DECIMAL(15,2),
    approved_at TIMESTAMPTZ,
    
    -- Receiving workflow (NEW)
    receiving_status VARCHAR(20) DEFAULT 'pending', -- 'pending', 'partial', 'complete'
    partially_received_at TIMESTAMPTZ,
    fully_received_at TIMESTAMPTZ,
    
    -- Audit
    created_by UUID NOT NULL REFERENCES users(id),
    approved_by UUID REFERENCES users(id),
    received_by UUID REFERENCES users(id),
    
    notes TEXT,
    rejection_reason TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ
);

CREATE TABLE purchase_order_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    purchase_order_id UUID NOT NULL REFERENCES purchase_orders(id) ON DELETE CASCADE,
    item_id UUID NOT NULL REFERENCES items(id), -- CHANGED: Reference canonical items
    
    quantity DECIMAL(15,3) NOT NULL,
    unit_price DECIMAL(15,2) NOT NULL,
    line_total DECIMAL(15,2) NOT NULL,
    
    -- Receiving tracking
    quantity_received DECIMAL(15,3) NOT NULL DEFAULT 0,
    quantity_remaining DECIMAL(15,3) NOT NULL,
    received_into_store_id UUID REFERENCES stores(id), -- NEW: Track which store received
    
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_purchase_orders_supplier ON purchase_orders(supplier_id);
CREATE INDEX idx_purchase_orders_store ON purchase_orders(destination_store_id);
CREATE INDEX idx_purchase_orders_status ON purchase_orders(status);
CREATE INDEX idx_purchase_order_items_po ON purchase_order_items(purchase_order_id);
CREATE INDEX idx_purchase_order_items_item ON purchase_order_items(item_id);
```
### 2.10 Recipes (Minor Updates)
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
    
    -- Calculated fields (cached for performance, recalculated via triggers)
    total_food_cost DECIMAL(15,2) NOT NULL DEFAULT 0,
    food_cost_percentage DECIMAL(5,2) NOT NULL DEFAULT 0,
    
    created_by UUID NOT NULL REFERENCES users(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ
);

CREATE TABLE recipe_ingredients (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    recipe_id UUID NOT NULL REFERENCES recipes(id) ON DELETE CASCADE,
    item_id UUID REFERENCES items(id), -- CHANGED: Reference canonical items
    ingredient_name VARCHAR(255) NOT NULL, -- For display, even if linked to item
    quantity DECIMAL(15,3) NOT NULL,
    unit VARCHAR(20) NOT NULL,
    unit_cost DECIMAL(15,2) NOT NULL,
    total_cost DECIMAL(15,2) NOT NULL, -- calculated: quantity * unit_cost
    
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes (updated)
CREATE INDEX idx_recipe_ingredients_recipe ON recipe_ingredients(recipe_id);
CREATE INDEX idx_recipe_ingredients_item ON recipe_ingredients(item_id) WHERE item_id IS NOT NULL;
```

### 2.11 Waste Records (Enhanced)
```sql
CREATE TYPE waste_status_enum AS ENUM ('Pending Review', 'Confirmed', 'Rejected');

CREATE TABLE waste_records (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    number VARCHAR(50) UNIQUE NOT NULL, -- WS-3001
    item_id UUID NOT NULL REFERENCES items(id), -- CHANGED: Reference canonical items
    store_id UUID NOT NULL REFERENCES stores(id), -- NEW: Store-specific waste
    
    quantity DECIMAL(15,3) NOT NULL,
    estimated_cost DECIMAL(15,2) NOT NULL,
    reason VARCHAR(100) NOT NULL,
    notes TEXT,
    
    status waste_status_enum NOT NULL DEFAULT 'Pending Review',
    
    -- Approval workflow (NEW)
    requires_approval BOOLEAN DEFAULT false,
    approval_threshold DECIMAL(15,2),
    approved_at TIMESTAMPTZ,
    rejection_reason TEXT,
    
    -- File attachments (NEW)
    photo_evidence_urls TEXT[],
    
    -- Audit
    recorded_by UUID NOT NULL REFERENCES users(id),
    approved_by UUID REFERENCES users(id),
    
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ
);

-- Indexes (updated)
CREATE INDEX idx_waste_records_item_store ON waste_records(item_id, store_id);
CREATE INDEX idx_waste_records_store ON waste_records(store_id);
CREATE INDEX idx_waste_records_status ON waste_records(status);
CREATE INDEX idx_waste_records_date ON waste_records(created_at);
```

---

## 3. Supporting Tables

### 3.1 Audit Logs (NEW)
```sql
CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    table_name VARCHAR(100) NOT NULL,
    record_id UUID NOT NULL,
    operation VARCHAR(20) NOT NULL, -- 'INSERT', 'UPDATE', 'DELETE'
    
    -- Change tracking
    old_values JSONB,
    new_values JSONB,
    changed_fields TEXT[],
    
    -- User context
    user_id UUID NOT NULL REFERENCES users(id),
    ip_address INET,
    user_agent TEXT,
    
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_audit_logs_table_record ON audit_logs(table_name, record_id);
CREATE INDEX idx_audit_logs_user_date ON audit_logs(user_id, created_at);
CREATE INDEX idx_audit_logs_table_date ON audit_logs(table_name, created_at);
CREATE INDEX idx_audit_logs_operation ON audit_logs(operation);
```

### 3.2 File Attachments (NEW)
```sql
CREATE TABLE attachments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    filename VARCHAR(255) NOT NULL, -- Generated filename
    original_filename VARCHAR(255) NOT NULL, -- User's original filename
    mime_type VARCHAR(100) NOT NULL,
    file_size BIGINT NOT NULL,
    storage_path TEXT NOT NULL, -- Path to file in storage system
    
    -- Associations (polymorphic)
    entity_type VARCHAR(50) NOT NULL, -- 'waste_record', 'purchase_order', etc.
    entity_id UUID NOT NULL,
    
    -- Security
    uploaded_by UUID NOT NULL REFERENCES users(id),
    is_public BOOLEAN DEFAULT false,
    access_permissions JSONB DEFAULT '{}', -- Store-specific access rules
    
    -- Metadata
    description TEXT,
    tags TEXT[],
    
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ
);

-- Indexes
CREATE INDEX idx_attachments_entity ON attachments(entity_type, entity_id);
CREATE INDEX idx_attachments_uploader ON attachments(uploaded_by);
```
### 3.3 Notification System (NEW)
```sql
CREATE TYPE notification_type_enum AS ENUM ('system', 'email', 'sms', 'push');
CREATE TYPE notification_priority_enum AS ENUM ('low', 'normal', 'high', 'urgent');

CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    type notification_type_enum NOT NULL,
    priority notification_priority_enum NOT NULL DEFAULT 'normal',
    
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    
    -- Recipients (at least one must be specified)
    user_id UUID REFERENCES users(id),
    store_id UUID REFERENCES stores(id), -- All users in this store
    role_filter VARCHAR(50), -- All users with this role
    
    -- Delivery tracking
    sent_at TIMESTAMPTZ,
    delivered_at TIMESTAMPTZ,
    read_at TIMESTAMPTZ,
    
    -- Source tracking
    source_entity_type VARCHAR(50),
    source_entity_id UUID,
    
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    expires_at TIMESTAMPTZ,
    
    CONSTRAINT chk_notification_recipient 
        CHECK (user_id IS NOT NULL OR store_id IS NOT NULL OR role_filter IS NOT NULL)
);

CREATE TABLE notification_preferences (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id),
    
    -- Notification categories
    low_stock_alerts BOOLEAN DEFAULT true,
    expiry_alerts BOOLEAN DEFAULT true,
    transfer_notifications BOOLEAN DEFAULT true,
    waste_approvals BOOLEAN DEFAULT false,
    system_alerts BOOLEAN DEFAULT true,
    
    -- Delivery preferences  
    email_enabled BOOLEAN DEFAULT true,
    sms_enabled BOOLEAN DEFAULT false,
    push_enabled BOOLEAN DEFAULT true,
    
    -- Timing preferences
    quiet_hours_start TIME,
    quiet_hours_end TIME,
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    
    UNIQUE(user_id)
);

-- Indexes
CREATE INDEX idx_notifications_user_unread ON notifications(user_id) WHERE read_at IS NULL;
CREATE INDEX idx_notifications_store_priority ON notifications(store_id, priority);
CREATE INDEX idx_notifications_type_priority ON notifications(type, priority);
```

### 3.4 Offline Synchronization (NEW)
```sql
CREATE TABLE sync_queues (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    device_id VARCHAR(100) NOT NULL,
    user_id UUID NOT NULL REFERENCES users(id),
    
    -- Operation details
    operation VARCHAR(20) NOT NULL, -- 'INSERT', 'UPDATE', 'DELETE'
    table_name VARCHAR(100) NOT NULL,
    record_data JSONB NOT NULL,
    local_timestamp TIMESTAMPTZ NOT NULL,
    
    -- Sync status
    sync_status VARCHAR(20) DEFAULT 'pending', -- 'pending', 'synced', 'conflict', 'failed'
    sync_attempts INTEGER DEFAULT 0,
    last_sync_attempt TIMESTAMPTZ,
    error_message TEXT,
    
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE device_registrations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    device_id VARCHAR(100) UNIQUE NOT NULL,
    user_id UUID NOT NULL REFERENCES users(id),
    
    device_name VARCHAR(255),
    platform VARCHAR(50), -- 'android', 'ios', 'web'
    app_version VARCHAR(20),
    
    -- Sync tracking
    last_sync_at TIMESTAMPTZ,
    
    -- Status
    is_active BOOLEAN DEFAULT true,
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_sync_queue_device_status ON sync_queues(device_id, sync_status);
CREATE INDEX idx_sync_queue_user_table ON sync_queues(user_id, table_name);
CREATE INDEX idx_device_registrations_user ON device_registrations(user_id);
```

### 3.5 System Configuration (NEW)
```sql
CREATE TABLE system_settings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    setting_key VARCHAR(100) UNIQUE NOT NULL,
    setting_value JSONB NOT NULL,
    setting_type VARCHAR(50) NOT NULL, -- 'string', 'number', 'boolean', 'json'
    
    description TEXT,
    is_system BOOLEAN DEFAULT false, -- Cannot be modified via UI
    store_id UUID REFERENCES stores(id), -- NULL = global setting
    
    updated_by UUID NOT NULL REFERENCES users(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Example settings:
-- low_stock_threshold_percentage: 10
-- expiry_warning_days: 7  
-- auto_reorder_enabled: true
-- currency_code: 'ETB'
-- tax_rate: 15.0

CREATE INDEX idx_system_settings_key ON system_settings(setting_key);
CREATE INDEX idx_system_settings_store ON system_settings(store_id);
```

---

## 4. Database Constraints & Business Rules

### 4.1 Enhanced Check Constraints
```sql
-- Store stock constraints
ALTER TABLE store_stock ADD CONSTRAINT chk_store_stock_positive_quantities 
    CHECK (quantity >= 0 AND reserved_quantity >= 0 AND min_quantity >= 0 AND max_quantity >= 0);
    
ALTER TABLE store_stock ADD CONSTRAINT chk_store_stock_min_max 
    CHECK (min_quantity <= max_quantity);

ALTER TABLE store_stock ADD CONSTRAINT chk_store_stock_reserved
    CHECK (reserved_quantity <= quantity);

-- Transfer constraints
ALTER TABLE transfers ADD CONSTRAINT chk_transfer_different_stores 
    CHECK (from_store_id != to_store_id);
    
ALTER TABLE transfer_items ADD CONSTRAINT chk_transfer_positive_quantities 
    CHECK (quantity_requested > 0);

-- Stock movement constraints
ALTER TABLE stock_movements ADD CONSTRAINT chk_movement_positive_quantity 
    CHECK (quantity > 0);
    
ALTER TABLE stock_movements ADD CONSTRAINT chk_movement_transfer_stores
    CHECK ((type = 'Transfer' AND from_store_id IS NOT NULL AND to_store_id IS NOT NULL)
           OR type != 'Transfer');

-- User security constraints
ALTER TABLE users ADD CONSTRAINT chk_user_password_changed
    CHECK (password_changed_at IS NOT NULL OR created_at > NOW() - INTERVAL '1 day');
```

### 4.2 Advanced Business Rules (via Triggers)
```sql
-- Auto-update stock status based on quantities
CREATE OR REPLACE FUNCTION update_stock_status()
RETURNS TRIGGER AS $$
BEGIN
    NEW.status = CASE 
        WHEN NEW.quantity <= 0 THEN 'Out of Stock'
        WHEN NEW.quantity <= NEW.min_quantity THEN 'Low Stock'
        ELSE 'Healthy'
    END;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_stock_status
    BEFORE INSERT OR UPDATE OF quantity, min_quantity ON store_stock
    FOR EACH ROW EXECUTE FUNCTION update_stock_status();

-- Auto-audit all data changes
CREATE OR REPLACE FUNCTION audit_trigger_function()
RETURNS TRIGGER AS $$
DECLARE
    old_data JSONB;
    new_data JSONB;
    changed_fields TEXT[];
BEGIN
    IF TG_OP = 'DELETE' THEN
        old_data = row_to_json(OLD)::JSONB;
        INSERT INTO audit_logs (table_name, record_id, operation, old_values, user_id, created_at)
        VALUES (TG_TABLE_NAME, OLD.id, TG_OP, old_data, COALESCE(current_setting('app.current_user_id', TRUE)::UUID, '00000000-0000-0000-0000-000000000000'), NOW());
        RETURN OLD;
    END IF;
    
    IF TG_OP = 'INSERT' THEN
        new_data = row_to_json(NEW)::JSONB;
        INSERT INTO audit_logs (table_name, record_id, operation, new_values, user_id, created_at)
        VALUES (TG_TABLE_NAME, NEW.id, TG_OP, new_data, COALESCE(current_setting('app.current_user_id', TRUE)::UUID, '00000000-0000-0000-0000-000000000000'), NOW());
        RETURN NEW;
    END IF;
    
    IF TG_OP = 'UPDATE' THEN
        old_data = row_to_json(OLD)::JSONB;
        new_data = row_to_json(NEW)::JSONB;
        
        -- Find changed fields
        SELECT ARRAY_AGG(key) INTO changed_fields
        FROM jsonb_each(old_data) o
        WHERE o.value != COALESCE((new_data -> o.key), 'null'::JSONB);
        
        IF array_length(changed_fields, 1) > 0 THEN
            INSERT INTO audit_logs (table_name, record_id, operation, old_values, new_values, changed_fields, user_id, created_at)
            VALUES (TG_TABLE_NAME, NEW.id, TG_OP, old_data, new_data, changed_fields, COALESCE(current_setting('app.current_user_id', TRUE)::UUID, '00000000-0000-0000-0000-000000000000'), NOW());
        END IF;
        RETURN NEW;
    END IF;
    
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Apply audit triggers to all major tables
CREATE TRIGGER audit_users AFTER INSERT OR UPDATE OR DELETE ON users FOR EACH ROW EXECUTE FUNCTION audit_trigger_function();
CREATE TRIGGER audit_store_stock AFTER INSERT OR UPDATE OR DELETE ON store_stock FOR EACH ROW EXECUTE FUNCTION audit_trigger_function();
CREATE TRIGGER audit_stock_movements AFTER INSERT OR UPDATE OR DELETE ON stock_movements FOR EACH ROW EXECUTE FUNCTION audit_trigger_function();
-- Add to other tables as needed
```
---

## 5. Performance Optimizations

### 5.1 Materialized Views for Reporting
```sql
-- Store stock summary (refreshed hourly)
CREATE MATERIALIZED VIEW store_stock_summary AS
SELECT 
    ss.store_id,
    s.name as store_name,
    i.item_type,
    COUNT(*) as total_items,
    COUNT(*) FILTER (WHERE ss.status = 'Low Stock') as low_stock_count,
    COUNT(*) FILTER (WHERE ss.status = 'Out of Stock') as out_of_stock_count,
    SUM(ss.quantity * ss.current_cost) as total_value,
    MAX(ss.updated_at) as last_updated
FROM store_stock ss
JOIN items i ON ss.item_id = i.id
JOIN stores s ON ss.store_id = s.id
WHERE ss.quantity > 0 AND i.deleted_at IS NULL AND s.deleted_at IS NULL
GROUP BY ss.store_id, s.name, i.item_type;

CREATE INDEX idx_store_stock_summary_store ON store_stock_summary(store_id);

-- Daily movement summary (refreshed daily)
CREATE MATERIALIZED VIEW daily_movement_summary AS
SELECT 
    DATE(sm.created_at) as movement_date,
    sm.store_id,
    i.item_type,
    sm.type as movement_type,
    COUNT(*) as transaction_count,
    SUM(sm.quantity) as total_quantity,
    SUM(sm.quantity * ss.current_cost) as total_value
FROM stock_movements sm
JOIN items i ON sm.item_id = i.id
JOIN store_stock ss ON sm.item_id = ss.item_id AND sm.store_id = ss.store_id
WHERE sm.deleted_at IS NULL
GROUP BY DATE(sm.created_at), sm.store_id, i.item_type, sm.type;

CREATE INDEX idx_daily_movement_summary_date_store ON daily_movement_summary(movement_date, store_id);
```

### 5.2 Partitioning Strategy
```sql
-- Partition audit_logs by month (for performance with large datasets)
CREATE TABLE audit_logs_template (LIKE audit_logs INCLUDING ALL);

-- Create monthly partitions for the last 2 years and next year
-- Example for 2024:
CREATE TABLE audit_logs_y2024m01 PARTITION OF audit_logs_template
FOR VALUES FROM ('2024-01-01') TO ('2024-02-01');

-- Similar for other months...

-- Partition stock_movements by year (for long-term historical data)
CREATE TABLE stock_movements_y2024 PARTITION OF stock_movements
FOR VALUES FROM ('2024-01-01') TO ('2025-01-01');
```

### 5.3 Index Strategy Summary
```sql
-- Critical performance indexes beyond those already defined

-- Composite indexes for common query patterns
CREATE INDEX idx_store_stock_item_status_qty ON store_stock(item_id, status, quantity) WHERE quantity > 0;
CREATE INDEX idx_movements_store_type_date ON stock_movements(store_id, type, created_at);
CREATE INDEX idx_transfers_stores_status_date ON transfers(from_store_id, to_store_id, status, requested_date);

-- Covering indexes for dashboard queries
CREATE INDEX idx_store_stock_dashboard_cover ON store_stock(store_id, status) 
    INCLUDE (item_id, quantity, min_quantity, current_cost);

-- Partial indexes for active records only
CREATE UNIQUE INDEX idx_items_code_active ON items(code) WHERE deleted_at IS NULL;
CREATE INDEX idx_stores_active_hierarchy ON stores(parent_store_id, store_level) WHERE is_active = true AND deleted_at IS NULL;
```

---

## 6. Security & Authorization Implementation

### 6.1 Row-Level Security (RLS)
```sql
-- Enable RLS on sensitive tables
ALTER TABLE store_stock ENABLE ROW LEVEL SECURITY;
ALTER TABLE stock_movements ENABLE ROW LEVEL SECURITY;
ALTER TABLE transfers ENABLE ROW LEVEL SECURITY;
ALTER TABLE waste_records ENABLE ROW LEVEL SECURITY;

-- Store-based access control policies
CREATE POLICY store_stock_access ON store_stock
    USING (
        store_id IN (
            SELECT store_id FROM user_store_assignments 
            WHERE user_id = current_setting('app.current_user_id')::UUID
        )
        OR EXISTS (
            SELECT 1 FROM users 
            WHERE id = current_setting('app.current_user_id')::UUID 
            AND role = 'admin'
        )
    );

-- Similar policies for other tables...
```

### 6.2 Data Encryption
```sql
-- Encrypt sensitive fields
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Example: Encrypt user phone numbers
ALTER TABLE users ADD COLUMN phone_encrypted BYTEA;

-- Function to encrypt/decrypt
CREATE OR REPLACE FUNCTION encrypt_sensitive_data(data TEXT)
RETURNS BYTEA AS $$
BEGIN
    RETURN pgp_sym_encrypt(data, current_setting('app.encryption_key'));
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

---

## 7. Migration Strategy from V1 to V2

### 7.1 Migration Steps Overview
1. **Create new schema alongside existing**
2. **Migrate canonical items data** 
3. **Create store_stock records from existing stock_items**
4. **Update foreign key references**
5. **Migrate audit and notification data**
6. **Switch application to new schema**
7. **Drop old tables after validation**

### 7.2 Critical Migration Scripts
```sql
-- Step 1: Migrate items from stock_items to canonical items table
INSERT INTO items (
    code, name, description, category, item_type, unit, 
    default_purchase_price, shelf_life_days, requires_refrigeration,
    catering_subtype, brand, model, warranty_period_months,
    is_active, created_by, created_at, updated_at
)
SELECT DISTINCT
    code, name, description, category, stock_category,
    unit, purchase_price,
    -- Map type-specific fields
    CASE WHEN stock_category = 'food' THEN 
        EXTRACT(days FROM (expiry_date - created_at))
    END,
    CASE WHEN stock_category = 'food' THEN requires_refrigeration END,
    CASE WHEN stock_category = 'catering' THEN subtype END,
    CASE WHEN stock_category = 'electronics' THEN brand END,
    CASE WHEN stock_category = 'electronics' THEN model END,
    CASE WHEN stock_category = 'electronics' THEN 
        EXTRACT(months FROM (warranty_expiry - created_at))
    END,
    true, created_by, created_at, updated_at
FROM stock_items_old
WHERE deleted_at IS NULL;

-- Step 2: Create store_stock records  
INSERT INTO store_stock (
    item_id, store_id, quantity, min_quantity, max_quantity,
    current_cost, status, created_at, updated_at
)
SELECT 
    i.id, si.store_id, si.quantity, si.min_quantity, si.max_quantity,
    si.purchase_price, si.status, si.created_at, si.updated_at
FROM stock_items_old si
JOIN items i ON i.code = si.code
WHERE si.deleted_at IS NULL;

-- Step 3: Update foreign key references in other tables
-- Update stock_movements
UPDATE stock_movements sm
SET item_id = i.id, store_id = si.store_id
FROM stock_items_old si
JOIN items i ON i.code = si.code
WHERE sm.stock_item_id = si.id;

-- Similar updates for other tables...
```

### 7.3 Data Validation Queries
```sql
-- Validate migration completeness
-- Check all items migrated
SELECT COUNT(*) as old_items FROM stock_items_old WHERE deleted_at IS NULL;
SELECT COUNT(*) as new_items FROM items WHERE deleted_at IS NULL;

-- Check store_stock records created correctly
SELECT 
    COUNT(DISTINCT si.id) as old_stock_records,
    COUNT(DISTINCT ss.id) as new_stock_records
FROM stock_items_old si
JOIN store_stock ss ON ss.item_id IN (
    SELECT i.id FROM items i WHERE i.code = si.code
)
WHERE si.deleted_at IS NULL;

-- Validate foreign key updates
SELECT COUNT(*) as unmigrated_movements
FROM stock_movements 
WHERE item_id IS NULL;
```

---

## 8. Calculated Fields & Business Logic

### 8.1 Real-time Calculated Fields
```sql
-- Stock value calculations (always calculated, never stored)
CREATE VIEW store_stock_with_values AS
SELECT 
    ss.*,
    (ss.quantity * ss.current_cost) as stock_value,
    (ss.quantity::DECIMAL / NULLIF(ss.max_quantity, 0)) as stock_fill_percentage,
    CASE 
        WHEN ss.quantity <= 0 THEN 'Out of Stock'
        WHEN ss.quantity <= ss.min_quantity THEN 'Low Stock'
        WHEN ss.quantity <= ss.reorder_point THEN 'Reorder Soon'
        ELSE 'Healthy'
    END as calculated_status
FROM store_stock ss;

-- Transfer cost calculations
CREATE VIEW transfer_summary AS
SELECT 
    t.*,
    (SELECT SUM(ti.quantity_requested * ti.unit_cost) FROM transfer_items ti WHERE ti.transfer_id = t.id) as estimated_total,
    (SELECT COUNT(*) FROM transfer_items ti WHERE ti.transfer_id = t.id) as item_count,
    (SELECT SUM(ti.quantity_received) FROM transfer_items ti WHERE ti.transfer_id = t.id) as total_received_quantity
FROM transfers t;
```

### 8.2 Cached Calculated Fields (Updated via Triggers)
```sql
-- Recipe cost calculations (cached but recalculated when ingredients change)
CREATE OR REPLACE FUNCTION update_recipe_costs()
RETURNS TRIGGER AS $$
DECLARE
    recipe_total DECIMAL(15,2);
    recipe_percentage DECIMAL(5,2);
BEGIN
    -- Calculate total food cost
    SELECT COALESCE(SUM(total_cost), 0) INTO recipe_total
    FROM recipe_ingredients 
    WHERE recipe_id = COALESCE(NEW.recipe_id, OLD.recipe_id);
    
    -- Calculate food cost percentage
    SELECT CASE 
        WHEN selling_price > 0 THEN (recipe_total / selling_price) * 100
        ELSE 0 
    END INTO recipe_percentage
    FROM recipes 
    WHERE id = COALESCE(NEW.recipe_id, OLD.recipe_id);
    
    -- Update the recipe
    UPDATE recipes 
    SET 
        total_food_cost = recipe_total,
        food_cost_percentage = recipe_percentage,
        updated_at = NOW()
    WHERE id = COALESCE(NEW.recipe_id, OLD.recipe_id);
    
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_recipe_costs
    AFTER INSERT OR UPDATE OR DELETE ON recipe_ingredients
    FOR EACH ROW EXECUTE FUNCTION update_recipe_costs();
```

---

## 9. Summary of V2 Improvements

### 9.1 Architectural Improvements
✅ **Proper Multi-Store Support**: Canonical items + store-specific stock  
✅ **Enhanced Security**: 2FA, account lockout, comprehensive audit trails  
✅ **Offline Capabilities**: Sync queues, device management, conflict resolution  
✅ **Transfer Management**: Complete workflow with approvals and tracking  
✅ **File Attachments**: Secure file storage with access controls  
✅ **Notification System**: Multi-channel notifications with preferences  
✅ **Advanced Authorization**: Row-level security, store-based permissions  

### 9.2 Data Integrity Improvements
✅ **Comprehensive Audit Logging**: All changes tracked with user attribution  
✅ **Soft Deletes with Reasons**: Reversible deletes with explanation tracking  
✅ **Movement Corrections**: Ability to correct stock movements with audit trail  
✅ **Approval Workflows**: Configurable approval thresholds and processes  
✅ **Business Rule Constraints**: Database-level enforcement of business logic  

### 9.3 Performance Improvements  
✅ **Optimized Indexing**: Composite and partial indexes for common queries  
✅ **Materialized Views**: Pre-calculated summaries for reporting  
✅ **Partitioning Strategy**: Handle large datasets efficiently  
✅ **Query Optimization**: Proper joins and covering indexes  

### 9.4 Operational Improvements
✅ **System Configuration**: Centralized settings management  
✅ **Device Management**: Mobile device registration and sync tracking  
✅ **Notification Preferences**: User-configurable alert preferences  
✅ **Store Hierarchy**: Parent-child store relationships  
✅ **Enhanced Reporting**: Better data structure for analytics  

---

**Document Version**: 2.0  
**Major Changes**: Separated canonical items from store stock, added comprehensive audit/security features  
**Migration Required**: HIGH complexity - careful planning and validation needed  
**Benefits**: Production-ready multi-store system with modern security and audit capabilities  
**Next Step**: Implement API_REQUIREMENTS_V2.md to support new database structure