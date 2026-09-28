# Catering Inventory Store Management System - API Documentation

## Overview

This document provides comprehensive documentation for the Catering Inventory Store Management System REST API. The API is built with Laravel 10+ and uses JWT authentication via Laravel Sanctum.

**Base URL**: `http://localhost:8000/api`

**Authentication**: Bearer Token (JWT)

**Content-Type**: `application/json`

---

## Authentication

All API endpoints (except login) require authentication using Bearer token in the Authorization header:

```
Authorization: Bearer {your_jwt_token}
```

### Login

Authenticate a user and receive access token.

**Endpoint**: `POST /auth/login`

**Request Body**:
```json
{
    "email": "admin@cateringinventory.com",
    "password": "password123",
    "device_name": "My Device"
}
```

**Success Response** (200):
```json
{
    "success": true,
    "data": {
        "access_token": "1|eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
        "token_type": "Bearer",
        "expires_in": 86400,
        "user": {
            "id": "9d2e8f4a-1b3c-4d5e-6f7g-8h9i0j1k2l3m",
            "name": "System Administrator",
            "email": "admin@cateringinventory.com",
            "role": "admin",
            "permissions": [
                "inventory.view",
                "inventory.create",
                "users.view",
                "dashboard.view"
            ],
            "assigned_stores": [
                {
                    "store_id": "store_uuid_here",
                    "store_name": "Main Warehouse",
                    "store_code": "MW-001",
                    "role_in_store": "manager",
                    "can_transfer_to": true,
                    "can_transfer_from": true
                }
            ]
        }
    }
}
```

**Error Response** (401):
```json
{
    "success": false,
    "message": "The provided credentials are incorrect.",
    "errors": {
        "email": ["The provided credentials are incorrect."]
    }
}
```

### Logout

Revoke the current access token.

**Endpoint**: `POST /auth/logout`

**Headers**: `Authorization: Bearer {token}`

**Success Response** (200):
```json
{
    "success": true,
    "message": "Successfully logged out"
}
```

### Get Profile

Get authenticated user's profile information.

**Endpoint**: `GET /auth/profile`

**Headers**: `Authorization: Bearer {token}`

**Success Response** (200):
```json
{
    "success": true,
    "data": {
        "id": "user_uuid",
        "name": "System Administrator",
        "email": "admin@cateringinventory.com",
        "phone": "+251911123456",
        "role": "admin",
        "department": "Management",
        "status": "Active",
        "permissions": [...],
        "two_factor_enabled": false,
        "assigned_stores": [...],
        "last_login_at": "2024-01-15T10:30:00Z",
        "created_at": "2024-01-01T00:00:00Z"
    }
}
```

### Refresh Token

Generate a new access token.

**Endpoint**: `POST /auth/refresh`

**Headers**: `Authorization: Bearer {token}`

**Success Response** (200):
```json
{
    "success": true,
    "data": {
        "access_token": "new_jwt_token_here",
        "token_type": "Bearer",
        "expires_in": 86400
    }
}
```

---

## User Management

### List Users

Get a paginated list of users with optional filtering.

**Endpoint**: `GET /users`

**Query Parameters**:
- `search` (optional): Search by name, email, or phone
- `role` (optional): Filter by user role
- `status` (optional): Filter by status (Active, Inactive, Suspended)
- `department` (optional): Filter by department
- `per_page` (optional): Number of items per page (default: 15)
- `page` (optional): Page number

**Example**: `GET /users?search=admin&role=admin&per_page=10`

**Success Response** (200):
```json
{
    "success": true,
    "data": {
        "users": [
            {
                "id": "user_uuid",
                "name": "System Administrator",
                "email": "admin@cateringinventory.com",
                "phone": "+251911123456",
                "role": "admin",
                "department": "Management",
                "status": "Active",
                "permissions": [...],
                "stores": [
                    {
                        "id": "store_uuid",
                        "name": "Main Warehouse",
                        "code": "MW-001"
                    }
                ],
                "created_at": "2024-01-01T00:00:00Z"
            }
        ],
        "pagination": {
            "current_page": 1,
            "last_page": 5,
            "per_page": 15,
            "total": 67
        }
    }
}
```

