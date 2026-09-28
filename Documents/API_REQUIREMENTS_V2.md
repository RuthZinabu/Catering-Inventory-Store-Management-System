# API Requirements V2
**Catering Inventory Store Management System - Updated API Design**

## Overview
This document defines the updated REST API requirements based on the new DATABASE_DESIGN_V2.md schema. The API design supports the separation of canonical items vs store-specific stock, enhanced multi-store operations, comprehensive audit trails, offline synchronization, and modern security features.

---

## 1. API Architecture Changes

### 1.1 Core Architectural Updates
**CHANGED**: Separation of item management from store-specific stock operations
- **Items API**: Manage canonical item definitions (shared across stores)
- **Store Stock API**: Manage store-specific quantities, thresholds, and locations  
- **Multi-Store Operations**: Cross-store transfers, consolidated reporting
- **Offline Sync API**: Handle mobile app synchronization scenarios

### 1.2 Authentication & Authorization Enhancements
**NEW**: Enhanced security and store-based access control
- **JWT with 2FA support**: Multi-factor authentication endpoints
- **Store-based permissions**: Users can access only assigned stores  
- **Role-based store access**: Different roles per store (manager/supervisor/staff)
- **Audit trail integration**: All API operations logged with user context

### 1.3 Offline-First Design
**NEW**: Support for mobile offline operations
- **Sync endpoints**: Upload/download data changes during offline periods
- **Conflict resolution**: Handle data conflicts when multiple users modify same records
- **Device management**: Register and manage mobile devices per user

---

## 2. Authentication & User Management APIs

### 2.1 Enhanced Authentication Endpoints
```http
# Standard authentication  
POST   /api/auth/login
POST   /api/auth/logout
POST   /api/auth/refresh
GET    /api/auth/profile

# Two-factor authentication (NEW)
POST   /api/auth/2fa/setup        # Generate 2FA secret
POST   /api/auth/2fa/verify       # Verify 2FA code during setup
POST   /api/auth/2fa/disable      # Disable 2FA
POST   /api/auth/login/2fa        # Complete login with 2FA code

# Password security (NEW)
POST   /api/auth/password/change  # Change password (requires current password)
POST   /api/auth/password/reset   # Request password reset
POST   /api/auth/password/confirm # Confirm password reset with token

# Account security (NEW)  
GET    /api/auth/sessions         # List active sessions
DELETE /api/auth/sessions/:id     # Revoke specific session
DELETE /api/auth/sessions/all     # Revoke all sessions

# Device management (NEW)
POST   /api/auth/devices/register # Register mobile device
GET    /api/auth/devices          # List user's registered devices  
DELETE /api/auth/devices/:id      # Unregister device
PUT    /api/auth/devices/:id      # Update device info
```

#### Example Login Request with 2FA:
```json
POST /api/auth/login
{
    "email": "manager@store.com",
    "password": "secure_password",
    "device_name": "iPhone 13 Pro",
    "two_factor_code": "123456"  // Optional, required if 2FA enabled
}

Response:
{
    "success": true,
    "data": {
        "access_token": "jwt_token_here",
        "refresh_token": "refresh_token_here",
        "expires_in": 3600,
        "user": {
            "id": "uuid",
            "email": "manager@store.com", 
            "name": "Store Manager",
            "role": "store_manager",
            "permissions": ["inventory.view", "inventory.update", ...],
            "assigned_stores": [
                {
                    "store_id": "store_uuid",
                    "store_name": "Main Warehouse", 
                    "role_in_store": "manager",
                    "can_transfer_to": true,
                    "can_transfer_from": true
                }
            ]
        }
    }
}
```

### 2.2 User & Store Assignment Management
```http
# User management (Enhanced)
GET    /api/users                    # List users with store assignments
GET    /api/users/:id               # Get user details with store permissions
POST   /api/users                   # Create user with initial store assignments  
PUT    /api/users/:id               # Update user details
DELETE /api/users/:id               # Deactivate user
PUT    /api/users/:id/activate      # Reactivate user
PUT    /api/users/:id/lock          # Lock user account
PUT    /api/users/:id/unlock        # Unlock user account

# Store assignments (NEW)
GET    /api/users/:id/stores        # Get user's store assignments
POST   /api/users/:id/stores        # Assign user to store
PUT    /api/users/:id/stores/:store_id  # Update store role/permissions
DELETE /api/users/:id/stores/:store_id  # Remove store assignment

# Bulk operations (NEW)
POST   /api/users/bulk/assign       # Assign multiple users to store
POST   /api/users/bulk/transfer     # Transfer users between stores
```

