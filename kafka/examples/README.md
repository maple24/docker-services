# Kafka Python Examples

Simple Python examples demonstrating Kafka producer and consumer using `kafka-python` library.

## Prerequisites

- Python 3.7+
- Kafka running (using the docker-compose setup)
- pip (Python package manager)

## Setup

1. **Create a virtual environment** (recommended):
   ```bash
   # Windows
   python -m venv venv
   .\venv\Scripts\activate

   # Linux/Mac
   python3 -m venv venv
   source venv/bin/activate
   ```

2. **Install dependencies**:
   ```bash
   pip install -r requirements.txt
   ```

## Usage

### Start Kafka

First, ensure Kafka is running:
```bash
cd ../..
docker-compose up -d
```

Wait for Kafka to be healthy (check with `docker-compose ps`).

### Run the Producer

In one terminal:
```bash
python producer.py
```

This will:
- Create a topic called `test-topic` (if auto-create is enabled)
- Produce 10 sample messages
- Display confirmation for each sent message

**Sample output:**
```
Starting to produce 10 messages to topic 'test-topic'...
✓ Sent message 0: Topic=test-topic, Partition=0, Offset=0
✓ Sent message 1: Topic=test-topic, Partition=1, Offset=0
✓ Sent message 2: Topic=test-topic, Partition=2, Offset=0
...
✓ Successfully produced 10 messages!
```

### Run the Consumer

In another terminal:
```bash
python consumer.py
```

This will:
- Subscribe to `test-topic`
- Start consuming messages from the beginning
- Display each message with metadata
- Run continuously until Ctrl+C

**Sample output:**
```
Starting consumer for topic 'test-topic'...
Waiting for messages (Press Ctrl+C to stop)...

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Message #1
  Topic: test-topic
  Partition: 0
  Offset: 0
  Key: key-0
  Timestamp: 1701518400000
  Value: {
    "id": 0,
    "timestamp": "2025-12-02T10:30:00.123456",
    "message": "Hello from Kafka! Message #0",
    "data": {
      "value": 0,
      "status": "active"
    }
  }
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Press **Ctrl+C** to stop the consumer gracefully.

## Configuration

### Customizing Connection

If your Kafka is on a different host or using LAN IP:

**In producer.py:**
```python
producer = create_producer(bootstrap_servers='192.168.1.100:9092')
```

**In consumer.py:**
```python
consumer = create_consumer(topic, bootstrap_servers='192.168.1.100:9092')
```

### Changing Topic

Modify the `TOPIC` variable in either script:
```python
TOPIC = 'my-custom-topic'
```

### Consumer Groups

Multiple consumers with the same `group_id` will share message consumption (load balancing):
```python
consumer = create_consumer(topic, group_id='my-consumer-group')
```

Different `group_id` values allow independent consumption of the same messages.

## Code Explanation

### Producer (`producer.py`)

- **KafkaProducer**: Creates a producer instance with JSON serialization
- **send()**: Asynchronously sends messages to a topic
- **get()**: Waits for acknowledgment and returns metadata
- **flush()**: Ensures all buffered messages are sent
- **close()**: Closes the producer connection

### Consumer (`consumer.py`)

- **KafkaConsumer**: Creates a consumer instance subscribed to a topic
- **auto_offset_reset='earliest'**: Start from beginning for new consumers
- **enable_auto_commit=True**: Automatically commit offsets
- **group_id**: Consumer group for load balancing
- Iterates over messages in real-time
- Signal handler for graceful shutdown (Ctrl+C)

## Troubleshooting

### Connection Refused

```
NoBrokersAvailable: NoBrokersAvailable
```

**Solution:**
- Ensure Kafka is running: `docker-compose ps`
- Check Kafka logs: `docker-compose logs kafka`
- Verify connection string matches your setup

### Topic Not Found

If `auto_create_topics_enable` is false, create topic manually:
```bash
docker exec -it kafka-broker kafka-topics \
  --create \
  --bootstrap-server localhost:9092 \
  --replication-factor 1 \
  --partitions 3 \
  --topic test-topic
```

### Messages Not Appearing

- Check consumer group offsets
- Try changing `auto_offset_reset` to `'latest'` or `'earliest'`
- Ensure producer and consumer use the same topic name

## Advanced Examples

### Producer with Partitioning

```python
# Send to specific partition
producer.send(topic, value=message, partition=1)

# Custom partitioner based on key
producer.send(topic, key=user_id, value=message)
```

### Consumer from Specific Offset

```python
from kafka import TopicPartition

consumer = KafkaConsumer(bootstrap_servers='localhost:9092')
tp = TopicPartition('test-topic', 0)
consumer.assign([tp])
consumer.seek(tp, 10)  # Start from offset 10
```

### Batch Processing

```python
# Producer: Batch messages
for i in range(1000):
    producer.send(topic, value=message)
producer.flush()  # Send all at once

# Consumer: Poll with timeout
records = consumer.poll(timeout_ms=1000, max_records=100)
for topic_partition, messages in records.items():
    for message in messages:
        process(message)
```

## References

- [kafka-python Documentation](https://kafka-python.readthedocs.io/)
- [Apache Kafka Documentation](https://kafka.apache.org/documentation/)

---

**Happy Kafka messaging! 🚀**