### Create User

Create a new user account.

**Endpoint**: `POST /users`

**Request Body**:
```json
{
    "name": "John Doe",
    "email": "john.doe@example.com",
    "password": "securepassword123",
    "password_confirmation": "securepassword123",
    "phone": "+251911234567",
    "role": "store_manager",
    "department": "Main Store",
    "permissions": [
        "inventory.view",
        "inventory.create",
        "suppliers.view"
    ]
}
```

**Validation Rules**:
- `name`: required, string, max 255 chars
- `email`: required, email, unique
- `password`: required, min 8 chars, confirmed
- `role`: required, one of: admin, store_manager, kitchen_supervisor, cashier, storekeeper, chef
- `permissions`: optional array of permission strings

**Success Response** (201):
```json
{
    "success": true,
    "data": {
        "id": "new_user_uuid",
        "name": "John Doe",
        "email": "john.doe@example.com",
        "role": "store_manager",
        "status": "Active",
        // ... other user fields
    },
    "message": "User created successfully"
}
```

### Get User

Get details of a specific user.

**Endpoint**: `GET /users/{userId}`

**Success Response** (200):
```json
{
    "success": true,
    "data": {
        "id": "user_uuid",
        "name": "John Doe",
        "email": "john.doe@example.com",
        "phone": "+251911234567",
        "role": "store_manager",
        "department": "Main Store",
        "status": "Active",
        "permissions": [...],
        "stores": [...],
        "store_assignments": [
            {
                "store_id": "store_uuid",
                "role_in_store": "manager",
                "can_transfer_to": true,
                "can_transfer_from": true
            }
        ],
        "created_at": "2024-01-01T00:00:00Z"
    }
}
```

### Update User

Update an existing user.

**Endpoint**: `PUT /users/{userId}`

**Request Body** (all fields optional):
```json
{
    "name": "John Smith",
    "email": "john.smith@example.com",
    "phone": "+251922345678",
    "role": "kitchen_supervisor",
    "department": "Kitchen",
    "status": "Active",
    "permissions": [
        "inventory.view",
        "recipes.create"
    ]
}
```

**Success Response** (200):
```json
{
    "success": true,
    "data": {
        // Updated user object
    },
    "message": "User updated successfully"
}
```

### Delete User

Soft delete a user account.

**Endpoint**: `DELETE /users/{userId}`

**Success Response** (200):
```json
{
    "success": true,
    "message": "User deleted successfully"
}
```

### Get Available Roles

Get list of available user roles.

**Endpoint**: `GET /users/roles`

**Success Response** (200):
```json
{
    "success": true,
    "data": [
        {"value": "admin", "label": "System Administrator"},
        {"value": "store_manager", "label": "Store Manager"},
        {"value": "kitchen_supervisor", "label": "Kitchen Supervisor"},
        {"value": "cashier", "label": "Cashier"},
        {"value": "storekeeper", "label": "Storekeeper"},
        {"value": "chef", "label": "Chef"}
    ]
}
```

### Get Available Permissions

Get list of available permissions.

**Endpoint**: `GET /users/permissions`

**Success Response** (200):
```json
{
    "success": true,
    "data": [
        "inventory.view",
        "inventory.create",
        "inventory.update",
        "inventory.delete",
        "suppliers.view",
        "suppliers.create",
        "purchases.view",
        "users.view",
        "reports.view",
        "dashboard.view"
    ]
}
```

---

## Store Management

### List Stores

Get a paginated list of stores. Non-admin users only see stores they're assigned to.

**Endpoint**: `GET /stores`

**Query Parameters**:
- `search` (optional): Search by name, code, or location
- `type` (optional): Filter by store type
- `active` (optional): Filter by active status (true/false)
- `level` (optional): Filter by store level (0, 1, 2, etc.)
- `per_page` (optional): Items per page

