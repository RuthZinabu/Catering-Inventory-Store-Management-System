# Environment Configuration Guide

This guide explains how to configure the Flutter app for different environments.

## Current API Base URL

The app is currently configured to use:
- **Production/Staging**: `https://catering-inventory-store-management.onrender.com/api`
- **Development**: Platform-specific localhost URLs

## Switching Environments

### Method 1: Using AppConfig (Runtime)

In your app, call:

```dart
import 'package:catering_frontend/config/app_config.dart';

// Set to development (uses localhost)
AppConfig.setEnvironment(Environment.development);

// Set to staging
AppConfig.setEnvironment(Environment.staging);

// Set to production
AppConfig.setEnvironment(Environment.production);
```

### Method 2: Build-Time Configuration

Pass the API URL at compile time:

```bash
# Production build with custom API URL
flutter build apk --dart-define=API_BASE_URL=https://catering-inventory-store-management.onrender.com/api

# iOS Production build
flutter build ios --dart-define=API_BASE_URL=https://catering-inventory-store-management.onrender.com/api

# Web build
flutter build web --dart-define=API_BASE_URL=https://catering-inventory-store-management.onrender.com/api

# Development with local backend
flutter run --dart-define=API_BASE_URL=http://localhost:8000/api
```

### Method 3: Using the In-App API Config Screen

The app includes a built-in API configuration screen for testing:

1. Navigate to Settings → API Configuration
2. Enter the desired API URL
3. Click "Update"
4. The app will use the new URL until you reset to default

**Predefined Quick URLs:**
- Local: `http://127.0.0.1:8000/api`
- Android Emulator: `http://10.0.2.2:8000/api`
- iOS Simulator: `http://localhost:8000/api`
- Production: `https://catering-inventory-store-management.onrender.com/api`

## Platform-Specific Development URLs

### Web Development
```
http://127.0.0.1:8000/api
```
Uses localhost for same-machine development.

### Android Emulator
```
http://10.0.2.2:8000/api
```
The emulator uses `10.0.2.2` to access the host machine's localhost.

### iOS Simulator
```
http://localhost:8000/api
```
Can directly access localhost.

### Physical Devices
```
http://192.168.1.XXX:8000/api
```
Replace with your computer's LAN IP address.

To find your LAN IP:
- **Windows**: `ipconfig` (look for IPv4 Address)
- **macOS/Linux**: `ifconfig` or `ip addr`

## Environment Configuration File

The main configuration is in:
```
lib/config/app_config.dart
```

Key settings:
- `apiBaseUrl`: Returns environment-specific URL
- `effectiveApiUrl`: Returns the actual URL being used (considers overrides)
- `setCustomApiUrl()`: Set a temporary custom URL
- `clearCustomApiUrl()`: Reset to default URL

## Production Deployment Checklist

When building for production:

- [ ] Verify API URL is correct: `https://catering-inventory-store-management.onrender.com/api`
- [ ] Set environment to production in `main.dart`:
  ```dart
  AppConfig.setEnvironment(Environment.production);
  ```
- [ ] Test API connectivity
- [ ] Verify CORS is configured on backend for your domain
- [ ] Disable debug features
- [ ] Test authentication flow
- [ ] Test offline functionality

## Testing Different Environments

### Test Production API
```dart
void main() {
  AppConfig.setEnvironment(Environment.production);
  runApp(MyApp());
}
```

### Test with Custom URL
```dart
void main() {
  AppConfig.setCustomApiUrl('https://catering-inventory-store-management.onrender.com/api');
  runApp(MyApp());
}
```

### Test Development
```dart
void main() {
  AppConfig.setEnvironment(Environment.development);
  runApp(MyApp());
}
```

## CORS Configuration

If you encounter CORS errors when testing from web:

1. Ensure your backend `config/cors.php` includes:
   ```php
   'allowed_origins' => [
       'https://catering-inventory-store-management.onrender.com',
       'http://localhost:*',
   ],
   ```

2. For development, you may need to add:
   ```php
   'allowed_origins_patterns' => [
       '/^http:\/\/localhost(:\d+)?$/',
   ],
   ```

## Troubleshooting

### Connection Refused Error
- **Development**: Ensure Laravel backend is running (`php artisan serve`)
- **Production**: Check if Render service is up
- **Physical Device**: Ensure device is on same network and IP is correct

### CORS Error (Web Only)
- Update backend CORS configuration
- Check browser console for specific error
- Verify the Origin header matches allowed origins

### Certificate Error (HTTPS)
- Ensure using `https://` (not `http://`) for production
- Check if Render SSL certificate is active

### Token/Auth Issues
- Clear app data and re-login
- Check token storage is working
- Verify backend token validation

## Quick Reference

| Environment | Default URL |
|-------------|-------------|
| Development (Web) | http://127.0.0.1:8000/api |
| Development (Android Emulator) | http://10.0.2.2:8000/api |
| Development (iOS Simulator) | http://localhost:8000/api |
| Staging | https://catering-inventory-store-management.onrender.com/api |
| Production | https://catering-inventory-store-management.onrender.com/api |

## Environment Variables

You can override the API URL using environment variables:

```bash
# Set permanently in your shell profile (.bashrc, .zshrc, etc.)
export API_BASE_URL=https://catering-inventory-store-management.onrender.com/api

# Run Flutter with the environment variable
flutter run
```

## Notes

- The app automatically detects the platform and uses appropriate URLs
- Custom URLs set via the UI are temporary and reset on app restart
- Build-time `--dart-define` values are permanent in that build
- Always test authentication after changing API URLs
