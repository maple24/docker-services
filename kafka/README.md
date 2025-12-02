# Kafka Docker Setup

A modern Apache Kafka setup using KRaft mode (without Zookeeper) and Kafka UI for easy cluster management and monitoring.

## 📦 What's Included

- **Apache Kafka**: Distributed streaming platform in KRaft mode (Confluent Platform 7.6.0)
- **KRaft**: Kafka's built-in consensus protocol (replaces Zookeeper)
- **Kafka UI**: Web-based interface for managing and monitoring Kafka clusters

## 🔧 Prerequisites

- Docker Engine 20.10+
- Docker Compose 2.0+
- At least 4GB RAM allocated to Docker
- Ports 9092, 9093, and 9000 available

## ⚙️ Configuration

1. Copy the example environment file:
   ```bash
   cp .env.example .env
   ```

2. Edit `.env` to customize your setup:

### Available Environment Variables

| Variable | Description | Default |
|----------|-------------|---------||
| `KAFKA_NODE_ID` | Kafka node ID for KRaft | `1` |
| `KAFKA_PORT` | Kafka client port | `9092` |
| `KAFKA_CONTROLLER_PORT` | KRaft controller port | `9093` |
| `YOUR_LAN_IP` | LAN IP for network access (use localhost for local-only) | `localhost` |
| `KAFKA_CLUSTER_ID` | Unique cluster ID (generate new for production) | `MkU3OEVBNTcwNTJENDM2Qk` |
| `KAFKA_REPLICATION_FACTOR` | Replication factor for topics | `1` |
| `KAFKA_MIN_ISR` | Minimum in-sync replicas | `1` |
| `KAFKA_NUM_PARTITIONS` | Default number of partitions | `3` |
| `KAFKA_AUTO_CREATE_TOPICS` | Auto-create topics | `true` |
| `KAFKA_LOG_RETENTION_HOURS` | Log retention period | `168` (7 days) |
| `KAFKA_GROUP_INITIAL_REBALANCE_DELAY_MS` | Consumer group rebalance delay | `0` |
| `KAFKA_UI_PORT` | Kafka UI web interface port | `9000` |
| `KAFKA_CLUSTER_NAME` | Cluster name in UI | `local` |

## 🚀 Usage

### Start the Kafka Cluster

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
docker-compose logs -f kafka
```

### Stop the Cluster

```bash
docker-compose down
```

### Stop and Remove All Data

```bash
docker-compose down -v
```

## 🌐 Access Points

- **Kafka Broker**: `localhost:9092` (or `YOUR_LAN_IP:9092` if configured)
- **KRaft Controller**: `localhost:9093` (internal only)
- **Kafka UI**: `http://localhost:9000`

### Accessing from Local Network

To access Kafka from other devices on your local network:

1. Find your machine's LAN IP address:
   ```powershell
   # Windows
   ipconfig | findstr IPv4
   
   # Linux/Mac
   ip addr show | grep inet
   ```

2. Update `.env` file:
   ```bash
   YOUR_LAN_IP=192.168.1.100  # Replace with your actual LAN IP
   ```

3. Restart Kafka:
   ```bash
   docker-compose down
   docker-compose up -d
   ```

4. Connect from other devices using:
   ```
   192.168.1.100:9092
   ```

**Note**: Ensure your firewall allows incoming connections on port 9092.

## 📊 Kafka UI Features

Access the Kafka UI at `http://localhost:9000` to:
- View and manage topics
- Browse messages
- Monitor consumer groups
- View broker configurations
- Create and delete topics
- Inspect topic configurations

## 🔨 Common Operations

### Create a Topic

```bash
docker exec -it kafka-broker kafka-topics \
  --create \
  --bootstrap-server localhost:9092 \
  --replication-factor 1 \
  --partitions 3 \
  --topic my-topic
```

### List Topics

```bash
docker exec -it kafka-broker kafka-topics \
  --list \
  --bootstrap-server localhost:9092
```

### Produce Messages

```bash
docker exec -it kafka-broker kafka-console-producer \
  --bootstrap-server localhost:9092 \
  --topic my-topic
```

### Consume Messages

```bash
docker exec -it kafka-broker kafka-console-consumer \
  --bootstrap-server localhost:9092 \
  --topic my-topic \
  --from-beginning
```

### Describe a Topic

```bash
docker exec -it kafka-broker kafka-topics \
  --describe \
  --bootstrap-server localhost:9092 \
  --topic my-topic
```

## 💾 Data Persistence

Data is persisted in named Docker volumes:
- `kafka-data`: Kafka message logs and KRaft metadata

## 🔍 Troubleshooting

### Connection Issues

If you can't connect to Kafka:
1. Ensure all containers are running: `docker-compose ps`
2. Check logs: `docker-compose logs kafka`
3. Verify ports are not in use: `netstat -an | findstr "9092"`

### Performance Issues

If experiencing slow performance:
- Increase Docker memory allocation (4GB minimum)
- Check `KAFKA_LOG_RETENTION_HOURS` setting
- Monitor disk space for volumes

### Reset Everything

To start fresh:
```bash
docker-compose down -v
docker-compose up -d
```

## 📈 Production Considerations

For production deployments, consider:
- Generating a unique `KAFKA_CLUSTER_ID` using `kafka-storage random-uuid`
- Increasing replication factor (`KAFKA_REPLICATION_FACTOR >= 3`)
- Using multiple brokers/controllers for high availability
- Configuring proper security (SASL/SSL)
- Setting up monitoring (Prometheus/Grafana)
- Tuning memory and JVM settings
- Separating broker and controller roles for large clusters
- Implementing proper backup strategies

## 📚 Examples

Check out the `examples/` directory for practical usage examples:

- **Python**: Producer and consumer examples using `kafka-python`
  - `examples/python/producer.py` - Send messages to Kafka
  - `examples/python/consumer.py` - Consume messages from Kafka
  - See `examples/python/README.md` for detailed instructions

## 🔗 Additional Resources

- [Apache Kafka Documentation](https://kafka.apache.org/documentation/)
- [Confluent Platform Documentation](https://docs.confluent.io/)
- [Kafka UI Documentation](https://docs.kafka-ui.provectus.io/)

## 📝 Notes

- This setup uses KRaft mode (Kafka without Zookeeper)
- Single broker configuration suitable for development
- KRaft is production-ready as of Kafka 3.3+
- For production, use multiple brokers with separated controller roles
- The `CLUSTER_ID` should be unique per cluster (generate with `kafka-storage random-uuid`)

## 🔄 Generating a New Cluster ID

For production, generate a unique cluster ID:

```bash
# Using Docker
docker run --rm confluentinc/cp-kafka:7.6.0 kafka-storage random-uuid

# Update your .env file with the generated UUID
```

---

**Version**: Kafka 7.6.0 (Confluent Platform) - KRaft Mode
**Last Updated**: December 2025