**Success Response** (200):
```json
{
    "success": true,
    "data": {
        "stores": [
            {
                "id": "store_uuid",
                "name": "Main Warehouse",
                "code": "MW-001",
                "description": "Primary storage facility",
                "location": "Main Building, Ground Floor",
                "phone": "+251911123456",
                "email": "warehouse@example.com",
                "parent_store_id": null,
                "store_level": 0,
                "store_type": "main_warehouse",
                "timezone": "Africa/Addis_Ababa",
                "is_active": true,
                "manager": {
                    "id": "manager_uuid",
                    "name": "Store Manager",
                    "email": "manager@example.com"
                },
                "parent_store": null,
                "created_at": "2024-01-01T00:00:00Z"
            }
        ],
        "pagination": {
            "current_page": 1,
            "last_page": 3,
            "per_page": 15,
            "total": 42
        }
    }
}
```

### Create Store

Create a new store.

**Endpoint**: `POST /stores`

**Request Body**:
```json
{
    "name": "Branch Store A",
    "code": "BSA-001",
    "description": "Branch location in Bole area",
    "location": "Bole, Addis Ababa",
    "phone": "+251922123456",
    "email": "branch.a@example.com",
    "parent_store_id": "main_store_uuid",
    "store_level": 1,
    "manager_id": "manager_uuid",
    "store_type": "dry_food",
    "timezone": "Africa/Addis_Ababa",
    "operating_hours": {
        "monday": {"open": "08:00", "close": "18:00"},
        "tuesday": {"open": "08:00", "close": "18:00"},
        "sunday": {"open": null, "close": null}
    },
    "settings": {
        "auto_reorder": true,
        "low_stock_threshold": 10
    },
    "is_active": true
}
```

**Validation Rules**:
- `name`: required, string, max 255
- `code`: required, string, max 50, unique
- `store_type`: required, one of: main_warehouse, dry_food, cold_room, freezer, beverage, kitchen, electronics, general
- `store_level`: required, integer, 0-5

**Success Response** (201):
```json
{
    "success": true,
    "data": {
        // Created store object with relationships
    },
    "message": "Store created successfully"
}
```

### Get Store

Get details of a specific store.

**Endpoint**: `GET /stores/{storeId}`

**Success Response** (200):
```json
{
    "success": true,
    "data": {
        "id": "store_uuid",
        "name": "Main Warehouse",
        "code": "MW-001",
        // ... all store fields
        "manager": {
            "id": "manager_uuid",
            "name": "Store Manager",
            "email": "manager@example.com"
        },
        "parent_store": null,
        "child_stores": [
            {
                "id": "child_uuid",
                "name": "Cold Storage",
                "code": "CS-001",
                "store_type": "cold_room"
            }
        ],
        "users": [
            {
                "id": "user_uuid",
                "name": "John Doe",
                "email": "john@example.com",
                "role": "storekeeper"
            }
        ]
    }
}
```

### Update Store

Update an existing store.

**Endpoint**: `PUT /stores/{storeId}`

**Request Body** (all fields optional):
```json
{
    "name": "Updated Store Name",
    "description": "Updated description",
    "manager_id": "new_manager_uuid",
    "is_active": false
}
```

**Success Response** (200):
```json
{
    "success": true,
    "data": {
        // Updated store object
    },
    "message": "Store updated successfully"
}
```

### Delete Store

Delete a store (only if no child stores or stock items exist).

**Endpoint**: `DELETE /stores/{storeId}`

**Success Response** (200):
```json
{
    "success": true,
    "message": "Store deleted successfully"
}
```

**Error Response** (400):
```json
{
    "success": false,
    "message": "Cannot delete store with child stores"
}
```

### Get Store Types

Get available store types.

**Endpoint**: `GET /stores/types`

