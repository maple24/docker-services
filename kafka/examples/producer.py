"""
Kafka Producer Example
Demonstrates how to produce messages to a Kafka topic
"""

from kafka import KafkaProducer
import json
import time
from datetime import datetime

def create_producer(bootstrap_servers='10.190.164.244:9092'):
    """Create and return a Kafka producer instance"""
    producer = KafkaProducer(
        bootstrap_servers=bootstrap_servers,
        value_serializer=lambda v: json.dumps(v).encode('utf-8'),
        key_serializer=lambda k: k.encode('utf-8') if k else None
    )
    return producer

def produce_messages(topic='test-topic', num_messages=10):
    """Produce sample messages to Kafka topic"""
    producer = create_producer()
    
    print(f"Starting to produce {num_messages} messages to topic '{topic}'...")
    
    try:
        for i in range(num_messages):
            # Create message
            message = {
                'id': i,
                'timestamp': datetime.now().isoformat(),
                'message': f'Hello from Kafka! Message #{i}',
                'data': {
                    'value': i * 10,
                    'status': 'active'
                }
            }
            
            # Send message with key
            key = f'key-{i}'
            future = producer.send(topic, key=key, value=message)
            
            # Wait for acknowledgment
            record_metadata = future.get(timeout=10)
            
            print(f"✓ Sent message {i}: "
                  f"Topic={record_metadata.topic}, "
                  f"Partition={record_metadata.partition}, "
                  f"Offset={record_metadata.offset}")
            
            # Small delay between messages
            time.sleep(0.5)
            
        print(f"\n✓ Successfully produced {num_messages} messages!")
        
    except Exception as e:
        print(f"✗ Error producing messages: {e}")
    finally:
        producer.flush()
        producer.close()

if __name__ == '__main__':
    # Customize these parameters as needed
    TOPIC = 'test-topic'
    NUM_MESSAGES = 10
    
    produce_messages(topic=TOPIC, num_messages=NUM_MESSAGES)
