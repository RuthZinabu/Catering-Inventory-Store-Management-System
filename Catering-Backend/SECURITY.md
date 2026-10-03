# Security Guidelines

## Immediate Actions Required

### 🚨 CRITICAL - Do These First

1. **Generate New APP_KEY**
   ```bash
   php artisan key:generate
   ```

2. **Set Strong Database Password**
   - Update `DB_PASSWORD` in `.env` with a strong password
   - Do not use default or empty passwords

3. **Configure Production Environment**
   ```env
   APP_ENV=production
   APP_DEBUG=false
   LOG_LEVEL=error
   ```

4. **Update Laravel Framework**
   ```bash
   composer update laravel/framework
   ```
   - Current version (10.10) has known vulnerabilities
   - Update to 10.48.22 or later to fix CVE-2024-52301

## Configuration Security

### Environment Variables
- Never commit `.env` files to version control
- Use `.env.example` for configuration templates
- Set appropriate CORS origins in production:
  ```env
  CORS_ALLOWED_ORIGINS=https://yourdomain.com,https://api.yourdomain.com
  SANCTUM_STATEFUL_DOMAINS=yourdomain.com,api.yourdomain.com
  ```

### Database Security
- Use SSL connections: `DB_SSLMODE=require`
- Create dedicated database user with minimal privileges
- Regularly update database credentials

### PHP Configuration
Ensure these PHP settings for security:
```ini
register_argc_argv=Off
expose_php=Off
display_errors=Off
log_errors=On
```

## Authentication & Authorization

### JWT Tokens
- Tokens expire after 24 hours by default
- Use proper token refresh mechanism
- Store tokens securely on client side

### Permissions System
Routes are now protected with permission middleware:
- `permission:permission.name` - Check specific permission
- `store.access` - Verify store access for user

### Rate Limiting
- Authentication endpoints: 5 attempts per minute
- General API: 60 requests per minute per user
- Customize in `RouteServiceProvider.php`

## API Security

### Request Validation
- All inputs are validated using Laravel form requests
- File uploads should be validated for type, size, and content
- Implement additional business rule validation

### Security Headers
Automatically applied to all responses:
- `X-Content-Type-Options: nosniff`
- `X-Frame-Options: DENY`
- `X-XSS-Protection: 1; mode=block`
- `Strict-Transport-Security` (HTTPS only)

### Error Handling
- Debug mode disabled in production
- Generic error messages to prevent information disclosure
- Detailed logs for debugging (server-side only)

## Deployment Security

### HTTPS Configuration
- Force HTTPS in production
- Configure HSTS headers
- Use proper SSL/TLS certificates

### Server Configuration
- Hide server information
- Disable directory browsing
- Configure proper file permissions
- Regular security updates

### Monitoring
- Enable Laravel logging
- Monitor failed authentication attempts
- Set up intrusion detection
- Regular security audits

## Development Security

### Dependencies
- Pin dependency versions in `composer.lock`
- Regular vulnerability scanning
- Update dependencies regularly

### Code Security
- Follow secure coding practices
- Code review for security issues
- Static analysis tools
- Security testing

## Incident Response

### If Security Breach Detected
1. Rotate all secrets (APP_KEY, database passwords, API keys)
2. Invalidate all user sessions/tokens
3. Review access logs
4. Patch vulnerabilities
5. Notify affected users if required

### Regular Security Tasks
- Weekly dependency updates
- Monthly security audits
- Quarterly penetration testing
- Annual security training

## Contact

For security issues, contact: security@yourdomain.com

**Never commit sensitive data to version control**