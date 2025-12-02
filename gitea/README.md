# Gitea Docker Setup

A self-hosted Git service with a lightweight, fast, and easy-to-use web interface. This setup includes Gitea with PostgreSQL database backend.

## 📦 What's Included

- **Gitea**: Self-hosted Git service (rootless mode)
- **PostgreSQL**: Database backend for Gitea
- **Persistent storage**: All data preserved across container restarts

## 🔧 Prerequisites

- Docker Engine 20.10+
- Docker Compose 2.0+
- At least 2GB RAM allocated to Docker
- Ports 3000 and 2222 available (HTTP and SSH)

## ⚙️ Configuration

1. Copy the example environment file:
   ```bash
   cp .env.example .env
   ```

2. Edit `.env` to customize your setup:

### Available Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `GITEA_VERSION` | Gitea image version | `1.21-rootless` |
| `USER_UID` | User ID for Gitea process | `1000` |
| `USER_GID` | Group ID for Gitea process | `1000` |
| `GITEA_HTTP_PORT` | HTTP port for web interface | `3000` |
| `GITEA_SSH_PORT` | SSH port for Git operations | `2222` |
| `GITEA_DOMAIN` | Domain name for Gitea | `localhost` |
| `GITEA_ROOT_URL` | Full URL to Gitea | `http://localhost:3000/` |
| `GITEA_SSH_DOMAIN` | SSH domain (for clone URLs) | `localhost` |
| `POSTGRES_VERSION` | PostgreSQL image version | `15-alpine` |
| `POSTGRES_USER` | PostgreSQL username | `gitea` |
| `POSTGRES_PASSWORD` | PostgreSQL password | `gitea` |
| `POSTGRES_DB` | PostgreSQL database name | `gitea` |

## 🚀 Usage

### Start Gitea

```bash
docker-compose up -d
```

### Check Service Status

```bash
docker-compose ps
```

### View Logs

```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f gitea
```

### Stop Gitea

```bash
docker-compose down
```

### Stop and Remove All Data

```bash
docker-compose down -v
```

## 🌐 Access Points

- **Web Interface**: `http://localhost:3000`
- **SSH Git Access**: `ssh://git@localhost:2222`
- **PostgreSQL**: Internal only (not exposed)

## 🎯 Initial Setup

1. Start the services: `docker-compose up -d`
2. Wait for services to be healthy (30-60 seconds)
3. Navigate to `http://localhost:3000`
4. Complete the initial setup wizard:
   - Database settings are pre-configured
   - Set admin account username and password
   - Configure email settings (optional)
   - Adjust other settings as needed

## 🔨 Common Operations

### Create Your First Repository

1. Log in to Gitea web interface
2. Click the "+" icon in the top right
3. Select "New Repository"
4. Fill in repository details and create

### Clone a Repository (HTTPS)

```bash
git clone http://localhost:3000/username/repo.git
```

### Clone a Repository (SSH)

```bash
git clone ssh://git@localhost:2222/username/repo.git
```

### Add SSH Key

1. Generate SSH key if you don't have one:
   ```bash
   ssh-keygen -t ed25519 -C "your_email@example.com"
   ```
2. Copy your public key: `~/.ssh/id_ed25519.pub`
3. In Gitea: Settings → SSH/GPG Keys → Add Key

### Backup Gitea Data

```bash
# Create backup
docker exec -u git gitea gitea dump -c /etc/gitea/app.ini

# The dump file will be in the gitea-data volume
```

### Restore from Backup

```bash
# Stop services
docker-compose down

# Remove old data
docker volume rm gitea_gitea-data gitea_gitea-db-data

# Start services
docker-compose up -d

# Wait for initialization, then restore
docker cp gitea-dump.zip gitea:/tmp/
docker exec -u git gitea gitea restore -c /etc/gitea/app.ini --from /tmp/gitea-dump.zip
```

## 💾 Data Persistence

Data is persisted in named Docker volumes:
- `gitea-data`: Repositories, attachments, and application data
- `gitea-config`: Configuration files
- `gitea-db-data`: PostgreSQL database

## 🔐 Security Recommendations

### For Production Use:

1. **Change Default Credentials**:
   - Set strong `POSTGRES_PASSWORD` in `.env`
   - Create admin account with strong password

2. **Use HTTPS**:
   - Set up reverse proxy (nginx/traefik) with SSL
   - Update `GITEA_ROOT_URL` to use https://

3. **Configure Email**:
   - Set up SMTP for notifications and password resets
   - Configure in Gitea admin panel

4. **Enable 2FA**:
   - Enable Two-Factor Authentication for admin accounts
   - User Settings → Security → Two-Factor Authentication

5. **Regular Backups**:
   - Schedule automated backups
   - Store backups off-site

6. **Update Regularly**:
   - Keep Gitea and PostgreSQL updated
   - Check release notes before upgrading

## 🔍 Troubleshooting

### Can't Access Web Interface

1. Check if containers are running: `docker-compose ps`
2. Check logs: `docker-compose logs gitea`
3. Verify port 3000 is not in use: `netstat -an | findstr "3000"`

### SSH Clone Not Working

1. Verify SSH port 2222 is accessible
2. Check SSH key is added to Gitea
3. Test SSH connection: `ssh -p 2222 git@localhost`

### Database Connection Issues

1. Check database is healthy: `docker-compose ps gitea-db`
2. Verify credentials in `.env` file
3. Check database logs: `docker-compose logs gitea-db`

### Reset Admin Password

```bash
docker exec -it gitea gitea admin user change-password \
  --username <admin-username> \
  --password <new-password>
```

## 📈 Production Considerations

For production deployments:
- Use a reverse proxy (nginx, Traefik, Caddy) with SSL
- Set up automated backups
- Configure email notifications
- Use strong passwords for all accounts
- Enable security features (2FA, login attempts)
- Monitor logs and set up alerting
- Regular security updates
- Consider using external PostgreSQL for better scalability

## 🔗 Additional Resources

- [Gitea Documentation](https://docs.gitea.io/)
- [Gitea Installation Guide](https://docs.gitea.io/en-us/install-with-docker/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)

## 📝 Notes

- This setup uses rootless mode for better security
- PostgreSQL is used instead of SQLite for better performance
- All data persists across container restarts
- SSH is on port 2222 to avoid conflicts with host SSH

## 🆙 Upgrading Gitea

```bash
# Pull new image
docker-compose pull

# Stop and recreate containers
docker-compose up -d

# Check logs for any migration messages
docker-compose logs -f gitea
```

---

**Version**: Gitea 1.21 (rootless) with PostgreSQL 15
**Last Updated**: December 2025
