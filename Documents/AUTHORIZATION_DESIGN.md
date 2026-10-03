# Authorization Design
**Catering Inventory Store Management System**

## Overview
This document defines the complete authentication and authorization architecture for the Laravel backend, designed to secure the Flutter frontend application with role-based access control.

---

## 1. Authentication Architecture

### 1.1 Authentication Method
**Primary**: Laravel Sanctum (SPA Authentication)
- Token-based authentication for Flutter frontend
- Stateless API authentication
- Built-in Laravel integration
- Mobile app friendly
- Secure token management

**Alternative Considered**: JWT with tymon/jwt-auth
- Rejected: Sanctum provides better Laravel integration and security

### 1.2 Token Management
```php
// Token Configuration
'sanctum' => [
    'expiration' => 1440, // 24 hours
    'token_prefix' => 'cism_',
    'personal_access_tokens' => [
        'expire_tokens' => true,
    ],
],
```

### 1.3 Authentication Flow
```
1. Flutter App → POST /api/auth/login (email, password)
2. Laravel → Validates credentials
3. Laravel → Creates Sanctum token
4. Laravel → Returns: { token, user, permissions }
5. Flutter → Stores token securely
6. Flutter → Includes token in all API requests: Authorization: Bearer {token}
7. Laravel → Validates token on each request
```

---

## 2. User Management System

### 2.1 User Model Extensions
```php
// User Model (extends Laravel's User)
class User extends Authenticatable
{
    use HasApiTokens, HasRoles, SoftDeletes;
    
    protected $fillable = [
        'name', 'email', 'phone', 'password', 
        'role_id', 'department', 'store_id', 'status'
    ];
    
    protected $hidden = ['password', 'remember_token'];
    
    protected $casts = [
        'last_login_at' => 'datetime',
        'email_verified_at' => 'datetime',
        'status' => UserStatus::class,
    ];
}

enum UserStatus: string
{
    case ACTIVE = 'active';
    case INACTIVE = 'inactive'; 
    case SUSPENDED = 'suspended';
}
```

### 2.2 Password Security
```php
// Password Requirements
- Minimum 8 characters
- Must include: uppercase, lowercase, number, special character
- Hashed using bcrypt (Laravel default)
- Password reset via email tokens
- Account lockout after 5 failed attempts (15-minute cooldown)
```

---

## 3. Role-Based Access Control (RBAC)

### 3.3 Role Hierarchy
```php
// Roles Table Structure
roles: [
    { id: 1, name: 'admin', display_name: 'System Administrator' },
    { id: 2, name: 'store_manager', display_name: 'Store Manager' },
    { id: 3, name: 'kitchen_supervisor', display_name: 'Kitchen Supervisor' },
    { id: 4, name: 'cashier', display_name: 'Cashier' },
    { id: 5, name: 'storekeeper', display_name: 'Storekeeper' },
    { id: 6, name: 'chef', display_name: 'Chef' },
]
```

### 3.2 Permission System
```php
// Permissions Based on Frontend Analysis
permissions: [
    'inventory.view',     'inventory.create',   'inventory.update',   'inventory.delete',
    'suppliers.view',     'suppliers.create',   'suppliers.update',   'suppliers.delete',
    'purchases.view',     'purchases.create',   'purchases.update',   'purchases.delete',
    'recipes.view',       'recipes.create',     'recipes.update',     'recipes.delete',
    'waste.view',         'waste.create',       'waste.update',       'waste.delete',
    'expiry.view',        'expiry.update',
    'users.view',         'users.create',       'users.update',       'users.delete',
    'reports.view',       'reports.export',
    'stores.view',        'stores.create',      'stores.update',      'stores.delete',
    'transfers.view',     'transfers.create',   'transfers.approve',
    'barcode.generate',   'barcode.scan',
    'dashboard.view',
]
```

### 3.3 Role-Permission Matrix
```php
// Role Permissions Assignment
$rolePermissions = [
    'admin' => [
        // Full system access
        'inventory.*', 'suppliers.*', 'purchases.*', 'recipes.*',
        'waste.*', 'expiry.*', 'users.*', 'reports.*', 'stores.*',
        'transfers.*', 'barcode.*', 'dashboard.view'
    ],
    
    'store_manager' => [
        'inventory.*', 'suppliers.*', 'purchases.*',
        'waste.view', 'waste.create', 'waste.update',
        'expiry.view', 'expiry.update',
        'reports.view', 'reports.export',
        'transfers.view', 'transfers.create', 'transfers.approve',
        'barcode.*', 'dashboard.view'
    ],
    
    'kitchen_supervisor' => [
        'inventory.view', 'inventory.update',
        'recipes.*', 'waste.*',
        'reports.view', 'dashboard.view'
    ],
    
    'cashier' => [
        'purchases.view', 'purchases.create',
        'reports.view', 'dashboard.view'
    ],
    
    'storekeeper' => [
        'inventory.*', 'waste.*', 'expiry.*',
        'transfers.view', 'transfers.create',
        'barcode.*', 'dashboard.view'
    ],
    
    'chef' => [
        'recipes.*', 'waste.view', 'waste.create',
        'inventory.view', 'dashboard.view'
    ]
];
```

