# Docker Configuration

This document explains the Docker setup for the Catering Inventory System backend.

## Files Structure

```
Catering-Backend/
├── Dockerfile                 # Main Docker configuration
├── .dockerignore             # Files to exclude from build
├── docker/                   # Docker configuration files
│   ├── nginx.conf           # Nginx main configuration
│   ├── default.conf         # Nginx site configuration
│   ├── supervisord.conf     # Process manager configuration
│   ├── php.ini              # PHP production settings
│   └── start.sh             # Container startup script
├── render.yaml              # Render deployment configuration
└── DEPLOY_RENDER.md         # Detailed deployment guide
```

## Local Testing

### Build the Docker Image

```bash
# Navigate to backend directory
cd Catering-Backend

# Build the image
docker build -t catering-backend .
```

### Run the Container Locally

```bash
docker run -d \
  --name catering-api \
  -p 8080:8080 \
  -e APP_KEY="base64:YOUR_KEY_HERE" \
  -e DB_HOST=your-db-host \
  -e DB_DATABASE=your-db-name \
  -e DB_USERNAME=your-db-user \
  -e DB_PASSWORD=your-db-pass \
  catering-backend
```

### View Logs

```bash
# View all logs
docker logs catering-api

# Follow logs in real-time
docker logs -f catering-api
```

### Execute Commands Inside Container

```bash
# Access container shell
docker exec -it catering-api sh

# Run artisan commands
docker exec catering-api php artisan migrate
docker exec catering-api php artisan db:seed
docker exec catering-api php artisan cache:clear
```

### Stop and Remove Container

```bash
# Stop container
docker stop catering-api

# Remove container
docker rm catering-api

# Remove image
docker rmi catering-backend
```

## Docker Compose (Optional)

Create `docker-compose.yml` for local development with database:

```yaml
version: '3.8'

services:
  app:
    build: .
    ports:
      - "8080:8080"
    environment:
      - APP_KEY=base64:YOUR_KEY_HERE
      - DB_HOST=mysql
      - DB_DATABASE=catering_db
      - DB_USERNAME=catering_user
      - DB_PASSWORD=secret
    depends_on:
      - mysql
    volumes:
      - ./storage:/var/www/html/storage

  mysql:
    image: mysql:8.0
    environment:
      MYSQL_DATABASE: catering_db
      MYSQL_USER: catering_user
      MYSQL_PASSWORD: secret
      MYSQL_ROOT_PASSWORD: rootsecret
    ports:
      - "3306:3306"
    volumes:
      - mysql_data:/var/lib/mysql

volumes:
  mysql_data:
```

Run with:
```bash
docker-compose up -d
```

## Configuration Details

### Nginx Configuration
- Listens on port **8080** (Render requirement)
- Serves Laravel from `/var/www/html/public`
- Configured for optimal PHP-FPM communication
- Gzip compression enabled
- Security headers added

### PHP Configuration
- **PHP 8.2 FPM** with Alpine Linux (lightweight)
- **OPcache** enabled for performance
- **256MB** memory limit
- **20MB** max upload size
- Production error logging

### Supervisor
Manages two processes:
1. **PHP-FPM**: Handles PHP requests
2. **Nginx**: Web server

### Startup Script (`start.sh`)
Automatically:
1. Waits for database connection
2. Generates APP_KEY if missing
3. Caches configuration
4. Runs migrations
5. Seeds database (if enabled)
6. Creates storage symlink
7. Starts services

## Performance Optimizations

1. **OPcache**: Caches compiled PHP code
2. **Config/Route/View Caching**: Laravel caching enabled
3. **Composer Optimization**: `--optimize-autoloader` flag
4. **Gzip Compression**: Reduces response size
5. **Alpine Linux**: Smaller image size (~150MB vs 400MB+)

## Security Features

1. **No root user**: Runs as `www-data`
2. **Hidden files protected**: Nginx blocks `.env`, `.git`
3. **Security headers**: X-Frame-Options, X-XSS-Protection
4. **Error display off**: Production PHP settings
5. **Proper file permissions**: 755 for storage directories

## Environment Variables Reference

| Variable | Description | Default |
|----------|-------------|---------|
| `APP_KEY` | Laravel encryption key | None (required) |
| `APP_ENV` | Application environment | production |
| `APP_DEBUG` | Debug mode | false |
| `DB_HOST` | Database host | localhost |
| `DB_PORT` | Database port | 3306 |
| `DB_DATABASE` | Database name | None (required) |
| `DB_USERNAME` | Database user | None (required) |
| `DB_PASSWORD` | Database password | None (required) |
| `SEED_DATABASE` | Seed on startup | false |

## Troubleshooting

### Container won't start
```bash
# Check logs
docker logs catering-api

# Common issues:
# - Missing APP_KEY
# - Database connection failed
# - Permission issues
```

### Database connection failed
```bash
# Test database connectivity
docker exec catering-api nc -zv $DB_HOST $DB_PORT

# Verify environment variables
docker exec catering-api env | grep DB_
```

### Permission errors
```bash
# Fix storage permissions
docker exec catering-api chown -R www-data:www-data storage bootstrap/cache
docker exec catering-api chmod -R 755 storage bootstrap/cache
```

### Clear all caches
```bash
docker exec catering-api php artisan cache:clear
docker exec catering-api php artisan config:clear
docker exec catering-api php artisan route:clear
docker exec catering-api php artisan view:clear
```

## Production Checklist

- [ ] Set `APP_DEBUG=false`
- [ ] Set `APP_ENV=production`
- [ ] Generate unique `APP_KEY`
- [ ] Configure database credentials
- [ ] Set up database backups
- [ ] Configure CORS for frontend domain
- [ ] Enable HTTPS (automatic on Render)
- [ ] Set up monitoring/logging
- [ ] Test all API endpoints
- [ ] Review security headers

## Additional Resources

- [Laravel Deployment Docs](https://laravel.com/docs/10.x/deployment)
- [Render Docker Docs](https://render.com/docs/docker)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [Nginx Documentation](https://nginx.org/en/docs/)