---

## 3. Canonical Items Management APIs

### 3.1 Items CRUD (Separated from Store Stock)
```http
# Canonical item management
GET    /api/items                   # List canonical items (shared across stores)
GET    /api/items/:id              # Get canonical item details
POST   /api/items                  # Create new canonical item
PUT    /api/items/:id              # Update canonical item
DELETE /api/items/:id              # Soft delete canonical item
PUT    /api/items/:id/restore      # Restore deleted item

# Item categories & types
GET    /api/items/categories       # Get available categories by type  
GET    /api/items/types            # Get available item types (food/catering/electronics)

# Bulk operations  
POST   /api/items/bulk/create      # Bulk create items
POST   /api/items/bulk/update      # Bulk update items
POST   /api/items/import           # Import items from CSV/Excel
GET    /api/items/export           # Export items to CSV/Excel

# Item search & filtering
GET    /api/items/search           # Advanced search with filters
```

#### Example Item Creation:
```json
POST /api/items
{
    "code": "FOOD-MEAT-001",
    "name": "Chicken Breast (Boneless)",
    "description": "Fresh boneless chicken breast",
    "category": "Meat & Poultry", 
    "item_type": "food",
    "unit": "kg",
    "default_purchase_price": 150.00,
    "shelf_life_days": 7,
    "requires_refrigeration": true
}

Response:
{
    "success": true,
    "data": {
        "id": "item_uuid",
        "code": "FOOD-MEAT-001",
        "name": "Chicken Breast (Boneless)",
        // ... other fields
        "created_at": "2024-01-15T10:30:00Z"
    }
}
```

---

## 4. Store Stock Management APIs

### 4.1 Store-Specific Stock Operations  
```http
# Store stock management (NEW - separated from items)
GET    /api/stores/:store_id/stock           # List stock items in specific store
GET    /api/stores/:store_id/stock/:item_id  # Get store-specific stock details
POST   /api/stores/:store_id/stock           # Add item to store inventory
PUT    /api/stores/:store_id/stock/:item_id  # Update store stock levels/thresholds
DELETE /api/stores/:store_id/stock/:item_id  # Remove item from store

# Stock level operations
PUT    /api/stores/:store_id/stock/:item_id/adjust      # Manual quantity adjustment
POST   /api/stores/:store_id/stock/:item_id/reserve     # Reserve quantity
POST   /api/stores/:store_id/stock/:item_id/unreserve   # Release reservation

# Store stock queries
GET    /api/stores/:store_id/stock/low        # Low stock items in store
GET    /api/stores/:store_id/stock/expiring   # Items expiring soon  
GET    /api/stores/:store_id/stock/out        # Out of stock items
GET    /api/stores/:store_id/stock/summary    # Stock summary by category

# Multi-store stock views (NEW)  
GET    /api/stock/consolidated                # Consolidated view across user's stores
GET    /api/stock/item/:item_id/stores       # Same item across all stores
POST   /api/stock/search/multi-store         # Search across multiple stores
```

#### Example Store Stock Addition:
```json
POST /api/stores/main-warehouse-uuid/stock  
{
    "item_id": "item_uuid",
    "initial_quantity": 100.0,
    "min_quantity": 20.0,
    "max_quantity": 500.0,
    "reorder_point": 30.0,
    "current_cost": 150.00,
    "location_code": "A1-B2",
    "location_description": "Freezer Section A, Row 1, Bin 2"
}

Response:
{
    "success": true,
    "data": {
        "id": "store_stock_uuid",
        "item": {
            "id": "item_uuid",
            "code": "FOOD-MEAT-001", 
            "name": "Chicken Breast (Boneless)"
        },
        "store_id": "main-warehouse-uuid",
        "quantity": 100.0,
        "available_quantity": 100.0,
        "reserved_quantity": 0.0,
        "status": "Healthy",
        // ... other fields
    }
}
```

### 4.2 Stock Movement Tracking (Enhanced)
```http
# Stock movements (Enhanced with corrections)
GET    /api/stores/:store_id/movements        # Store-specific movements
GET    /api/movements/:id                     # Get movement details
POST   /api/movements                         # Record new movement
POST   /api/movements/:id/correct             # Create correction movement
DELETE /api/movements/:id                     # Soft delete movement (with reason)

# Movement approvals (NEW)
GET    /api/movements/pending-approval        # Movements requiring approval
POST   /api/movements/:id/approve             # Approve movement
POST   /api/movements/:id/reject              # Reject movement

# Movement queries
GET    /api/movements/audit-trail/:item_id    # Complete audit trail for item
GET    /api/movements/user/:user_id           # Movements by specific user
POST   /api/movements/search                  # Advanced movement search
GET    /api/movements/summary                 # Movement summary reports
```