---

## 4. API Security Implementation

### 4.1 Middleware Stack
```php
// API Route Protection
Route::middleware(['auth:sanctum', 'check.permissions'])->group(function () {
    // Protected API routes
});

// Custom Permission Middleware
class CheckPermissions
{
    public function handle($request, Closure $next, ...$permissions)
    {
        $user = $request->user();
        
        if (!$user) {
            return response()->json(['message' => 'Unauthenticated'], 401);
        }
        
        foreach ($permissions as $permission) {
            if (!$user->hasPermission($permission)) {
                return response()->json(['message' => 'Forbidden'], 403);
            }
        }
        
        return $next($request);
    }
}
```

### 4.2 Route-Level Permissions
```php
// Example Route Definitions with Permissions
Route::group(['middleware' => ['auth:sanctum']], function () {
    
    // Stock Management
    Route::get('/stock/items', [StockController::class, 'index'])
        ->middleware('permission:inventory.view');
    Route::post('/stock/items', [StockController::class, 'store'])
        ->middleware('permission:inventory.create');
    Route::put('/stock/items/{item}', [StockController::class, 'update'])
        ->middleware('permission:inventory.update');
    Route::delete('/stock/items/{item}', [StockController::class, 'destroy'])
        ->middleware('permission:inventory.delete');
    
    // User Management (Admin Only)
    Route::apiResource('users', UserController::class)
        ->middleware('permission:users.view,users.create,users.update,users.delete');
        
    // Reports (View Permission Required)
    Route::get('/reports/{type}', [ReportController::class, 'generate'])
        ->middleware('permission:reports.view');
});
```

### 4.3 Data Filtering by Store
```php
// Store-Based Data Isolation
class StockItem extends Model
{
    protected static function booted()
    {
        // Automatically filter by user's assigned store
        static::addGlobalScope('store', function (Builder $builder) {
            if (auth()->check() && auth()->user()->store_id) {
                $builder->where('store_id', auth()->user()->store_id);
            }
        });
    }
}

// Service Layer Store Filtering
class StockService
{
    public function getStockItems($filters = [])
    {
        $query = StockItem::query();
        
        // Apply store-level access control
        $user = auth()->user();
        if (!$user->hasRole('admin')) {
            $query->where('store_id', $user->store_id);
        }
        
        return $query->with('supplier', 'movements')->get();
    }
}
```

---

## 5. Security Features

### 5.1 Rate Limiting
```php
// API Rate Limiting Configuration
'throttle:api' => '60,1', // 60 requests per minute per user

// Auth-specific Rate Limiting
Route::middleware('throttle:5,1')->group(function () {
    Route::post('/auth/login', [AuthController::class, 'login']);
    Route::post('/auth/register', [AuthController::class, 'register']);
});
```

### 5.2 Request Validation
```php
// Login Request Validation
class LoginRequest extends FormRequest
{
    public function rules()
    {
        return [
            'email' => 'required|email',
            'password' => 'required|string|min:8',
            'device_name' => 'required|string|max:255'
        ];
    }
}

// Stock Item Creation Validation with Permissions
class StoreStockItemRequest extends FormRequest
{
    public function authorize()
    {
        return $this->user()->hasPermission('inventory.create');
    }
    
    public function rules()
    {
        return [
            'name' => 'required|string|max:255',
            'code' => 'required|string|unique:stock_items,code',
            'category' => 'required|in:food,catering,electronics',
            // ... other validation rules
        ];
    }
}
```

### 5.3 Audit Trail Implementation
```php
// Security Event Logging
class SecurityLogger
{
    public static function logLogin($user, $ipAddress)
    {
        SecurityLog::create([
            'user_id' => $user->id,
            'event_type' => 'login',
            'ip_address' => $ipAddress,
            'user_agent' => request()->userAgent(),
            'timestamp' => now()
        ]);
    }
    
    public static function logPermissionDenied($user, $permission, $resource)
    {
        SecurityLog::create([
            'user_id' => $user->id,
            'event_type' => 'permission_denied',
            'details' => json_encode([
                'permission' => $permission,
                'resource' => $resource,
                'ip_address' => request()->ip()
            ]),
            'timestamp' => now()
        ]);
    }
}
```

