# CORS Configuration for Flutter Multi-Platform Support

This document outlines the CORS configuration implemented to support Flutter Web, Android, and iOS platforms accessing the same Laravel API.

## Architecture

```
Flutter Web / Android / iOS
        ↓
   Laravel REST API  
        ↓
 Supabase PostgreSQL
```

## Laravel Backend Configuration

### 1. CORS Configuration (`config/cors.php`)

```php
'paths' => ['api/*', 'sanctum/csrf-cookie'],
'allowed_methods' => ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
'allowed_origins' => explode(',', env('CORS_ALLOWED_ORIGINS', '*')),
'allowed_headers' => [
    'Content-Type',
    'Authorization',
    'Accept',
    'X-Requested-With',
    'X-CSRF-TOKEN',
    'X-XSRF-TOKEN',
],
'max_age' => 86400, // 24 hours
'supports_credentials' => true,
```

### 2. Environment Configuration (`.env`)

```env
# CORS Configuration for Flutter Web and Mobile
CORS_ALLOWED_ORIGINS=http://localhost:3000,http://127.0.0.1:3000,http://localhost:8080,http://127.0.0.1:8080

# Sanctum Configuration
SANCTUM_STATEFUL_DOMAINS=localhost,127.0.0.1,::1
```

### 3. Middleware Configuration (`app/Http/Kernel.php`)

Added `HandleCors` middleware to API routes:

```php
'api' => [
    \Illuminate\Http\Middleware\HandleCors::class,
    \Laravel\Sanctum\Http\Middleware\EnsureFrontendRequestsAreStateful::class,
    'throttle:api',
    \Illuminate\Routing\Middleware\SubstituteBindings::class,
],
```

### 4. Health Check Endpoint (`routes/api.php`)

```php
Route::get('health', function () {
    return response()->json([
        'status' => 'ok',
        'message' => 'Catering Inventory API is running',
        'timestamp' => now(),
        'version' => '1.0.0',
        'cors_enabled' => true,
    ]);
});
```

## Flutter Frontend Configuration

### 1. Platform-Specific API URLs (`lib/config/app_config.dart`)

The API base URL is automatically determined based on the platform:

- **Flutter Web**: `http://127.0.0.1:8000/api`
- **Android Emulator**: `http://10.0.2.2:8000/api`
- **iOS Simulator**: `http://localhost:8000/api`
- **Physical Devices**: Configurable LAN IP (e.g., `http://192.168.1.100:8000/api`)

### 2. API Client Updates (`lib/services/api/api_client.dart`)

- Uses `AppConfig.effectiveApiUrl` for dynamic URL configuration
- Handles web platform detection with `kIsWeb`
- Improved device name detection for authentication
- Web-compatible network connectivity checking

### 3. Development Tools

#### API Configuration Widget (`lib/widgets/api_config_widget.dart`)
- Real-time API URL configuration
- Platform information display
- Quick setting buttons for common scenarios

#### API Configuration Screen (`lib/screens/api_config_screen.dart`)
- Connection testing functionality
- Platform-specific setup instructions
- Integration with app navigation

## Platform-Specific Setup

### Flutter Web (Chrome)
- **Development URL**: `http://127.0.0.1:8000/api`
- **CORS**: Configured for localhost origins
- **Authentication**: Uses Bearer token with device name "Web Browser"

### Android Emulator
- **Development URL**: `http://10.0.2.2:8000/api`
- **CORS**: Not applicable (native HTTP client)
- **Authentication**: Uses Bearer token with device name "Android Device"

### iOS Simulator
- **Development URL**: `http://localhost:8000/api`
- **CORS**: Not applicable (native HTTP client)
- **Authentication**: Uses Bearer token with device name "iOS Device"

### Physical Devices
- **Development URL**: Requires manual configuration of LAN IP
- **Setup**: Use API Configuration screen to set custom URL
- **Example**: `http://192.168.1.100:8000/api`

## Authentication Flow

### Login Process
```
1. POST /api/auth/login
   - Credentials + device_name
   - Returns access_token

2. Subsequent requests
   - Header: Authorization: Bearer {token}
   - All platforms use same token format
```

### Token Management
- Stored in `FlutterSecureStorage`
- Automatic refresh on 401 responses
- Platform-agnostic implementation

## Development Workflow

### 1. Start Laravel Server
```bash
cd Catering-Backend
php artisan serve --host=0.0.0.0 --port=8000
```

### 2. Configure API URL (if needed)
- Web: Automatic (uses 127.0.0.1:8000)
- Android Emulator: Automatic (uses 10.0.2.2:8000)
- Physical Device: Use API Configuration screen

### 3. Test Connection
- Use `/api-config` route in development
- Test connection button verifies CORS and API health

## Production Considerations

### 1. CORS Origins
Update `.env` for production domains:
```env
CORS_ALLOWED_ORIGINS=https://yourdomain.com,https://app.yourdomain.com
```

### 2. API URLs
Update `app_config.dart` staging/production URLs:
```dart
case Environment.production:
  return 'https://api.cateringinventory.com/api';
```

### 3. Security
- Remove debug routes in production
- Implement proper SSL certificates
- Use secure token storage

## Troubleshooting

### CORS Errors (Web Only)
1. Check Laravel server is running on correct port
2. Verify CORS_ALLOWED_ORIGINS includes your development URL
3. Ensure HandleCors middleware is enabled
4. Check browser developer tools for specific CORS error

### Connection Issues (Mobile)
1. Verify network connectivity
2. Check firewall settings on development machine
3. For physical devices, ensure correct LAN IP configuration
4. Test with API Configuration screen

### Authentication Issues
1. Verify token is being stored and sent
2. Check device name is being included in login request
3. Ensure Sanctum configuration is correct
4. Test with health endpoint first (no auth required)

## Files Modified

### Laravel Backend
- `config/cors.php` - CORS configuration
- `app/Http/Kernel.php` - Added HandleCors middleware
- `.env` - CORS origins configuration  
- `routes/api.php` - Added health endpoint

### Flutter Frontend
- `lib/config/app_config.dart` - Platform-specific URLs
- `lib/services/api/api_client.dart` - Web compatibility
- `lib/widgets/api_config_widget.dart` - Configuration UI
- `lib/screens/api_config_screen.dart` - Development tools
- `lib/app_wrapper.dart` - Navigation and debug access

## Testing Checklist

- [ ] Laravel server starts successfully
- [ ] Health endpoint returns 200 OK
- [ ] Flutter Web can connect to API
- [ ] Android emulator can connect to API  
- [ ] iOS simulator can connect to API
- [ ] Physical device can connect with custom IP
- [ ] Login works on all platforms
- [ ] Authenticated requests succeed on all platforms
- [ ] CORS preflight OPTIONS requests succeed (Web only)

## Next Steps

1. Test login flow from Flutter Web
2. Verify same API works for Android/iOS without CORS issues
3. Deploy to staging environment
4. Update production CORS configuration
5. Implement proper SSL certificates for production