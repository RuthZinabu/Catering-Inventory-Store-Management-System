# Use official PHP 8.2 FPM Alpine image for smaller size
FROM php:8.2-fpm-alpine

# Set working directory
WORKDIR /var/www/html

# Install system dependencies and PHP extensions
RUN apk add --no-cache \
    git \
    curl \
    libpng-dev \
    libzip-dev \
    zip \
    unzip \
    nginx \
    supervisor \
    mysql-client \
    netcat-openbsd \
    && docker-php-ext-install pdo_mysql zip exif pcntl bcmath gd \
    && docker-php-ext-enable opcache

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copy application files
COPY . .

# Install PHP dependencies with optimizations for production
RUN composer install --no-dev --optimize-autoloader --no-interaction --prefer-dist

# Set proper permissions
# Create Laravel runtime directories and set permissions
RUN mkdir -p \
    /var/www/html/storage/framework/cache/data \
    /var/www/html/storage/framework/sessions \
    /var/www/html/storage/framework/views \
    /var/www/html/storage/logs \
    /var/www/html/bootstrap/cache \
    && chown -R www-data:www-data \
        /var/www/html/storage \
        /var/www/html/bootstrap/cache \
    && chmod -R 775 \
        /var/www/html/storage \
        /var/www/html/bootstrap/cache

# Copy Nginx configuration
COPY docker/nginx.conf /etc/nginx/nginx.conf
COPY docker/default.conf /etc/nginx/http.d/default.conf

# Copy Supervisor configuration
COPY docker/supervisord.conf /etc/supervisord.conf

# Copy PHP production configuration
COPY docker/php.ini /usr/local/etc/php/conf.d/custom.ini

# Expose port 8080 (Render requirement)
EXPOSE 8080

# Create startup script
COPY docker/start.sh /start.sh
RUN chmod +x /start.sh

# Run migrations and start services
CMD ["/start.sh"]