---

## 6. Frontend Integration

### 6.1 Flutter Token Storage
```dart
// Secure Token Storage Recommendations
class AuthService {
  static const String _tokenKey = 'auth_token';
  
  // Use flutter_secure_storage for token persistence
  static Future<void> saveToken(String token) async {
    const storage = FlutterSecureStorage();
    await storage.write(key: _tokenKey, value: token);
  }
  
  static Future<String?> getToken() async {
    const storage = FlutterSecureStorage();
    return await storage.read(key: _tokenKey);
  }
  
  static Future<void> clearToken() async {
    const storage = FlutterSecureStorage();
    await storage.delete(key: _tokenKey);
  }
}
```

### 6.2 API Client Authentication
```dart
// HTTP Client with Token Injection
class ApiClient {
  static const String baseUrl = 'https://api.cateringinventory.com';
  
  static Future<Map<String, String>> _getHeaders() async {
    final token = await AuthService.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
  
  static Future<Response> get(String endpoint) async {
    final headers = await _getHeaders();
    return await http.get(Uri.parse('$baseUrl$endpoint'), headers: headers);
  }
}
```

### 6.3 Permission-Based UI
```dart
// Permission-Based Widget Rendering
class PermissionWidget extends StatelessWidget {
  final String permission;
  final Widget child;
  final Widget? fallback;
  
  const PermissionWidget({
    required this.permission,
    required this.child,
    this.fallback,
  });
  
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.hasPermission(permission)) {
          return child;
        }
        return fallback ?? const SizedBox.shrink();
      },
    );
  }
}

// Usage Example
PermissionWidget(
  permission: 'inventory.create',
  child: FloatingActionButton(
    onPressed: () => _createNewItem(),
    child: Icon(Icons.add),
  ),
)
```

---

## 7. Error Handling & Responses

### 7.1 Authentication Error Responses
```php
// Standardized Auth Error Responses
class AuthController extends Controller
{
    public function login(LoginRequest $request)
    {
        $credentials = $request->only('email', 'password');
        
        if (!Auth::attempt($credentials)) {
            return response()->json([
                'message' => 'Invalid credentials',
                'errors' => ['email' => ['The provided credentials are incorrect.']]
            ], 401);
        }
        
        $user = Auth::user();
        
        if ($user->status !== UserStatus::ACTIVE) {
            return response()->json([
                'message' => 'Account suspended or inactive',
                'errors' => ['account' => ['Your account is not active.']]
            ], 403);
        }
        
        $token = $user->createToken($request->device_name)->plainTextToken;
        
        return response()->json([
            'message' => 'Login successful',
            'data' => [
                'token' => $token,
                'user' => new UserResource($user),
                'permissions' => $user->getAllPermissions()->pluck('name')
            ]
        ]);
    }
}
```

### 7.2 Permission Denied Responses
```json
// 403 Forbidden Response Format
{
    "message": "Insufficient permissions",
    "error_code": "PERMISSION_DENIED",
    "required_permission": "inventory.create",
    "user_permissions": ["inventory.view", "inventory.update"]
}
```

---

## 8. Session Management

### 8.1 Token Lifecycle
```php
// Token Management
class TokenService
{
    public static function revokeUserTokens($userId)
    {
        PersonalAccessToken::where('tokenable_id', $userId)
            ->where('tokenable_type', User::class)
            ->delete();
    }
    
    public static function revokeExpiredTokens()
    {
        PersonalAccessToken::where('created_at', '<', now()->subDays(30))
            ->delete();
    }
    
    public static function getUserActiveSessions($userId)
    {
        return PersonalAccessToken::where('tokenable_id', $userId)
            ->where('tokenable_type', User::class)
            ->where('last_used_at', '>', now()->subDays(1))
            ->get();
    }
}
```

### 8.2 Logout Implementation
```php
// Secure Logout
public function logout(Request $request)
{
    // Revoke current token
    $request->user()->currentAccessToken()->delete();
    
    // Log security event
    SecurityLogger::logLogout($request->user(), $request->ip());
    
    return response()->json(['message' => 'Successfully logged out']);
}

// Logout from all devices
public function logoutAll(Request $request)
{
    // Revoke all user tokens
    $request->user()->tokens()->delete();
    
    SecurityLogger::logLogoutAll($request->user(), $request->ip());
    
    return response()->json(['message' => 'Logged out from all devices']);
}
```

---

## 9. Production Security Considerations

