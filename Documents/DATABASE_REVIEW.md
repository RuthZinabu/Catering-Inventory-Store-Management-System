# Database Design Review & Analysis
**Catering Inventory Store Management System - Version 2 Updates**

## Overview
This document reviews the existing DATABASE_DESIGN.md against modern backend requirements and identifies all changes needed for the updated database schema. The review focuses on separation of canonical items vs store-specific stock levels, enhanced security, audit requirements, and multi-store operations.

---

## 1. Critical Architecture Changes Required

### 1.1 **MAJOR**: Separation of Canonical Items vs Store-Specific Stock
**Current Issue**: Single `stock_items` table mixes item definitions with store-specific quantities
**Required Change**: Split into two tables for proper multi-store inventory management

#### Current Design Problems:
```sql
-- PROBLEMATIC: Single table approach
CREATE TABLE stock_items (
    id UUID PRIMARY KEY,
    name VARCHAR(255),
    quantity DECIMAL(15,3), -- ❌ Store-specific data mixed with canonical data
    store_id UUID,          -- ❌ Creates duplicate item definitions per store
    ...
);
```

#### Required New Design:
```sql
-- ✅ Canonical item definitions (shared across all stores)
CREATE TABLE items (
    id UUID PRIMARY KEY,
    code VARCHAR(100) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    category VARCHAR(100),
    item_type item_type_enum, -- 'food', 'catering', 'electronics'
    unit VARCHAR(20),
    -- Item-specific metadata only
    ...
);

-- ✅ Store-specific stock levels (separate table)
CREATE TABLE store_stock (
    id UUID PRIMARY KEY,
    item_id UUID REFERENCES items(id),
    store_id UUID REFERENCES stores(id),
    quantity DECIMAL(15,3) NOT NULL DEFAULT 0,
    min_quantity DECIMAL(15,3),
    max_quantity DECIMAL(15,3),
    reorder_point DECIMAL(15,3),
    location VARCHAR(255), -- shelf/bin location within store
    status stock_status_enum,
    last_count_date DATE,
    UNIQUE(item_id, store_id)
);
```

### 1.2 **MAJOR**: Enhanced Multi-Store Authorization
**Current Issue**: Basic store_id filtering insufficient for complex multi-store operations
**Required Change**: Proper store hierarchy and permission matrix

#### New Requirements:
- Store managers can view their store + supervised stores
- Regional managers can view multiple stores  
- Admin users can view all stores
- Cross-store transfer permissions
- Store-specific user assignments

### 1.3 **MAJOR**: Audit Trail & Change Tracking
**Current Issue**: Limited audit capabilities
**Required Change**: Comprehensive audit logging with proper retention

#### Required Tables:
```sql
-- New audit trail table
CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    table_name VARCHAR(100) NOT NULL,
    record_id UUID NOT NULL,
    operation VARCHAR(20) NOT NULL, -- 'INSERT', 'UPDATE', 'DELETE'
    old_values JSONB,
    new_values JSONB,
    changed_fields TEXT[],
    user_id UUID NOT NULL REFERENCES users(id),
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

---

## 2. Table-by-Table Change Analysis

### 2.1 **users** Table - MODERATE Changes Required

#### Current State:
✅ **Keep**: Basic user fields, roles, permissions
❌ **Missing**: Enhanced security fields, multi-store assignments

#### Required Changes:
```sql
ALTER TABLE users ADD COLUMN two_factor_enabled BOOLEAN DEFAULT false;
ALTER TABLE users ADD COLUMN two_factor_secret VARCHAR(255);
ALTER TABLE users ADD COLUMN failed_login_attempts INTEGER DEFAULT 0;
ALTER TABLE users ADD COLUMN locked_until TIMESTAMPTZ;
ALTER TABLE users ADD COLUMN password_changed_at TIMESTAMPTZ;
ALTER TABLE users ADD COLUMN must_change_password BOOLEAN DEFAULT false;

-- New table for user-store assignments  
CREATE TABLE user_store_assignments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    store_id UUID NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
    role_in_store VARCHAR(50) NOT NULL, -- 'manager', 'supervisor', 'staff'
    can_transfer_to BOOLEAN DEFAULT false,
    can_transfer_from BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, store_id)
);
```

### 2.2 **stores** Table - MINOR Changes Required

#### Current State:
✅ **Keep**: Basic store information, manager assignment
✅ **Add**: Store hierarchy support

#### Required Changes:
```sql
ALTER TABLE stores ADD COLUMN parent_store_id UUID REFERENCES stores(id);
ALTER TABLE stores ADD COLUMN store_level INTEGER DEFAULT 0; -- 0=main, 1=branch, 2=sub-branch
ALTER TABLE stores ADD COLUMN timezone VARCHAR(50) DEFAULT 'UTC';
ALTER TABLE stores ADD COLUMN operating_hours JSONB;
ALTER TABLE stores ADD COLUMN settings JSONB DEFAULT '{}';

