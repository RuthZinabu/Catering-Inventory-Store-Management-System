#!/bin/sh

# Exit on error
set -e

echo "Starting Laravel application..."

# Create necessary directories
mkdir -p /var/log/supervisor
mkdir -p /var/log/nginx
mkdir -p /var/run

# Wait for database to be ready (optional, if using external DB)
if [ -n "$DB_HOST" ]; then
    echo "Waiting for database connection..."
    until nc -z -v -w30 $DB_HOST ${DB_PORT:-3306}
    do
        echo "Waiting for database connection..."
        sleep 5
    done
    echo "Database is ready!"
fi

# Generate application key if not set
if [ -z "$APP_KEY" ]; then
    echo "Generating application key..."
    php artisan key:generate --force
fi

# Clear and cache configuration
echo "Optimizing Laravel..."
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Run database migrations
echo "Running database migrations..."
php artisan migrate --force

# Seed database if SEED_DATABASE is set
if [ "$SEED_DATABASE" = "true" ]; then
    echo "Seeding database..."
    php artisan db:seed --force
fi

# Create storage link if it doesn't exist
if [ ! -L /var/www/html/public/storage ]; then
    echo "Creating storage symlink..."
    php artisan storage:link
fi

# Set proper permissions
chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

echo "Starting services via supervisor..."

# Start supervisor
exec /usr/bin/supervisord -c /etc/supervisord.conf
