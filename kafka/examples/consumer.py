"""
Kafka Consumer Example
Demonstrates how to consume messages from a Kafka topic
"""

from kafka import KafkaConsumer
import json
import signal
import sys

# Global flag for graceful shutdown
running = True

def signal_handler(sig, frame):
    """Handle Ctrl+C for graceful shutdown"""
    global running
    print("\n\nShutting down consumer...")
    running = False

def create_consumer(topic, bootstrap_servers='10.190.164.244:9092', group_id='python-consumer-group'):
    """Create and return a Kafka consumer instance"""
    consumer = KafkaConsumer(
        topic,
        bootstrap_servers=bootstrap_servers,
        group_id=group_id,
        auto_offset_reset='earliest',  # Start from beginning if no offset exists
        enable_auto_commit=True,
        auto_commit_interval_ms=1000,
        value_deserializer=lambda m: json.loads(m.decode('utf-8')),
        key_deserializer=lambda k: k.decode('utf-8') if k else None
    )
    return consumer

def consume_messages(topic='test-topic'):
    """Consume messages from Kafka topic"""
    consumer = create_consumer(topic)
    
    print(f"Starting consumer for topic '{topic}'...")
    print("Waiting for messages (Press Ctrl+C to stop)...\n")
    
    # Register signal handler for graceful shutdown
    signal.signal(signal.SIGINT, signal_handler)
    
    try:
        message_count = 0
        for message in consumer:
            if not running:
                break
                
            message_count += 1
            
            print(f"━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            print(f"Message #{message_count}")
            print(f"  Topic: {message.topic}")
            print(f"  Partition: {message.partition}")
            print(f"  Offset: {message.offset}")
            print(f"  Key: {message.key}")
            print(f"  Timestamp: {message.timestamp}")
            print(f"  Value: {json.dumps(message.value, indent=2)}")
            print(f"━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n")
            
    except Exception as e:
        print(f"✗ Error consuming messages: {e}")
    finally:
        consumer.close()
        print(f"\n✓ Consumer closed. Total messages consumed: {message_count}")

if __name__ == '__main__':
    # Customize these parameters as needed
    TOPIC = 'test-topic'
    
    consume_messages(topic=TOPIC)
