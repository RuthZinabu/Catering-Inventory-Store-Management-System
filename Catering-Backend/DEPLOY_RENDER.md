# Deploying Laravel Backend to Render

This guide will help you deploy the Catering Inventory System backend to Render using Docker.

## Prerequisites

- A Render account (https://render.com)
- A MySQL database (you can create one on Render or use an external service)
- Your code pushed to a Git repository (GitHub, GitLab, or Bitbucket)

## Deployment Steps

### 1. Set Up MySQL Database on Render

1. Go to your Render dashboard
2. Click **New** → **PostgreSQL** or use **MySQL** from an external provider (Render doesn't provide managed MySQL, so you can use PlanetScale, Railway, or AWS RDS)
3. For PlanetScale (free tier available):
   - Sign up at https://planetscale.com
   - Create a new database
   - Get your connection credentials

### 2. Create Web Service on Render

1. Go to Render Dashboard → **New** → **Web Service**
2. Connect your Git repository
3. Configure the service:
   - **Name**: `catering-backend` (or your preferred name)
   - **Region**: Choose closest to your users
   - **Branch**: `main` (or your deployment branch)
   - **Root Directory**: `Catering-Backend`
   - **Runtime**: Docker
   - **Docker Build Context**: `Catering-Backend`
   - **Dockerfile Path**: `./Dockerfile`
   - **Instance Type**: Free (or Starter for better performance)

### 3. Configure Environment Variables

Add these environment variables in Render dashboard:

#### Required Variables

```bash
# Application
APP_NAME="Catering Inventory System"
APP_ENV=production
APP_DEBUG=false
APP_KEY=base64:YOUR_GENERATED_KEY_HERE
APP_URL=https://your-app-name.onrender.com

# Database (from your MySQL provider)
DB_CONNECTION=mysql
DB_HOST=your-mysql-host
DB_PORT=3306
DB_DATABASE=your-database-name
DB_USERNAME=your-database-username
DB_PASSWORD=your-database-password

# Logging
LOG_CHANNEL=errorlog

# Cache & Session
CACHE_DRIVER=file
SESSION_DRIVER=file
QUEUE_CONNECTION=sync

# Storage
FILESYSTEM_DISK=local

# Optional: Seed database on first deploy
SEED_DATABASE=false
```

#### Generate APP_KEY

To generate a Laravel application key:

```bash
php artisan key:generate --show
```

Or use this PHP command:
```bash
php -r "echo 'base64:' . base64_encode(random_bytes(32)) . PHP_EOL;"
```

### 4. Deploy

1. Click **Create Web Service**
2. Render will automatically:
   - Build the Docker image
   - Install dependencies
   - Run migrations
   - Start the application

### 5. Verify Deployment

1. Once deployed, visit your app URL: `https://your-app-name.onrender.com`
2. Test the health endpoint: `https://your-app-name.onrender.com/api/health`
3. Check logs in Render dashboard for any issues

## Post-Deployment

### Running Artisan Commands

You can run artisan commands via Render Shell:

1. Go to your service dashboard
2. Click **Shell** tab
3. Run commands:
   ```bash
   php artisan migrate
   php artisan db:seed
   php artisan cache:clear
   php artisan config:clear
   ```

### Database Seeding

To seed the database after deployment:

1. Set `SEED_DATABASE=true` in environment variables, OR
2. Run manually via Shell: `php artisan db:seed`

### Setting Up CORS

If your frontend is on a different domain, update CORS settings in `config/cors.php`:

```php
'allowed_origins' => [
    'https://your-frontend.onrender.com',
    'https://your-custom-domain.com',
],
```

### Custom Domain

1. Go to your service **Settings** → **Custom Domain**
2. Add your domain
3. Update your DNS records as instructed

## Troubleshooting

### Build Fails

- Check Render logs for specific errors
- Ensure `Dockerfile` path is correct: `./Dockerfile`
- Verify `docker` directory exists with all config files

### Application Errors

- Check environment variables are set correctly
- Verify database connection credentials
- Review application logs in Render dashboard

### Database Connection Issues

- Ensure database host is accessible from Render
- Check IP allowlisting if using external database
- Verify credentials and database exists

### Storage/Upload Issues

For persistent storage, consider:
- Using AWS S3 for file uploads
- Configuring Laravel filesystem to use S3:
  ```bash
  FILESYSTEM_DISK=s3
  AWS_ACCESS_KEY_ID=your-key
  AWS_SECRET_ACCESS_KEY=your-secret
  AWS_DEFAULT_REGION=us-east-1
  AWS_BUCKET=your-bucket
  ```

## Monitoring

- **Logs**: Available in Render dashboard → **Logs** tab
- **Metrics**: View CPU, memory usage in **Metrics** tab
- **Health Checks**: Render automatically monitors your service

## Updating the Application

1. Push changes to your Git repository
2. Render automatically detects changes and redeploys
3. Or manually deploy from Render dashboard

## Costs

- **Free Tier**: 
  - 750 hours/month (sleeps after 15 min inactivity)
  - Good for testing/development
  
- **Starter Tier** ($7/month):
  - No sleeping
  - Better for production

## Security Recommendations

1. **Never commit `.env` file** - Already in `.gitignore`
2. **Use strong APP_KEY** - Generate unique key
3. **Set APP_DEBUG=false** in production
4. **Use HTTPS** - Render provides SSL automatically
5. **Regularly update dependencies**: `composer update`
6. **Enable database backups** on your MySQL provider

## Support

- Render Docs: https://render.com/docs
- Laravel Docs: https://laravel.com/docs
- Project Issues: Create an issue in your repository

## Notes

- The Dockerfile uses **PHP 8.2 FPM + Nginx** for optimal performance
- **OPcache** is enabled for faster PHP execution
- **Supervisor** manages PHP-FPM and Nginx processes
- Application listens on **port 8080** (Render requirement)
- Automatic migrations run on every deployment