---

## 5. Transfer Management APIs (NEW)

### 5.1 Inter-Store Transfer Operations
```http
# Transfer management
GET    /api/transfers                         # List transfers (filtered by user stores)
GET    /api/transfers/:id                     # Get transfer details
POST   /api/transfers                         # Create transfer request
PUT    /api/transfers/:id                     # Update transfer
DELETE /api/transfers/:id                     # Cancel transfer

# Transfer workflow
POST   /api/transfers/:id/approve             # Approve transfer
POST   /api/transfers/:id/ship                # Mark as shipped
POST   /api/transfers/:id/receive             # Mark as received
POST   /api/transfers/:id/reject              # Reject transfer

# Transfer items
GET    /api/transfers/:id/items               # Get transfer items
POST   /api/transfers/:id/items               # Add items to transfer
PUT    /api/transfers/:id/items/:item_id      # Update transfer item quantity
DELETE /api/transfers/:id/items/:item_id      # Remove item from transfer

# Transfer queries
GET    /api/transfers/pending                 # Pending approvals for user's stores
GET    /api/transfers/in-transit              # Transfers in transit to user's stores  
GET    /api/transfers/history                 # Transfer history
```

#### Example Transfer Creation:
```json
POST /api/transfers
{
    "from_store_id": "main-warehouse-uuid",
    "to_store_id": "branch-store-uuid", 
    "priority": "normal",
    "required_date": "2024-01-20",
    "notes": "Weekly stock replenishment",
    "items": [
        {
            "item_id": "item_uuid",
            "quantity_requested": 50.0
        },
        {
            "item_id": "item2_uuid", 
            "quantity_requested": 25.0
        }
    ]
}

Response:
{
    "success": true,
    "data": {
        "id": "transfer_uuid",
        "transfer_number": "TRF-2024-001",
        "from_store": {
            "id": "main-warehouse-uuid",
            "name": "Main Warehouse"
        },
        "to_store": {
            "id": "branch-store-uuid", 
            "name": "Branch Store"
        },
        "status": "pending",
        "items": [...],
        // ... other fields
    }
}
```

---

## 6. Purchase Management APIs (Enhanced)

### 6.1 Purchase Orders with Store Assignment
```http
# Purchase orders (Enhanced)  
GET    /api/purchase-orders                   # List POs for user's stores
GET    /api/purchase-orders/:id              # Get PO details
POST   /api/purchase-orders                  # Create PO for specific store
PUT    /api/purchase-orders/:id              # Update PO
DELETE /api/purchase-orders/:id              # Cancel PO

# Purchase approval workflow (NEW)
GET    /api/purchase-orders/pending-approval # POs requiring approval
POST   /api/purchase-orders/:id/approve      # Approve PO
POST   /api/purchase-orders/:id/reject       # Reject PO

# Goods receiving (Enhanced)
POST   /api/purchase-orders/:id/receive      # Receive goods into store
PUT    /api/purchase-orders/:id/items/:item_id/receive  # Partial receive item
GET    /api/purchase-orders/:id/receiving-history       # Receiving history

# Purchase queries
GET    /api/purchase-orders/by-store/:store_id  # POs for specific store
GET    /api/purchase-orders/by-supplier/:supplier_id  # POs by supplier
```

### 6.2 Supplier Management (Minor Updates)
```http
# Suppliers (Unchanged core functionality)
GET    /api/suppliers                         # List suppliers
GET    /api/suppliers/:id                     # Get supplier details  
POST   /api/suppliers                         # Create supplier
PUT    /api/suppliers/:id                     # Update supplier
DELETE /api/suppliers/:id                     # Soft delete supplier

# Supplier performance (NEW)
GET    /api/suppliers/:id/performance         # Delivery performance metrics
GET    /api/suppliers/:id/purchase-history    # Purchase history with supplier
```

---

## 7. Waste & Expiry Management APIs (Enhanced)

