# Deployment Guide - Todo Today on Tailscale

This guide explains how to deploy the Todo Today application to your `bigbox` server using Docker and Tailscale.

## Prerequisites

- Docker and Docker Compose installed on your bigbox server
- Tailscale account and auth key
- SSH access to your bigbox server
- Git installed on the server

## Architecture

The deployment consists of two main services:

1. **Tailscale Service**: Provides secure networking via Tailscale, giving your app its own hostname on your Tailscale network
2. **Web Service**: The Rails application running on port 3000, accessible via the Tailscale network

The SQLite database is stored in `./db/production.sqlite3` on the host machine, making it easy to backup and move.

## Deployment Steps

### 1. Clone the Repository on bigbox

SSH into your bigbox server and clone the repository:

```bash
ssh bigbox
cd /path/to/your/apps
git clone <repository-url> todo_today
cd todo_today
```

### 2. Configure Environment Variables

The `.env` file has been created with your Tailscale auth key. Review and update if needed:

```bash
nano .env
```

Key variables to verify:
- `TAILSCALE_AUTH_KEY`: Your Tailscale authentication key (already set)
- `TAILSCALE_HOSTNAME`: The hostname for your app on Tailscale (default: `todo-today`)
- `SECRET_KEY_BASE`: Rails secret key (already generated)
- `SEED_DB`: Set to `true` to seed the database on first run

### 3. Build and Start the Services

Build the Docker image and start the services:

```bash
docker-compose up -d
```

This will:
- Build the Rails application Docker image
- Start the Tailscale service and connect to your Tailscale network
- Start the web service and run database migrations
- Seed the database if `SEED_DB=true`

### 4. Verify the Deployment

Check that services are running:

```bash
docker-compose ps
```

View logs:

```bash
# All services
docker-compose logs -f

# Just the web service
docker-compose logs -f web

# Just Tailscale
docker-compose logs -f tailscale
```

### 5. Access Your Application

Once deployed, your application will be accessible via Tailscale at:

```
http://todo-today:3000
```

Or use the Tailscale IP address shown in the logs.

To find your Tailscale IP:

```bash
docker-compose exec tailscale tailscale ip
```

## Managing the Application

### Update the Application

To update to the latest code:

```bash
git pull
docker-compose build
docker-compose up -d
```

### Restart Services

```bash
docker-compose restart
```

### Stop Services

```bash
docker-compose down
```

### View Database

The SQLite database is located at:

```
./db/production.sqlite3
```

To access it:

```bash
docker-compose exec web rails dbconsole
```

## Database Backup

The SQLite database file is stored on the host machine at `./db/production.sqlite3`, making it easy to backup.

### Manual Backup

```bash
# Create a backup
cp ./db/production.sqlite3 ./db/backups/production-$(date +%Y%m%d-%H%M%S).sqlite3
```

### Automated Backups (Optional)

The project includes a backup service that can automatically backup to MinIO. To enable it:

1. Configure MinIO settings in `.env`:
   ```
   MINIO_ENDPOINT=http://your-minio-server:9000
   MINIO_ACCESS_KEY=your_access_key
   MINIO_SECRET_KEY=your_secret_key
   MINIO_BUCKET=todo-backups
   ```

2. Start the backup service:
   ```bash
   docker-compose --profile backup up -d
   ```

## Tailscale Configuration

### Changing the Hostname

To change your app's Tailscale hostname:

1. Update `TAILSCALE_HOSTNAME` in `.env`
2. Restart services: `docker-compose restart`

### Re-authenticating with Tailscale

If you need to re-authenticate or the auth key expires:

1. Generate a new auth key from the Tailscale admin console
2. Update `TAILSCALE_AUTH_KEY` in `.env`
3. Remove the Tailscale state: `docker-compose down -v`
4. Restart: `docker-compose up -d`

## Troubleshooting

### Web service can't connect to the network

If the web service fails to start, check:

1. Tailscale service is running: `docker-compose ps tailscale`
2. Tailscale has connected: `docker-compose logs tailscale`
3. Check for auth key issues in Tailscale logs

### Database migration errors

If migrations fail:

```bash
# Run migrations manually
docker-compose exec web rails db:migrate

# Check database status
docker-compose exec web rails db:migrate:status
```

### Can't access the application

1. Verify Tailscale is connected:
   ```bash
   docker-compose exec tailscale tailscale status
   ```

2. Check web service is healthy:
   ```bash
   docker-compose ps web
   ```

3. Verify you're on the same Tailscale network on your client device

### Viewing detailed logs

```bash
# All logs with timestamps
docker-compose logs -f --timestamps

# Specific service with more detail
docker-compose logs -f --tail=100 web
```

## Moving the Database

Since the database is stored as a file, you can easily move it:

1. Stop the application:
   ```bash
   docker-compose down
   ```

2. Copy the database file:
   ```bash
   scp bigbox:/path/to/todo_today/db/production.sqlite3 ./backup/
   ```

3. To restore on another server:
   ```bash
   scp ./backup/production.sqlite3 newserver:/path/to/todo_today/db/
   ```

4. Restart the application:
   ```bash
   docker-compose up -d
   ```

## Security Notes

- The `.env` file contains sensitive keys. Never commit it to version control (it's in `.gitignore`)
- The Tailscale auth key should be kept secure
- Consider using reusable auth keys for production deployments
- The application is only accessible via your Tailscale network, providing built-in security

## Additional Configuration

### Enable Google OAuth (Optional)

To enable Google OAuth login:

1. Set up OAuth credentials in Google Cloud Console
2. Update `.env`:
   ```
   ENABLE_GOOGLE_OAUTH=true
   GOOGLE_CLIENT_ID=your_client_id
   GOOGLE_CLIENT_SECRET=your_client_secret
   ```
3. Restart: `docker-compose restart web`

### Nginx Reverse Proxy (Optional)

To enable the Nginx reverse proxy:

```bash
docker-compose --profile nginx up -d
```

This adds Nginx in front of Rails, which can improve performance for static assets.
