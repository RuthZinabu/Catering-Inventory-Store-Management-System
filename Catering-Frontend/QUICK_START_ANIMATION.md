# Quick Start: Using the Logo Loading Animation

## 5-Minute Setup Guide

### 1. Basic Usage (Copy & Paste)

Replace any `CircularProgressIndicator` with:

```dart
import 'package:catering_inventory_store_management_system/widgets/logo_loading_transition.dart';

// Instead of:
CircularProgressIndicator()

// Use:
LogoLoadingTransition(size: 120)
```

### 2. Common Scenarios

#### Full-Screen Loading
```dart
Scaffold(
  backgroundColor: Colors.white,
  body: Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        LogoLoadingTransition(size: 140),
        SizedBox(height: 24),
        Text('Loading...', style: TextStyle(color: Colors.grey)),
      ],
    ),
  ),
)
```

#### Button Loading
```dart
ElevatedButton(
  onPressed: isLoading ? null : _handleAction,
  child: isLoading
      ? LogoLoadingTransition(
          size: 24,
          duration: Duration(milliseconds: 1800),
        )
      : Text('Submit'),
)
```

#### Inline/Small Loading
```dart
Row(
  children: [
    Text('Processing'),
    SizedBox(width: 8),
    LogoLoadingTransition(size: 20),
  ],
)
```

### 3. Already Implemented

✅ **Login Screen** - Sign In button  
✅ **Initialization Screen** - App startup

Check these files for examples:
- `lib/screens/auth/login_screen.dart`
- `lib/app_wrapper.dart`

### 4. Accessing API Config (For Testing)

When `AppConfig.isDebug = true`:

1. Launch app
2. Tap "API Config" button on initialization screen
3. Switch between:
   - Localhost: `http://127.0.0.1:8000/api`
   - Production: `https://catering-inventory-store-management.onrender.com/api`

### 5. Customization

```dart
LogoLoadingTransition(
  size: 120,                                    // Logo size
  duration: Duration(milliseconds: 2200),       // Animation speed
  backgroundColor: Colors.white,                // Background
  repeat: true,                                 // Loop or play once
)
```

## Size Recommendations

| Use Case | Size | Duration |
|----------|------|----------|
| Button | 20-28 | 1500-1800ms |
| Inline/Card | 40-60 | 1800-2000ms |
| Dialog | 80-100 | 2000-2200ms |
| Full Screen | 120-160 | 2000-2500ms |
| Splash | 140-180 | 2200-2500ms |

## Testing

```bash
# Run the app
flutter run

# Clean build if issues
flutter clean && flutter pub get && flutter run
```

## Troubleshooting in 3 Steps

1. **Logo not showing?**
   - Run: `flutter pub get`
   - Check: `assets/images/halal_logo.png` exists

2. **Animation stuttering?**
   - Test on physical device (not just emulator)

3. **Wrong colors?**
   - Edit: `lib/widgets/logo_loading_transition.dart`
   - Search: `Color(0xFF1B5E20)` 
   - Replace with your color

## API Testing Screen Locations

**Files to check**:
- `lib/screens/api_config_screen.dart` - Main screen
- `lib/widgets/api_config_widget.dart` - Config widget
- `lib/app_wrapper.dart` - Access button

**Route**: `/api-config`

**Usage**: Helps test app with different backend servers without rebuilding

---

For detailed documentation, see `LOGO_LOADING_ANIMATION.md`