### 7.1 Store-Specific Waste Tracking
```http
# Waste records (Enhanced with store context)
GET    /api/stores/:store_id/waste            # Waste records for store
GET    /api/waste-records/:id                 # Get waste record details
POST   /api/waste-records                     # Create waste record
PUT    /api/waste-records/:id                 # Update waste record  
DELETE /api/waste-records/:id                 # Delete waste record

# Waste approval workflow (NEW)
GET    /api/waste-records/pending-approval    # Waste records requiring approval
POST   /api/waste-records/:id/approve         # Approve waste record
POST   /api/waste-records/:id/reject          # Reject waste record

# File attachments (NEW)
POST   /api/waste-records/:id/attachments     # Upload photo evidence
GET    /api/waste-records/:id/attachments     # Get attached files
DELETE /api/waste-records/:id/attachments/:file_id  # Delete attachment

# Waste analysis
GET    /api/waste-records/analysis/by-reason  # Waste analysis by reason
GET    /api/waste-records/analysis/by-category # Waste analysis by item category
```

### 7.2 Expiry Management (Enhanced)
```http
# Expiry tracking (Store-specific) 
GET    /api/stores/:store_id/expiring         # Expiring items in store
GET    /api/stores/:store_id/expired          # Expired items in store
PUT    /api/store-stock/:id/extend-expiry     # Extend expiry date (with reason)

# Expiry notifications  
GET    /api/expiry/alerts                     # Expiry alerts for user's stores
POST   /api/expiry/alerts/:id/acknowledge     # Acknowledge expiry alert
```

---

## 8. Notification Management APIs (NEW)

### 8.1 Notification System
```http
# Notifications
GET    /api/notifications                     # Get user's notifications
GET    /api/notifications/unread              # Get unread notifications
PUT    /api/notifications/:id/read            # Mark notification as read
PUT    /api/notifications/mark-all-read       # Mark all as read
DELETE /api/notifications/:id                 # Delete notification

# Notification preferences
GET    /api/notifications/preferences         # Get user's notification preferences
PUT    /api/notifications/preferences         # Update notification preferences

# System notifications (admin only)
POST   /api/notifications/broadcast           # Send notification to all users
POST   /api/notifications/store/:store_id     # Send to all users in store
POST   /api/notifications/role/:role          # Send to all users with role
```

#### Example Notification Preferences:
```json
PUT /api/notifications/preferences
{
    "low_stock_alerts": true,
    "expiry_alerts": true, 
    "transfer_notifications": true,
    "waste_approvals": false,
    "system_alerts": true,
    "email_enabled": true,
    "sms_enabled": false,
    "push_enabled": true,
    "quiet_hours_start": "22:00",
    "quiet_hours_end": "06:00"
}
```

---

## 9. Offline Synchronization APIs (NEW)

### 9.1 Mobile Offline Support
```http
# Device management
POST   /api/sync/register-device              # Register mobile device
GET    /api/sync/device-info                  # Get device sync info
PUT    /api/sync/device-info                  # Update device info

# Data synchronization  
POST   /api/sync/upload                       # Upload offline changes
GET    /api/sync/download                     # Download server changes
POST   /api/sync/resolve-conflicts            # Resolve data conflicts
GET    /api/sync/status                       # Get sync status

# Offline operations queue
GET    /api/sync/queue                        # Get pending sync operations
DELETE /api/sync/queue/:id                    # Remove resolved operation
POST   /api/sync/queue/retry                  # Retry failed operations
```

#### Example Offline Upload:
```json
POST /api/sync/upload
{
    "device_id": "device_uuid",
    "operations": [
        {
            "operation": "INSERT",
            "table": "stock_movements",
            "local_timestamp": "2024-01-15T10:30:00Z",
            "data": {
                "item_id": "item_uuid",
                "store_id": "store_uuid",
                "type": "Stock Out",
                "quantity": 5.0,
                // ... other movement data
            }
        },
        {
            "operation": "UPDATE", 
            "table": "store_stock",
            "local_timestamp": "2024-01-15T10:30:05Z",
            "data": {
                "id": "store_stock_uuid",
                "quantity": 45.0
            }
        }
    ]
}

Response:
{
    "success": true,
    "data": {
        "synced_operations": 2,
        "conflicts": [],
        "errors": [],
        "server_timestamp": "2024-01-15T10:35:00Z"
    }
}
```

---

## 10. Reporting & Analytics APIs (Enhanced)

