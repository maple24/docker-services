# PostgreSQL Docker Setup

A production-ready PostgreSQL database with pgAdmin web interface for easy management, configured for local network access.

## 📦 What's Included

- **PostgreSQL**: Popular open-source relational database (version 16)
- **pgAdmin**: Web-based database management interface
- **Network Access**: Configured to accept connections from local network
- **Performance Tuning**: Optimized settings for common workloads

## 🔧 Prerequisites

- Docker Engine 20.10+
- Docker Compose 2.0+
- At least 2GB RAM allocated to Docker
- Ports 5432 and 5050 available

## ⚙️ Configuration

1. Copy the example environment file:
   ```bash
   cp .env.example .env
   ```

2. **IMPORTANT**: Change default passwords in `.env`:
   ```bash
   POSTGRES_PASSWORD=your_secure_password
   PGADMIN_PASSWORD=your_admin_password
   ```

### Available Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `POSTGRES_VERSION` | PostgreSQL image version | `16-alpine` |
| `POSTGRES_USER` | Database superuser username | `postgres` |
| `POSTGRES_PASSWORD` | Database superuser password | `postgres` |
| `POSTGRES_DB` | Default database name | `postgres` |
| `POSTGRES_PORT` | PostgreSQL port | `5432` |
| `MAX_CONNECTIONS` | Maximum concurrent connections | `200` |
| `SHARED_BUFFERS` | Shared memory buffers | `256MB` |
| `EFFECTIVE_CACHE_SIZE` | OS cache size hint | `1GB` |
| `MAINTENANCE_WORK_MEM` | Memory for maintenance operations | `64MB` |
| `WORK_MEM` | Memory per query operation | `4MB` |
| `PGADMIN_VERSION` | pgAdmin image version | `latest` |
| `PGADMIN_EMAIL` | pgAdmin login email | `admin@admin.com` |
| `PGADMIN_PASSWORD` | pgAdmin login password | `admin` |
| `PGADMIN_EXTERNAL_PORT` | pgAdmin web interface port | `5050` |

## 🚀 Usage

### Start PostgreSQL

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

# PostgreSQL only
docker-compose logs -f postgres

# pgAdmin only
docker-compose logs -f pgadmin
```

### Stop PostgreSQL

```bash
docker-compose down
```

### Stop and Remove All Data

**⚠️ Warning: This will delete all your data!**

```bash
docker-compose down -v
```

## 🌐 Access Points

### PostgreSQL Database

**From Local Machine:**
```
Host: localhost
Port: 5432
Username: postgres (or your POSTGRES_USER)
Password: (your POSTGRES_PASSWORD)
Database: postgres (or your POSTGRES_DB)
```

**From Local Network:**
```
Host: YOUR_SERVER_IP (e.g., 192.168.1.100)
Port: 5432
Username: postgres
Password: (your POSTGRES_PASSWORD)
Database: postgres
```

### pgAdmin Web Interface

Access at: `http://localhost:5050` (or `http://YOUR_SERVER_IP:5050`)

**Login Credentials:**
- Email: admin@admin.com (or your PGADMIN_EMAIL)
- Password: admin (or your PGADMIN_PASSWORD)

## 🔌 Connecting from Local Network

### 1. Find Your Server's IP Address

**Linux:**
```bash
ip addr show | grep inet
# or
hostname -I
```

**Windows:**
```powershell
ipconfig | findstr IPv4
```

### 2. Configure Firewall

**Linux (UFW):**
```bash
sudo ufw allow 5432/tcp
sudo ufw allow 5050/tcp
```

**Linux (firewalld):**
```bash
sudo firewall-cmd --permanent --add-port=5432/tcp
sudo firewall-cmd --permanent --add-port=5050/tcp
sudo firewall-cmd --reload
```

**Windows:**
```powershell
New-NetFirewallRule -DisplayName "PostgreSQL" -Direction Inbound -Protocol TCP -LocalPort 5432 -Action Allow
New-NetFirewallRule -DisplayName "pgAdmin" -Direction Inbound -Protocol TCP -LocalPort 5050 -Action Allow
```

### 3. Connect from Another Device

**Using psql:**
```bash
psql -h 192.168.1.100 -p 5432 -U postgres -d postgres
```

**Using Python:**
```python
import psycopg2

conn = psycopg2.connect(
    host="192.168.1.100",
    port=5432,
    database="postgres",
    user="postgres",
    password="your_password"
)
```

**Using Node.js:**
```javascript
const { Client } = require('pg');

const client = new Client({
  host: '192.168.1.100',
  port: 5432,
  database: 'postgres',
  user: 'postgres',
  password: 'your_password'
});
```

**Connection String Format:**
```
postgresql://postgres:your_password@192.168.1.100:5432/postgres
```

## 🔨 Common Operations

### Connect with psql

```bash
docker exec -it postgresql psql -U postgres
```

### Create a New Database

```bash
docker exec -it postgresql psql -U postgres -c "CREATE DATABASE mydb;"
```

### Create a New User

```bash
docker exec -it postgresql psql -U postgres -c "CREATE USER myuser WITH PASSWORD 'mypassword';"
docker exec -it postgresql psql -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE mydb TO myuser;"
```

### Backup Database