### 9.1 Environment Configuration
```env
# Production Security Settings
APP_ENV=production
APP_DEBUG=false
APP_KEY=base64:generated-32-character-key

# Sanctum Configuration
SANCTUM_STATEFUL_DOMAINS=cateringinventory.com,app.cateringinventory.com
SESSION_DOMAIN=.cateringinventory.com
SESSION_SECURE_COOKIE=true
SESSION_SAME_SITE=none

# Database Security
DB_CONNECTION=pgsql
DB_HOST=secure-db-host
DB_PORT= 5433
DB_DATABASE=catering_inventory_prod
DB_USERNAME=cism_user
DB_PASSWORD=secure-generated-password

# CORS Configuration
CORS_ALLOWED_ORIGINS=https://app.cateringinventory.com
CORS_ALLOWED_METHODS=GET,POST,PUT,DELETE,OPTIONS
```

### 9.2 SSL/TLS Requirements
```php
// Force HTTPS in Production
if (app()->environment('production')) {
    URL::forceScheme('https');
}

// Security Headers Middleware
class SecurityHeaders
{
    public function handle($request, Closure $next)
    {
        $response = $next($request);
        
        $response->headers->set('Strict-Transport-Security', 'max-age=31536000; includeSubDomains');
        $response->headers->set('X-Content-Type-Options', 'nosniff');
        $response->headers->set('X-Frame-Options', 'DENY');
        $response->headers->set('X-XSS-Protection', '1; mode=block');
        $response->headers->set('Referrer-Policy', 'strict-origin-when-cross-origin');
        
        return $response;
    }
}
```

### 9.3 Database Security
```php
// Database Query Security
class StockService
{
    public function searchItems($query, $category = null)
    {
        // Use parameterized queries to prevent SQL injection
        return StockItem::where('name', 'LIKE', '%' . $query . '%')
            ->when($category, function ($builder) use ($category) {
                $builder->where('stock_category', $category);
            })
            ->where('store_id', auth()->user()->store_id)
            ->get();
    }
}

// Mass Assignment Protection
class StockItem extends Model
{
    protected $fillable = [
        'code', 'name', 'category', 'stock_category', 'unit',
        'purchase_price', 'quantity', 'min_quantity', 'max_quantity',
        'location', 'supplier_id', 'description'
    ];
    
    protected $guarded = ['id', 'created_at', 'updated_at'];
}
```

---

## 10. Implementation Checklist

### 10.1 Phase 1: Basic Authentication
- [ ] Install and configure Laravel Sanctum
- [ ] Create User model with roles and permissions
- [ ] Implement login/logout/register endpoints
- [ ] Create permission middleware
- [ ] Set up role-based route protection
- [ ] Implement token management

### 10.2 Phase 2: Advanced Security
- [ ] Add rate limiting to auth endpoints
- [ ] Implement audit logging
- [ ] Set up security event monitoring
- [ ] Add account lockout protection
- [ ] Configure session management
- [ ] Implement permission-based data filtering

### 10.3 Phase 3: Production Hardening
- [ ] Configure HTTPS and security headers
- [ ] Set up CORS for Flutter app
- [ ] Implement token refresh mechanism
- [ ] Add comprehensive input validation
- [ ] Configure production logging
- [ ] Set up security monitoring alerts

---

## 11. Security Testing Requirements

### 11.1 Authentication Tests
```php
// Example Test Cases
class AuthenticationTest extends TestCase
{
    public function test_login_with_valid_credentials()
    {
        $user = User::factory()->create(['status' => UserStatus::ACTIVE]);
        
        $response = $this->postJson('/api/auth/login', [
            'email' => $user->email,
            'password' => 'password',
            'device_name' => 'Test Device'
        ]);
        
        $response->assertStatus(200)
                ->assertJsonStructure(['data' => ['token', 'user', 'permissions']]);
    }
    
    public function test_cannot_access_protected_route_without_token()
    {
        $response = $this->getJson('/api/stock/items');
        $response->assertStatus(401);
    }
    
    public function test_cannot_perform_action_without_permission()
    {
        $user = User::factory()->create();
        $token = $user->createToken('test')->plainTextToken;
        
        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
                         ->postJson('/api/stock/items', ['name' => 'Test Item']);
                         
        $response->assertStatus(403);
    }
}
```

### 11.2 Security Vulnerability Checks
- SQL injection prevention testing
- XSS attack prevention
- CSRF protection verification
- Rate limiting effectiveness
- Token security validation
- Permission bypass attempts
- Store data isolation verification

---

**Document Status**: Complete authorization design for Laravel backend  
**Security Level**: Production-ready with comprehensive RBAC  
**Integration**: Designed specifically for Flutter frontend requirements  
**Next Phase**: Implementation following DATABASE_DESIGN.md and API_DESIGN.md