### 10.1 Multi-Store Reporting
```http
# Dashboard APIs (Enhanced for multi-store)
GET    /api/dashboard/kpis                    # KPIs for user's accessible stores
GET    /api/dashboard/alerts                  # Alerts across user's stores  
GET    /api/dashboard/store/:store_id         # Store-specific dashboard

# Stock reports (Multi-store aware)
GET    /api/reports/stock/current             # Current stock across stores
GET    /api/reports/stock/valuation           # Inventory valuation by store
GET    /api/reports/stock/movements           # Stock movement reports  
GET    /api/reports/stock/low-stock           # Low stock across stores

# Transfer reports (NEW)
GET    /api/reports/transfers/summary         # Transfer summary reports
GET    /api/reports/transfers/performance     # Transfer performance metrics

# Waste reports (Enhanced)  
GET    /api/reports/waste/summary             # Waste summary by store
GET    /api/reports/waste/trends              # Waste trends analysis
GET    /api/reports/waste/by-reason           # Waste analysis by reason

# Export capabilities
GET    /api/reports/export/stock              # Export stock report
GET    /api/reports/export/movements          # Export movement report
GET    /api/reports/export/transfers          # Export transfer report
```

### 10.2 Advanced Analytics (NEW)
```http
# Consumption analysis
GET    /api/analytics/consumption/trends      # Consumption trend analysis
GET    /api/analytics/consumption/forecast    # Consumption forecasting
GET    /api/analytics/consumption/seasonal    # Seasonal consumption patterns

# Performance metrics
GET    /api/analytics/performance/stores      # Store performance comparison
GET    /api/analytics/performance/suppliers   # Supplier performance analysis
GET    /api/analytics/performance/users       # User activity analytics
```

---

## 11. File & Attachment Management APIs (NEW)

### 11.1 File Upload & Management
```http
# File uploads
POST   /api/attachments/upload                # Upload file
GET    /api/attachments/:id                   # Get file info
GET    /api/attachments/:id/download          # Download file
DELETE /api/attachments/:id                   # Delete file

# Entity attachments
GET    /api/attachments/entity/:type/:id      # Get files for entity
POST   /api/attachments/entity/:type/:id      # Attach file to entity
DELETE /api/attachments/entity/:type/:id/:file_id  # Remove attachment

# Bulk operations
POST   /api/attachments/bulk-upload           # Upload multiple files
POST   /api/attachments/bulk-delete           # Delete multiple files
```

---

## 12. System Administration APIs (NEW)

### 12.1 System Configuration
```http
# System settings
GET    /api/admin/settings                    # Get system settings
PUT    /api/admin/settings                    # Update system settings
GET    /api/admin/settings/store/:store_id    # Store-specific settings

# Audit logs
GET    /api/admin/audit-logs                  # Get audit logs
GET    /api/admin/audit-logs/user/:user_id    # User-specific audit trail
GET    /api/admin/audit-logs/table/:table     # Table-specific changes

# System health
GET    /api/admin/health                      # System health check
GET    /api/admin/metrics                     # System performance metrics
```

### 12.2 Data Management
```http
# Data maintenance
POST   /api/admin/cleanup/audit-logs          # Cleanup old audit logs
POST   /api/admin/cleanup/notifications       # Cleanup old notifications
POST   /api/admin/backup/export               # Export system data
POST   /api/admin/backup/import               # Import system data
```

---

## Summary of V2 API Changes

### **New Capabilities**:
✅ **Canonical Items vs Store Stock**: Separate APIs for item definitions and store-specific stock  
✅ **Enhanced Security**: 2FA, account lockout, comprehensive session management  
✅ **Transfer Management**: Complete inter-store transfer workflow with approvals  
✅ **Offline Synchronization**: Mobile app sync with conflict resolution  
✅ **Notification System**: Multi-channel notifications with user preferences  
✅ **File Attachments**: Secure file upload and association with entities  
✅ **Advanced Authorization**: Store-based permissions and row-level security  
✅ **Comprehensive Audit**: All API operations logged with user context  

### **Enhanced Features**:
🔄 **Multi-Store Operations**: Store-aware queries and consolidated reporting  
🔄 **Approval Workflows**: Configurable approval processes for various operations  
🔄 **Advanced Reporting**: Multi-store analytics and performance metrics  
🔄 **Movement Corrections**: Ability to correct stock movements with audit trails  

### **Migration Impact**:
- **Breaking Changes**: Item and stock endpoints restructured
- **New Dependencies**: Notification service, file storage, sync service
- **Enhanced Security**: All endpoints require enhanced authentication
- **Performance**: Optimized for multi-store queries with proper indexing

---

**Document Version**: 2.0  
**Based on**: DATABASE_DESIGN_V2.md schema and modern API best practices  
**Security Level**: Production-ready with comprehensive audit and authorization  
**Offline Support**: Full mobile synchronization capabilities  
**Next Phase**: Implement Laravel backend with new API structure