# API Integration Testing Guide

This guide provides step-by-step instructions for testing the Flutter frontend integration with the Laravel backend API.

## Prerequisites

Before testing, ensure you have:

1. **Laravel Backend Running**:
   ```bash
   cd Catering-Backend
   php artisan serve
   # Backend should be running on http://localhost:8000
   ```

2. **Database Seeded**:
   ```bash
   php artisan migrate --seed
   ```

3. **Flutter Dependencies Installed**:
   ```bash
   cd Catering-Frontend
   flutter pub get
   flutter packages pub run build_runner build
   ```

## Test Credentials

The seeded database includes these test accounts (from API documentation):

- **Admin User**: 
  - Email: `admin@cateringinventory.com`
  - Password: `password123`
  - Role: `admin`
  - Access: All stores and permissions

- **Store Manager**:
  - Email: `manager@cateringinventory.com`
  - Password: `password123`
  - Role: `store_manager`
  - Access: Main Warehouse and Cold Storage stores

## Testing Methods

### Method 1: Using the Login Screen (Recommended)

1. **Run the Flutter App**:
   ```bash
   flutter run -t lib/main_api_test.dart
   ```

2. **Test Authentication Flow**:
   - App will show the login screen
   - Enter test credentials (pre-filled for development)
   - Tap "Sign In" button
   - Observe authentication process and error handling

3. **Expected Results**:
   - ✅ **Success**: Navigate to main app interface with user data
   - ❌ **Network Error**: "No internet connection" message
   - ❌ **Invalid Credentials**: "The provided credentials are incorrect"
   - ❌ **Server Error**: Appropriate error message with retry option

### Method 2: Using API Test Screen

1. **Add Test Route to Existing App**:
   - Navigate to `/api-test` route in the app
   - Or modify main app to show API test button

2. **Run Individual API Tests**:
   - **Test Login**: Authenticates with backend
   - **Get Profile**: Fetches current user profile
   - **Get Users**: Lists all users (admin permission required)
   - **Get Stores**: Lists all stores
   - **Get Items**: Lists inventory items
   - **Test Logout**: Clears authentication

3. **Monitor Results**: Each test shows detailed success/error information

### Method 3: Manual Network Testing

1. **Test Network Connectivity**:
   - Turn off WiFi/mobile data
   - Try login → Should show network error
   - Turn on connectivity → Should show "back online" message

2. **Test Backend Downtime**:
   - Stop Laravel server
   - Try API calls → Should show server error
   - Restart server → Should resume normal operation

## Testing Checklist

### Authentication Flow
- [ ] Login with valid credentials succeeds
- [ ] Login with invalid credentials shows appropriate error
- [ ] Password visibility toggle works
- [ ] "Remember me" checkbox functions (optional)
- [ ] Network errors are handled gracefully
- [ ] Token is stored securely
- [ ] User data is cached properly
- [ ] Logout clears all stored data

### API Integration
- [ ] All API services can connect to backend
- [ ] JSON serialization/deserialization works
- [ ] Pagination is handled correctly
- [ ] Search and filtering work
- [ ] Error responses are parsed correctly
- [ ] Loading states are shown appropriately

### Error Handling
- [ ] Network errors show user-friendly messages
- [ ] Authentication errors trigger re-login
- [ ] Validation errors display field-specific messages
- [ ] Server errors show retry options
- [ ] Timeout errors are handled gracefully

### User Experience
- [ ] Loading indicators appear during API calls
- [ ] Success messages confirm completed actions
- [ ] Error snackbars provide helpful information
- [ ] Offline/online notifications work
- [ ] App remains responsive during network operations

## Common Issues and Solutions

### 1. Connection Refused
**Problem**: `Connection refused` or `No route to host`
**Solution**: 
- Ensure Laravel backend is running on `http://localhost:8000`
- Check if port 8000 is available
- Verify network connectivity

### 2. CORS Errors
**Problem**: Cross-Origin Request Blocked
**Solution**:
- Configure Laravel CORS settings
- Add Flutter development server to allowed origins
- Check `config/cors.php` in Laravel backend

### 3. 422 Validation Errors
**Problem**: Validation failed responses
**Solution**:
- Check API request format matches Laravel expectations
- Verify all required fields are included
- Review Laravel validation rules

### 4. Token Expiration
**Problem**: 401 Unauthorized after successful login
**Solution**:
- Check JWT token configuration in Laravel
- Verify token refresh mechanism works
- Ensure secure storage is functioning

### 5. Model Serialization Errors
**Problem**: JSON parsing failures
**Solution**:
- Run `flutter packages pub run build_runner build`
- Verify model fields match API response format
- Check for null safety issues

## Development vs Production Configuration

### Development Settings
```dart
// In app_config.dart
Environment.development → 'http://localhost:8000/api'
enableLogging: true
```

### Production Settings
```dart
// In app_config.dart  
Environment.production → 'https://api.cateringinventory.com/api'
enableLogging: false
```

## Next Steps After Successful Testing

Once authentication is working:

1. **Enable API Services Gradually**:
   ```dart
   ApiRepository.instance.enableApiForUsers();
   ApiRepository.instance.enableApiForStores();
   ApiRepository.instance.enableApiForInventory();
   ```

2. **Replace Mock Data in Screens**:
   - Update existing screens to use ApiRepository
   - Add loading states and error handling
   - Test each screen individually

3. **Implement Offline Support**:
   - Add local caching with sqflite
   - Implement sync mechanisms
   - Handle offline/online transitions

4. **Add Push Notifications**:
   - Integrate Firebase messaging
   - Handle notification callbacks
   - Update UI based on notifications

## Support

If you encounter issues during testing:

1. Check the console output for detailed error messages
2. Verify Laravel backend logs: `tail -f storage/logs/laravel.log`
3. Use network debugging tools to inspect API requests
4. Review the API documentation for endpoint specifications

The authentication flow should work seamlessly once the backend is running and properly configured.