**Success Response** (200):
```json
{
    "success": true,
    "data": [
        {"value": "main_warehouse", "label": "Main Warehouse"},
        {"value": "dry_food", "label": "Dry Food Storage"},
        {"value": "cold_room", "label": "Cold Room"},
        {"value": "freezer", "label": "Freezer"},
        {"value": "beverage", "label": "Beverage Storage"},
        {"value": "kitchen", "label": "Kitchen"},
        {"value": "electronics", "label": "Electronics Storage"},
        {"value": "general", "label": "General Storage"}
    ]
}
```

---

## Item Management (Canonical Items)

### List Items

Get a paginated list of canonical items (shared across all stores).

**Endpoint**: `GET /items`

**Query Parameters**:
- `search` (optional): Search by name, code, or description
- `type` (optional): Filter by item type (food, catering, electronics)
- `category` (optional): Filter by category
- `active` (optional): Filter by active status (default: true)
- `per_page` (optional): Items per page

**Success Response** (200):
```json
{
    "success": true,
    "data": {
        "items": [
            {
                "id": "item_uuid",
                "code": "FOOD-MEAT-001",
                "name": "Chicken Breast (Boneless)",
                "description": "Fresh boneless chicken breast",
                "category": "Meat & Poultry",
                "item_type": "food",
                "unit": "kg",
                "default_purchase_price": 150.00,
                "shelf_life_days": 7,
                "requires_refrigeration": true,
                "catering_subtype": null,
                "brand": null,
                "model": null,
                "warranty_period_months": null,
                "is_active": true,
                "creator": {
                    "id": "creator_uuid",
                    "name": "System Administrator"
                },
                "created_at": "2024-01-01T00:00:00Z"
            }
        ],
        "pagination": {
            "current_page": 1,
            "last_page": 8,
            "per_page": 15,
            "total": 114
        }
    }
}
```

### Create Item

Create a new canonical item.

**Endpoint**: `POST /items`

**Request Body**:
```json
{
    "code": "FOOD-MEAT-002",
    "name": "Beef Steak",
    "description": "Premium beef steak cuts",
    "category": "Meat & Poultry",
    "item_type": "food",
    "unit": "kg",
    "default_purchase_price": 280.00,
    "shelf_life_days": 5,
    "requires_refrigeration": true
}
```

**Item Type Specific Fields**:

**Food Items**:
- `shelf_life_days`: integer (optional)
- `requires_refrigeration`: boolean (optional)

**Catering Items**:
- `catering_subtype`: "permanent" or "temporary" (optional)

**Electronics Items**:
- `brand`: string (optional)
- `model`: string (optional)  
- `warranty_period_months`: integer (optional)

**Validation**: Type-specific fields are validated - food items cannot have catering or electronics fields.

**Success Response** (201):
```json
{
    "success": true,
    "data": {
        // Created item object
    },
    "message": "Item created successfully"
}
```

### Get Item

Get details of a specific item including stock levels across stores.

**Endpoint**: `GET /items/{itemId}`

**Success Response** (200):
```json
{
    "success": true,
    "data": {
        "id": "item_uuid",
        "code": "FOOD-MEAT-001",
        "name": "Chicken Breast (Boneless)",
        // ... all item fields
        "creator": {
            "id": "creator_uuid",
            "name": "System Administrator"
        },
        "store_stock": [
            {
                "store": {
                    "id": "store_uuid",
                    "name": "Main Warehouse",
                    "code": "MW-001"
                },
                "quantity": 45.500,
                "available_quantity": 40.000,
                "reserved_quantity": 5.500,
                "status": "Healthy"
            }
        ],
        "total_stock": 45.500,
        "available_stock": 40.000
    }
}
```

### Update Item

Update an existing canonical item.

**Endpoint**: `PUT /items/{itemId}`

**Request Body** (all fields optional):
```json
{
    "name": "Updated Item Name",
    "description": "Updated description",
    "default_purchase_price": 300.00,
    "is_active": false
}
```

**Success Response** (200):
```json
{
    "success": true,
    "data": {
        // Updated item object
    },
    "message": "Item updated successfully"
}
```

### Delete Item

Delete an item (only if no stock exists and not used in recipes).