CREATE INDEX idx_stores_parent ON stores(parent_store_id);
CREATE INDEX idx_stores_level ON stores(store_level);
```

### 2.3 **stock_items** → **items** + **store_stock** - MAJOR Restructure

#### Required New Tables:
```sql
-- DROP the existing stock_items table approach
-- CREATE new canonical items table
CREATE TYPE item_type_enum AS ENUM ('food', 'catering', 'electronics');

CREATE TABLE items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(100) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    category VARCHAR(100) NOT NULL,
    item_type item_type_enum NOT NULL,
    unit VARCHAR(20) NOT NULL,
    default_purchase_price DECIMAL(15,2),
    
    -- Food-specific canonical fields
    shelf_life_days INTEGER,
    requires_refrigeration BOOLEAN DEFAULT false,
    
    -- Catering-specific canonical fields  
    catering_subtype catering_subtype_enum,
    
    -- Electronics-specific canonical fields
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

-- Store-specific stock levels
CREATE TABLE store_stock (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    item_id UUID NOT NULL REFERENCES items(id),
    store_id UUID NOT NULL REFERENCES stores(id),
    
    -- Quantities
    quantity DECIMAL(15,3) NOT NULL DEFAULT 0,
    reserved_quantity DECIMAL(15,3) NOT NULL DEFAULT 0,
    available_quantity DECIMAL(15,3) GENERATED ALWAYS AS (quantity - reserved_quantity) STORED,
    
    -- Thresholds (store-specific)
    min_quantity DECIMAL(15,3) NOT NULL DEFAULT 0,
    max_quantity DECIMAL(15,3) NOT NULL DEFAULT 0,
    reorder_point DECIMAL(15,3),
    
    -- Location within store
    location_code VARCHAR(50), -- A1-B2, FREEZER-01, etc.
    location_description VARCHAR(255),
    
    -- Store-specific pricing
    current_cost DECIMAL(15,2),
    last_cost DECIMAL(15,2),
    
    -- Status
    status stock_status_enum NOT NULL DEFAULT 'Healthy',
    last_counted_at TIMESTAMPTZ,
    last_counted_by UUID REFERENCES users(id),
    
    -- Audit
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    UNIQUE(item_id, store_id)
);
```

### 2.4 **stock_movements** Table - MAJOR Enhancements

#### Current Issues:
❌ Missing correction capabilities
❌ No soft delete support
❌ Limited approval workflow support

#### Required Changes:
```sql
-- Enhance existing table
ALTER TABLE stock_movements ADD COLUMN is_correction BOOLEAN DEFAULT false;
ALTER TABLE stock_movements ADD COLUMN corrects_movement_id UUID REFERENCES stock_movements(id);
ALTER TABLE stock_movements ADD COLUMN correction_reason TEXT;
ALTER TABLE stock_movements ADD COLUMN requires_approval BOOLEAN DEFAULT false;
ALTER TABLE stock_movements ADD COLUMN approved_by UUID REFERENCES users(id);
ALTER TABLE stock_movements ADD COLUMN approved_at TIMESTAMPTZ;
ALTER TABLE stock_movements ADD COLUMN rejection_reason TEXT;
ALTER TABLE stock_movements ADD COLUMN deleted_at TIMESTAMPTZ;
ALTER TABLE stock_movements ADD COLUMN deleted_by UUID REFERENCES users(id);
ALTER TABLE stock_movements ADD COLUMN deletion_reason TEXT;

-- Update to reference new tables
ALTER TABLE stock_movements DROP COLUMN stock_item_id;
ALTER TABLE stock_movements ADD COLUMN item_id UUID NOT NULL REFERENCES items(id);
ALTER TABLE stock_movements ADD COLUMN store_id UUID NOT NULL REFERENCES stores(id);

