#!/bin/sh

set -e

echo "Starting Laravel application..."

# Create necessary directories
mkdir -p /var/log/supervisor
mkdir -p /var/log/nginx
mkdir -p /var/run

# Wait for database to be ready
if [ -n "$DB_HOST" ]; then
    echo "Waiting for database connection..."

    until nc -z -v -w30 "$DB_HOST" "${DB_PORT:-5432}"
    do
        echo "Waiting for database connection..."
        sleep 5
    done

    echo "Database is ready!"
fi

# Verify application key exists
if [ -z "$APP_KEY" ]; then
    echo "ERROR: APP_KEY is not set."
    exit 1
fi

# Optimize Laravel
echo "Optimizing Laravel..."

php artisan config:cache
php artisan route:cache

# Run database migrations
echo "Running database migrations..."

php artisan migrate --force

# Seed database if requested
if [ "$SEED_DATABASE" = "true" ]; then
    echo "Seeding database..."
    php artisan db:seed --force
fi

# Create storage link
if [ ! -L /var/www/html/public/storage ]; then
    echo "Creating storage symlink..."
    php artisan storage:link
fi

# Set permissions
chown -R www-data:www-data \
    /var/www/html/storage \
    /var/www/html/bootstrap/cache

echo "Starting services via supervisor..."

exec /usr/bin/supervisord -c /etc/supervisord.conf