**Endpoint**: `DELETE /items/{itemId}`

**Success Response** (200):
```json
{
    "success": true,
    "message": "Item deleted successfully"
}
```

### Search Items

Quick search for items (used for autocomplete/typeahead).

**Endpoint**: `GET /items/search`

**Query Parameters**:
- `q` (required): Search query (min 2 characters)
- `type` (optional): Filter by item type
- `category` (optional): Filter by category  
- `limit` (optional): Max results (1-50, default: 20)

**Success Response** (200):
```json
{
    "success": true,
    "data": [
        {
            "id": "item_uuid",
            "code": "FOOD-MEAT-001",
            "name": "Chicken Breast (Boneless)",
            "unit": "kg",
            "item_type": "food"
        }
    ]
}
```

### Get Item Types

Get available item types.

**Endpoint**: `GET /items/types`

**Success Response** (200):
```json
{
    "success": true,
    "data": [
        {"value": "food", "label": "Food"},
        {"value": "catering", "label": "Catering"},
        {"value": "electronics", "label": "Electronics"}
    ]
}
```

### Get Categories

Get available categories, optionally filtered by type.

**Endpoint**: `GET /items/categories`

**Query Parameters**:
- `type` (optional): Filter by item type

**Success Response** (200):
```json
{
    "success": true,
    "data": [
        "Meat & Poultry",
        "Grains & Cereals",
        "Dairy Products",
        "Tables",
        "POS Equipment"
    ]
}
```

---

## Error Responses

All endpoints follow a consistent error response format:

### Validation Errors (422)
```json
{
    "success": false,
    "message": "Validation failed",
    "errors": {
        "email": ["The email field is required."],
        "password": ["The password must be at least 8 characters."]
    }
}
```

### Authentication Errors (401)
```json
{
    "success": false,
    "message": "Unauthorized"
}
```

### Authorization Errors (403)
```json
{
    "success": false,
    "message": "You do not have access to this store"
}
```

### Not Found Errors (404)
```json
{
    "success": false,
    "message": "Resource not found"
}
```

### Server Errors (500)
```json
{
    "success": false,
    "message": "Internal server error"
}
```

---

## Rate Limiting

API requests are rate-limited to 60 requests per minute per user/IP address.

When rate limit is exceeded:
```json
{
    "message": "Too Many Attempts.",
    "exception": "Illuminate\\Http\\Exceptions\\ThrottleRequestsException"
}
```

---

## Pagination

Paginated endpoints return data in this format:

```json
{
    "success": true,
    "data": {
        "items": [...],
        "pagination": {
            "current_page": 1,
            "last_page": 5,
            "per_page": 15,
            "total": 67,
            "from": 1,
            "to": 15
        }
    }
}
```

Query parameters for pagination:
- `page`: Page number (default: 1)
- `per_page`: Items per page (default: 15, max: 100)

---

## Default Test Credentials

After running `php artisan migrate --seed`:

**Admin User**:
- Email: `admin@cateringinventory.com`
- Password: `password123`
- Role: `admin`
- Access: All stores and permissions

**Store Manager**:
- Email: `manager@cateringinventory.com`  
- Password: `password123`
- Role: `store_manager`
- Access: Main Warehouse and Cold Storage stores

---

## Status Codes Summary

- **200**: Success
- **201**: Created  
- **400**: Bad Request
- **401**: Unauthorized
- **403**: Forbidden
- **404**: Not Found
- **422**: Validation Error
- **429**: Rate Limited
- **500**: Server Error

---

## Notes

1. All timestamps are in ISO 8601 format (UTC)
2. All monetary values are in Ethiopian Birr (ETB)
3. UUIDs are used for all resource IDs
4. Soft deletes are used - deleted resources return 404 but data is preserved
5. All endpoints require HTTPS in production
6. API versioning may be added in future (v1, v2, etc.)

This API documentation covers the core functionality implemented in the Laravel backend. Additional endpoints for stock movements, transfers, purchase orders, and other features will be added as development continues.