```bash
# Backup to file
docker exec -it postgresql pg_dump -U postgres mydb > backup.sql

# Backup all databases
docker exec -it postgresql pg_dumpall -U postgres > backup_all.sql
```

### Restore Database

```bash
# Restore from file
docker exec -i postgresql psql -U postgres mydb < backup.sql
```

### Check Active Connections

```bash
docker exec -it postgresql psql -U postgres -c "SELECT * FROM pg_stat_activity;"
```

### View Database Size

```bash
docker exec -it postgresql psql -U postgres -c "SELECT pg_database.datname, pg_size_pretty(pg_database_size(pg_database.datname)) AS size FROM pg_database;"
```

## 🎯 Setting Up pgAdmin

1. Access pgAdmin at `http://localhost:5050`
2. Login with your credentials
3. Click "Add New Server"
4. **General Tab:**
   - Name: Local PostgreSQL
5. **Connection Tab:**
   - Host: postgres (use container name)
   - Port: 5432
   - Username: postgres
   - Password: (your POSTGRES_PASSWORD)
   - Save password: ✓
6. Click "Save"

## 📂 Initialization Scripts

Place SQL scripts in `init-scripts/` directory to run on first startup:

```bash
mkdir -p init-scripts
```

**Example: `init-scripts/01-create-schema.sql`**
```sql
CREATE DATABASE myapp;

\c myapp;

CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_users_email ON users(email);
```

Scripts run in alphabetical order on first container start.

## 💾 Data Persistence

Data is persisted in named Docker volumes:
- `postgres-data`: Database files
- `pgadmin-data`: pgAdmin configuration and settings

## ⚡ Performance Tuning

The configuration includes optimized settings. Adjust based on your system:

**For 4GB RAM system:**
```env
SHARED_BUFFERS=1GB
EFFECTIVE_CACHE_SIZE=3GB
MAINTENANCE_WORK_MEM=256MB
WORK_MEM=10MB
```

**For 8GB RAM system:**
```env
SHARED_BUFFERS=2GB
EFFECTIVE_CACHE_SIZE=6GB
MAINTENANCE_WORK_MEM=512MB
WORK_MEM=20MB
```

**For 16GB+ RAM system:**
```env
SHARED_BUFFERS=4GB
EFFECTIVE_CACHE_SIZE=12GB
MAINTENANCE_WORK_MEM=1GB
WORK_MEM=40MB
```

## 🔍 Troubleshooting

### Can't Connect from Network

1. **Check container is running:**
   ```bash
   docker-compose ps
   ```

2. **Verify PostgreSQL is listening:**
   ```bash
   docker exec -it postgresql psql -U postgres -c "SHOW listen_addresses;"
   ```
   Should show: `*`

3. **Check firewall:**
   ```bash
   sudo ufw status
   # or
   sudo firewall-cmd --list-ports
   ```

4. **Test connection:**
   ```bash
   telnet YOUR_SERVER_IP 5432
   ```

### Authentication Failed

- Ensure password in `.env` matches connection attempt
- Check `pg_hba.conf` if you've customized authentication

### Performance Issues

- Increase `shared_buffers` and `effective_cache_size`
- Monitor with: `docker stats postgresql`
- Check slow queries in pgAdmin

### Reset Everything

```bash
docker-compose down -v
docker-compose up -d
```

## 🔐 Security Best Practices

### For Production:

1. **Change Default Passwords:**
   ```bash
   # Strong passwords in .env
   POSTGRES_PASSWORD=$(openssl rand -base64 32)
   PGADMIN_PASSWORD=$(openssl rand -base64 32)
   ```

2. **Restrict Network Access:**
   - Use specific IP ranges in firewall rules
   - Consider VPN for remote access
   - Don't expose pgAdmin to internet

3. **Use SSL/TLS:**
   - Configure PostgreSQL SSL certificates
   - Force SSL connections

4. **Regular Backups:**
   ```bash
   # Add to crontab
   0 2 * * * docker exec postgresql pg_dumpall -U postgres > /backups/postgres-$(date +\%Y\%m\%d).sql
   ```

5. **Limit Privileges:**
   - Create application-specific users
   - Grant minimal required permissions
   - Never use superuser in applications

6. **Monitor Logs:**
   ```bash
   docker-compose logs -f postgres | grep ERROR
   ```

## 📈 Production Considerations

- Use specific version tags (not `latest`)
- Set up automated backups
- Configure replication for high availability
- Use connection pooling (PgBouncer)
- Monitor with Prometheus/Grafana
- Regular vacuum and analyze operations
- Set up log rotation
- Consider using Docker secrets for passwords

## 🔗 Additional Resources

- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [pgAdmin Documentation](https://www.pgadmin.org/docs/)
- [PostgreSQL Performance Tuning](https://wiki.postgresql.org/wiki/Performance_Optimization)
- [PgTune - PostgreSQL Configuration Wizard](https://pgtune.leopard.in.ua/)

## 📝 Notes

- PostgreSQL is configured with `listen_addresses=*` to accept network connections
- Default configuration is optimized for general workloads
- pgAdmin persists server connections across restarts
- Database files are stored in Docker volumes for persistence
- Initialization scripts run only on first startup

---

**Version**: PostgreSQL 16 (Alpine)
**Last Updated**: December 2025
