# CORS Troubleshooting Guide

## Current CORS Issue
The Flutter Web application is experiencing CORS (Cross-Origin Resource Sharing) errors when trying to connect to the Laravel API. This is indicated by the XMLHttpRequest error in the browser console.

## Changes Made

### 1. Laravel Backend Configuration

#### Updated `.env` file:
- Added comprehensive list of common Flutter Web development ports
- Includes localhost and 127.0.0.1 variants for ports: 3000, 4000, 5000, 7357, 8080

#### Updated `config/cors.php`:
- Set `allowed_origins` to `['*']` for local development (more permissive)
- Set `allowed_headers` to `['*']` to allow all headers
- Environment-based configuration (permissive in local, restricted in production)

#### Updated `app/Http/Kernel.php`:
- Added `HandleCors` middleware to global middleware stack
- Ensures CORS headers are applied to ALL requests, including preflight OPTIONS requests

#### Added test endpoints in `routes/api.php`:
- `/api/cors-test` - Test endpoint for CORS verification
- Catch-all OPTIONS route for preflight requests

### 2. Current Configuration

**CORS Origins:** `*` (all origins allowed in local development)
**CORS Headers:** `*` (all headers allowed)
**CORS Methods:** GET, POST, PUT, PATCH, DELETE, OPTIONS
**Supports Credentials:** true

## Testing Steps

### 1. Check Flutter Web Port
First, determine what port Flutter Web is running on:

```bash
cd Catering-Frontend
flutter run -d chrome
```

Note the port number shown (e.g., "Running on http://localhost:12345")

### 2. Test CORS Directly
Open browser developer tools and test in console:

```javascript
// Test basic fetch to health endpoint
fetch('http://127.0.0.1:8000/api/health')
  .then(response => response.json())
  .then(data => console.log('Health check:', data))
  .catch(error => console.error('Error:', error));

// Test CORS-specific endpoint
fetch('http://127.0.0.1:8000/api/cors-test')
  .then(response => response.json())
  .then(data => console.log('CORS test:', data))
  .catch(error => console.error('CORS Error:', error));
```

### 3. Check Network Tab
1. Open browser Developer Tools (F12)
2. Go to Network tab
3. Try to make a request from Flutter Web app
4. Look for:
   - OPTIONS preflight request (should return 200)
   - Actual request (should return expected response)
   - Response headers should include CORS headers

### 4. Verify Laravel Server
Make sure Laravel development server is running:

```bash
cd Catering-Backend
php artisan serve --host=0.0.0.0 --port=8000
```

Expected output should show server running on `http://0.0.0.0:8000`

## Expected CORS Headers
The Laravel server should return these headers for CORS requests:

```
Access-Control-Allow-Origin: * (or the specific origin)
Access-Control-Allow-Methods: GET, POST, PUT, PATCH, DELETE, OPTIONS
Access-Control-Allow-Headers: * (or specific headers)
Access-Control-Allow-Credentials: true
Access-Control-Max-Age: 86400
```

## Common Issues & Solutions

### Issue 1: Wrong Port
**Problem:** Flutter Web runs on port 12345, but CORS only allows 3000, 8080, etc.
**Solution:** Either:
- Use the current permissive `*` configuration (recommended for development)
- Or add the specific port to .env CORS_ALLOWED_ORIGINS

### Issue 2: Preflight Request Fails
**Problem:** OPTIONS request returns 404 or doesn't include CORS headers
**Solution:** 
- Verify HandleCors middleware is in global middleware (✓ Done)
- Verify OPTIONS route is present (✓ Done)
- Clear Laravel cache (pending)

### Issue 3: Laravel Server Not Running
**Problem:** Connection refused or timeout
**Solution:** 
- Start Laravel server: `php artisan serve --host=0.0.0.0 --port=8000`
- Verify server is accessible: `curl http://127.0.0.1:8000/api/health`

### Issue 4: Cache Issues
**Problem:** Old CORS configuration is cached
**Solution:**
```bash
php artisan cache:clear
php artisan config:clear
php artisan route:clear
```

## Debugging Commands

### Test API from Command Line:
```bash
# Test health endpoint
curl -v http://127.0.0.1:8000/api/health

# Test CORS preflight
curl -v -X OPTIONS \
  -H "Origin: http://localhost:12345" \
  -H "Access-Control-Request-Method: GET" \
  -H "Access-Control-Request-Headers: Content-Type" \
  http://127.0.0.1:8000/api/cors-test
```

### Check Laravel Logs:
```bash
tail -f storage/logs/laravel.log
```

## Next Steps

1. **Restart Laravel server** with the new configuration
2. **Clear all caches** if possible
3. **Test with browser console** using the fetch commands above
4. **Check Flutter Web port** and ensure it's included in CORS configuration
5. **Verify network requests** in browser developer tools

## Production Considerations

The current configuration allows all origins (`*`) which is appropriate for development but NOT for production. For production:

1. Update `.env`:
```env
CORS_ALLOWED_ORIGINS=https://yourdomain.com,https://app.yourdomain.com
```

2. Update `config/cors.php` to use specific headers:
```php
'allowed_headers' => [
    'Content-Type',
    'Authorization',
    'Accept',
    'X-Requested-With',
],
```