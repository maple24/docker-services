# Docker Services Repository

A centralized repository for managing Docker configurations and containerized services. This repository provides pre-configured Docker setups for various services, making it easy to deploy and maintain consistent development and production environments.

## 📋 Repository Purpose

This repository serves as:
- A collection of reusable Docker configurations
- Infrastructure-as-code documentation
- A standardized approach to service deployment
- A reference for Docker best practices

## 🗂️ Repository Structure

```
docker-services/
├── README.md                 # This file
├── .gitignore               # Git ignore rules
├── docker-compose.yml       # Optional: Multi-service orchestration
├── kafka/                   # Kafka service
│   ├── docker-compose.yml
│   ├── README.md
│   └── .env.example
├── gitea/                   # Gitea service
│   ├── docker-compose.yml
│   ├── README.md
│   └── .env.example
└── [service-name]/          # Additional services
    ├── docker-compose.yml (or Dockerfile)
    ├── README.md
    └── .env.example
```

## 🚀 Quick Start

### Running a Single Service

1. Navigate to the service directory:
   ```bash
   cd kafka/
   ```

2. Copy the example environment file:
   ```bash
   cp .env.example .env
   ```

3. Edit `.env` with your configuration

4. Start the service:
   ```bash
   docker-compose up -d
   ```

### Running Multiple Services

Use the root-level `docker-compose.yml` to orchestrate multiple services:

```bash
docker-compose up -d kafka gitea
```

## 📝 Service Naming Conventions

Each service directory should follow these conventions:

- **Directory name**: Lowercase, hyphenated (e.g., `my-service/`)
- **Service name in compose**: Match directory name
- **Container names**: `{service-name}-{component}` (e.g., `kafka-broker`)
- **Network names**: `{service-name}-network`
- **Volume names**: `{service-name}-{purpose}` (e.g., `kafka-data`)

## 🔧 Adding a New Service

1. Create a new directory for your service:
   ```bash
   mkdir my-service && cd my-service
   ```

2. Create required files:
   - `docker-compose.yml` or `Dockerfile`
   - `README.md` (see template below)
   - `.env.example`

3. Document the service in the README with:
   - Service description
   - Prerequisites
   - Configuration options
   - Usage instructions
   - Port mappings
   - Volume information

### Service README Template

```markdown
# Service Name

Brief description of the service.

## Prerequisites
- Docker Engine 20.10+
- Docker Compose 2.0+

## Configuration
Copy `.env.example` to `.env` and configure:
- `VARIABLE_NAME`: Description

## Usage
docker-compose up -d

## Ports
- `8080`: Service port

## Volumes
- `service-data`: Persistent data storage
```

## 🔐 Security Best Practices

- **Never commit `.env` files** - Always use `.env.example` as templates
- **Use secrets management** for sensitive data in production
- **Limit exposed ports** - Only expose necessary ports
- **Use specific image tags** - Avoid `latest` tag in production
- **Regular updates** - Keep base images and services updated
- **Network isolation** - Use custom networks for service isolation

## 📊 Best Practices

### Docker Compose Files
- Use version 3.8+ for compose files
- Define explicit networks
- Use named volumes for data persistence
- Set resource limits (memory, CPU)
- Include health checks
- Use restart policies appropriately

### Image Management
- Use official images when available
- Pin specific versions (e.g., `postgres:15.2`)
- Document image choices in service README

### Environment Variables
- Document all variables in `.env.example`
- Use sensible defaults where possible
- Group related variables together
- Add comments explaining each variable

## 🛠️ Maintenance

### Updating Services
```bash
# Pull latest images
docker-compose pull

# Recreate containers
docker-compose up -d --force-recreate
```

### Cleaning Up
```bash
# Stop and remove containers
docker-compose down

# Remove volumes (careful!)
docker-compose down -v
```

## 📚 Suggested Repository Names

Consider these naming conventions for your GitHub repository:
- `docker-services` (current, descriptive)
- `docker-compose-collection`
- `containerized-services`
- `infra-as-code`
- `docker-stack`
- `homelab-docker` (for personal/homelab use)

## 🤝 Contributing

When adding or modifying services:
1. Test configurations locally
2. Update relevant documentation
3. Follow existing naming conventions
4. Include meaningful commit messages

## 📖 Additional Resources

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Reference](https://docs.docker.com/compose/compose-file/)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)

## 📄 License

Specify your license here (e.g., MIT, Apache 2.0)

---

**Last Updated**: December 2025
