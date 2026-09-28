# Catering Inventory Store Management System - Backend

Laravel-based REST API backend for the Catering Inventory Store Management System.

## Features

- 🔐 **Authentication & Authorization**: JWT-based auth with 2FA support
- 🏪 **Multi-Store Management**: Hierarchical store structure with user assignments
- 📦 **Inventory Management**: Canonical items + store-specific stock levels
- 🔄 **Stock Movements**: Complete audit trail with corrections support
- 🚛 **Transfer Management**: Inter-store transfers with approval workflows
- 💰 **Purchase Orders**: Full procurement workflow with receiving
- 📊 **Reporting**: Real-time dashboards and analytics
- 📱 **Offline Sync**: Mobile app synchronization support
- 🔍 **Audit Logs**: Comprehensive change tracking

## Technology Stack

- **Framework**: Laravel 10+
- **Database**: PostgreSQL 14+
- **Authentication**: Laravel Sanctum
- **Architecture**: Repository + Service Layer
- **API**: RESTful with JSON responses

## Installation

### Prerequisites

- PHP 8.1+
- Composer
- PostgreSQL 14+
- Node.js (for asset compilation)

### Setup

1. **Install dependencies**
   ```bash
   composer install
   ```

2. **Environment configuration**
   ```bash
   cp .env.example .env
   # Edit .env with your database credentials
   ```

3. **Database setup**
   ```bash
   php artisan key:generate
   php artisan migrate
   php artisan db:seed
   ```

4. **Start the server**
   ```bash
   php artisan serve
   ```

The API will be available at `http://localhost:8000`

## API Documentation

### Authentication

**Login**
```http
POST /api/auth/login
Content-Type: application/json

{
    "email": "admin@cateringinventory.com",
    "password": "password123",
    "device_name": "My Device"
}
```

**Response**
```json
{
    "success": true,
    "data": {
        "access_token": "jwt_token_here",
        "user": {
            "id": "uuid",
            "name": "System Administrator",
            "email": "admin@cateringinventory.com",
            "role": "admin",
            "permissions": [...],
            "assigned_stores": [...]
        }
    }
}
```

### Core Resources

- `GET /api/users` - List users
- `GET /api/stores` - List stores  
- `GET /api/items` - List canonical items
- `GET /api/stores/{store}/stock` - Store-specific stock
- `GET /api/stock-movements` - Stock movements
- `GET /api/transfers` - Inter-store transfers
- `GET /api/suppliers` - Suppliers
- `GET /api/purchase-orders` - Purchase orders

All endpoints require authentication via `Authorization: Bearer {token}` header.

## Database Schema

### Core Tables

- **users** - System users with enhanced security
- **stores** - Store hierarchy with parent-child relationships
- **items** - Canonical item definitions (shared across stores)
- **store_stock** - Store-specific stock levels and thresholds
- **stock_movements** - Complete audit trail of all stock changes
- **user_store_assignments** - User permissions per store

### Key Features

- **UUID Primary Keys** for better security and distributed systems
- **Soft Deletes** with reason tracking for audit compliance
- **Audit Logging** for all data modifications
- **Multi-Store Support** with proper data isolation
- **Offline Sync** capabilities for mobile apps

## Default Credentials

After seeding:
- **Admin**: admin@cateringinventory.com / password123
- **Manager**: manager@cateringinventory.com / password123

## Development

### Running Tests
```bash
php artisan test
```

### Code Style
```bash
composer run-script format
```

### Database Reset
```bash
php artisan migrate:fresh --seed
```

## Production Deployment

1. Set `APP_ENV=production` in `.env`
2. Configure database connection
3. Set up SSL certificates  
4. Configure caching and queues
5. Set up monitoring and logging

## Security Features

- JWT token authentication with configurable expiration
- Role-based access control (RBAC)
- Store-level data isolation
- Account lockout protection
- Comprehensive audit trails
- Two-factor authentication support
- Rate limiting on API endpoints

## Architecture

The backend follows Laravel best practices:

- **Controllers**: Handle HTTP requests and responses
- **Models**: Eloquent ORM for database interactions
- **Services**: Business logic layer
- **Resources**: API response transformation
- **Requests**: Input validation
- **Middleware**: Cross-cutting concerns (auth, logging, etc.)

## Contributing

1. Follow PSR-12 coding standards
2. Write tests for new features
3. Update documentation
4. Use meaningful commit messages

## License

This project is proprietary software for internal use.