-- Add offline sync support
ALTER TABLE stock_movements ADD COLUMN offline_sync_id UUID UNIQUE;
ALTER TABLE stock_movements ADD COLUMN offline_created_at TIMESTAMPTZ;
ALTER TABLE stock_movements ADD COLUMN sync_status VARCHAR(20) DEFAULT 'synced';
```

### 2.5 **purchase_orders** Table - MODERATE Enhancements

#### Required Changes:
```sql
-- Add approval workflow
ALTER TABLE purchase_orders ADD COLUMN requires_approval BOOLEAN DEFAULT false;
ALTER TABLE purchase_orders ADD COLUMN approval_threshold DECIMAL(15,2);
ALTER TABLE purchase_orders ADD COLUMN approved_at TIMESTAMPTZ;
ALTER TABLE purchase_orders ADD COLUMN rejection_reason TEXT;

-- Add receiving workflow
ALTER TABLE purchase_orders ADD COLUMN receiving_status VARCHAR(20) DEFAULT 'pending';
ALTER TABLE purchase_orders ADD COLUMN partially_received_at TIMESTAMPTZ;
ALTER TABLE purchase_orders ADD COLUMN fully_received_at TIMESTAMPTZ;

-- Add store assignment
ALTER TABLE purchase_orders ADD COLUMN destination_store_id UUID REFERENCES stores(id);

-- Update purchase_order_items to use new item structure
ALTER TABLE purchase_order_items DROP COLUMN stock_item_id;
ALTER TABLE purchase_order_items ADD COLUMN item_id UUID NOT NULL REFERENCES items(id);
ALTER TABLE purchase_order_items ADD COLUMN received_into_store_id UUID REFERENCES stores(id);
```

### 2.6 **NEW**: Transfer Management Tables

#### Required New Tables:
```sql
CREATE TYPE transfer_status_enum AS ENUM ('pending', 'approved', 'in_transit', 'received', 'cancelled');

CREATE TABLE transfers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    transfer_number VARCHAR(50) UNIQUE NOT NULL,
    from_store_id UUID NOT NULL REFERENCES stores(id),
    to_store_id UUID NOT NULL REFERENCES stores(id),
    
    status transfer_status_enum NOT NULL DEFAULT 'pending',
    priority VARCHAR(20) DEFAULT 'normal', -- 'low', 'normal', 'high', 'urgent'
    
    -- Workflow
    requested_by UUID NOT NULL REFERENCES users(id),
    approved_by UUID REFERENCES users(id),
    shipped_by UUID REFERENCES users(id),
    received_by UUID REFERENCES users(id),
    
    -- Dates
    requested_date DATE NOT NULL,
    required_date DATE,
    approved_date DATE,
    shipped_date DATE,
    received_date DATE,
    
    notes TEXT,
    shipping_notes TEXT,
    
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE transfer_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    transfer_id UUID NOT NULL REFERENCES transfers(id) ON DELETE CASCADE,
    item_id UUID NOT NULL REFERENCES items(id),
    
    quantity_requested DECIMAL(15,3) NOT NULL,
    quantity_approved DECIMAL(15,3),
    quantity_shipped DECIMAL(15,3),
    quantity_received DECIMAL(15,3),
    
    unit_cost DECIMAL(15,2),
    notes TEXT,
    
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

### 2.7 **waste_records** Table - MODERATE Enhancements

#### Required Changes:
```sql
-- Update to new item structure
ALTER TABLE waste_records DROP COLUMN stock_item_id;
ALTER TABLE waste_records ADD COLUMN item_id UUID NOT NULL REFERENCES items(id);
ALTER TABLE waste_records ADD COLUMN store_id UUID NOT NULL REFERENCES stores(id);

-- Add approval workflow
ALTER TABLE waste_records ADD COLUMN requires_approval BOOLEAN DEFAULT false;
ALTER TABLE waste_records ADD COLUMN approval_threshold DECIMAL(15,2);
ALTER TABLE waste_records ADD COLUMN approved_at TIMESTAMPTZ;
ALTER TABLE waste_records ADD COLUMN rejection_reason TEXT;

-- Add attachment support
ALTER TABLE waste_records ADD COLUMN attachments JSONB DEFAULT '[]';
ALTER TABLE waste_records ADD COLUMN photo_evidence_urls TEXT[];
```

### 2.8 **NEW**: File Attachments Table

#### Required New Table:
```sql
CREATE TABLE attachments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    filename VARCHAR(255) NOT NULL,
    original_filename VARCHAR(255) NOT NULL,
    mime_type VARCHAR(100) NOT NULL,
    file_size BIGINT NOT NULL,
    storage_path TEXT NOT NULL,
    
    -- Associations
    entity_type VARCHAR(50) NOT NULL, -- 'waste_record', 'purchase_order', etc.
    entity_id UUID NOT NULL,
    
    -- Security
    uploaded_by UUID NOT NULL REFERENCES users(id),
    is_public BOOLEAN DEFAULT false,
    access_permissions JSONB DEFAULT '{}',
    
    -- Metadata
    description TEXT,
    tags TEXT[],
    
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ
);

CREATE INDEX idx_attachments_entity ON attachments(entity_type, entity_id);
```

### 2.9 **NEW**: Notification Management Tables

#### Required New Tables:
```sql
CREATE TYPE notification_type_enum AS ENUM ('system', 'email', 'sms', 'push');
CREATE TYPE notification_priority_enum AS ENUM ('low', 'normal', 'high', 'urgent');

CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    type notification_type_enum NOT NULL,
    priority notification_priority_enum NOT NULL DEFAULT 'normal',
    
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    
    -- Recipients  
    user_id UUID REFERENCES users(id),
    store_id UUID REFERENCES stores(id),
    role_filter VARCHAR(50), -- Send to all users with this role
    
    -- Delivery
    sent_at TIMESTAMPTZ,
    delivered_at TIMESTAMPTZ,
    read_at TIMESTAMPTZ,
    
    -- Metadata
    source_entity_type VARCHAR(50),
    source_entity_id UUID,
    
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    expires_at TIMESTAMPTZ
);

CREATE TABLE notification_preferences (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id),
    
    -- Preference settings
    low_stock_alerts BOOLEAN DEFAULT true,
    expiry_alerts BOOLEAN DEFAULT true,
    transfer_notifications BOOLEAN DEFAULT true,
    waste_approvals BOOLEAN DEFAULT false,
    system_alerts BOOLEAN DEFAULT true,
    
    -- Delivery preferences
    email_enabled BOOLEAN DEFAULT true,
    sms_enabled BOOLEAN DEFAULT false,
    push_enabled BOOLEAN DEFAULT true,
    
    -- Timing
    quiet_hours_start TIME,
    quiet_hours_end TIME,
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    
    UNIQUE(user_id)
);
```

### 2.10 **NEW**: Offline Synchronization Support

#### Required New Tables:
```sql
CREATE TABLE sync_queues (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    device_id VARCHAR(100) NOT NULL,
    user_id UUID NOT NULL REFERENCES users(id),
    
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
    
    last_sync_at TIMESTAMPTZ,
    is_active BOOLEAN DEFAULT true,
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

---

## 3. Index Strategy Updates

### 3.1 New Required Indexes
```sql
-- Multi-store performance indexes
CREATE INDEX idx_store_stock_store_item ON store_stock(store_id, item_id);
CREATE INDEX idx_store_stock_low_stock ON store_stock(store_id) WHERE status = 'Low Stock';
CREATE INDEX idx_store_stock_expiring ON store_stock(store_id, updated_at) 
    WHERE status IN ('Expired', 'Expiring Soon');

-- Transfer management indexes  
CREATE INDEX idx_transfers_from_store ON transfers(from_store_id, status);
CREATE INDEX idx_transfers_to_store ON transfers(to_store_id, status);
CREATE INDEX idx_transfers_status_date ON transfers(status, requested_date);

-- Audit and sync indexes
CREATE INDEX idx_audit_logs_table_record ON audit_logs(table_name, record_id);
CREATE INDEX idx_audit_logs_user_date ON audit_logs(user_id, created_at);
CREATE INDEX idx_sync_queue_device_status ON sync_queues(device_id, sync_status);

-- Notification indexes
CREATE INDEX idx_notifications_user_unread ON notifications(user_id) WHERE read_at IS NULL;
CREATE INDEX idx_notifications_store_priority ON notifications(store_id, priority);
```

### 3.2 Removed/Updated Indexes
```sql
-- Remove old stock_items indexes (table restructured)
-- DROP INDEX idx_stock_items_*;

-- Update movement indexes for new structure  
DROP INDEX IF EXISTS idx_stock_movements_item;
CREATE INDEX idx_stock_movements_item_store ON stock_movements(item_id, store_id);
```

---

## 4. Constraint Updates

### 4.1 New Business Rule Constraints
```sql
-- Store stock constraints
ALTER TABLE store_stock ADD CONSTRAINT chk_positive_quantities 
    CHECK (quantity >= 0 AND min_quantity >= 0 AND max_quantity >= 0);
    
ALTER TABLE store_stock ADD CONSTRAINT chk_min_max_quantities 
    CHECK (min_quantity <= max_quantity);

-- Transfer constraints
ALTER TABLE transfers ADD CONSTRAINT chk_different_stores 
    CHECK (from_store_id != to_store_id);
    
ALTER TABLE transfer_items ADD CONSTRAINT chk_positive_transfer_quantities 
    CHECK (quantity_requested > 0);

-- Notification constraints
ALTER TABLE notifications ADD CONSTRAINT chk_notification_recipient
    CHECK (user_id IS NOT NULL OR store_id IS NOT NULL OR role_filter IS NOT NULL);
```

---

## 5. Migration Strategy

### 5.1 Data Migration Required
1. **Split stock_items into items + store_stock**
   - Extract canonical item data to `items` table
   - Create store_stock records for each item/store combination
   - Migrate quantities and store-specific data

2. **Update all foreign key references**
   - Update stock_movements.stock_item_id → item_id
   - Update purchase_order_items.stock_item_id → item_id  
   - Update waste_records.stock_item_id → item_id
   - Update recipe_ingredients.stock_item_id → item_id

3. **Create store hierarchy data**
   - Assign parent_store_id relationships
   - Set store_level values
   - Create initial user_store_assignments

### 5.2 Zero-Downtime Migration Steps
1. Create new tables alongside existing ones
2. Create data migration scripts with validation
3. Run migration in batches during low-traffic periods
4. Update application to use new schema
5. Drop old tables after validation

---

## 6. Performance Impact Assessment

### 6.1 Query Performance Changes

#### **Improved Performance**:
- Multi-store queries (proper indexing by store)
- Item searches (canonical item table)
- Transfer operations (dedicated tables)
- Audit queries (proper indexing)

#### **Potential Performance Concerns**:
- Stock level queries now require JOIN (items + store_stock)
- Movement queries more complex with multi-table structure
- Notification queries with complex recipient logic

### 6.2 Mitigation Strategies
```sql
-- Materialized views for common queries
CREATE MATERIALIZED VIEW store_stock_summary AS
SELECT 
    ss.store_id,
    i.item_type,
    COUNT(*) as total_items,
    COUNT(*) FILTER (WHERE ss.status = 'Low Stock') as low_stock_count,
    SUM(ss.quantity * ss.current_cost) as total_value
FROM store_stock ss
JOIN items i ON ss.item_id = i.id
WHERE ss.quantity > 0
GROUP BY ss.store_id, i.item_type;

-- Refresh strategy: Real-time for critical data, scheduled for reports
```

---

## 7. Security Enhancement Review

### 7.1 Authentication Improvements
- ✅ Added two-factor authentication support
- ✅ Added account lockout protection  
- ✅ Added password policy enforcement
- ✅ Added session management enhancements

### 7.2 Authorization Improvements  
- ✅ Added granular store-level permissions
- ✅ Added transfer permission matrix
- ✅ Added approval workflow permissions
- ✅ Added audit trail access controls

### 7.3 Data Protection Improvements
- ✅ Added comprehensive audit logging
- ✅ Added soft delete with reason tracking  
- ✅ Added attachment security controls
- ✅ Added data retention policies support

---

## 8. Compliance & Audit Requirements

### 8.1 Audit Trail Coverage
- ✅ All data modifications logged
- ✅ User actions tracked with IP/user agent
- ✅ Approval workflows audited
- ✅ System configuration changes logged

### 8.2 Data Retention Policies
- Stock movements: 7 years minimum
- Audit logs: 5 years minimum  
- Notifications: 90 days default
- Sync queues: 30 days after successful sync

### 8.3 Compliance Support
- Food safety: Batch tracking, expiry monitoring
- Financial: Purchase audit trails, waste documentation
- Operational: Transfer approvals, user activity logs

---

## Summary

### **Critical Changes Required**:
1. **MAJOR**: Split stock_items → items + store_stock
2. **MAJOR**: Add comprehensive audit logging
3. **MAJOR**: Implement transfer management system
4. **MAJOR**: Add offline synchronization support
5. **MODERATE**: Enhance user security features
6. **MODERATE**: Add notification management
7. **MODERATE**: Add file attachment system

### **Benefits of Changes**:
- ✅ Proper multi-store inventory separation
- ✅ Enhanced security and audit capabilities  
- ✅ Support for offline mobile operations
- ✅ Comprehensive approval workflows
- ✅ Better performance with proper indexing
- ✅ Modern notification system
- ✅ File attachment capabilities

### **Migration Complexity**: **HIGH** 
- Requires careful data migration
- Zero-downtime deployment strategy needed
- Comprehensive testing required
- Phased rollout recommended

---

**Document Status**: Complete review of existing database design  
**Criticality**: HIGH - Foundational changes required for production system  
**Next Step**: Implement DATABASE_DESIGN_V2.md with all identified changes