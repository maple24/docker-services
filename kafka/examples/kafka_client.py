import threading
from kafka import KafkaProducer, KafkaConsumer
from kafka.errors import KafkaError
from loguru import logger
from abc import ABC, abstractmethod


class KafkaClient(ABC):
    """
    An abstract base class for a Kafka client that produces and consumes messages.

    Attributes:
        bootstrap_servers (str): Kafka bootstrap servers.
        produce_topic (str): Kafka topic to produce messages to.
        consume_topics (List[str]): List of Kafka topics to consume messages from.
        group_id (str): Kafka consumer group ID.
    """

    def __init__(
        self,
        bootstrap_servers: str,
        produce_topic: str,
        consume_topics: list[str],
        group_id: str,
    ):
        """
        Initialize the KafkaClient with necessary configurations.

        Args:
            bootstrap_servers (str): Kafka bootstrap servers.
            produce_topic (str): Kafka topic to produce messages to.
            consume_topics (List[str]): List of Kafka topics to consume messages from.
            group_id (str): Kafka consumer group ID.
        """
        self.bootstrap_servers: str = bootstrap_servers
        self.produce_topic: str = produce_topic
        self.consume_topics: list[str] = consume_topics
        self.group_id: str = group_id
        self.producer: KafkaProducer = KafkaProducer(
            bootstrap_servers=self.bootstrap_servers
        )
        self.consumer: KafkaConsumer = KafkaConsumer(
            *self.consume_topics,
            bootstrap_servers=self.bootstrap_servers,
            group_id=self.group_id,
            auto_offset_reset="earliest",
            enable_auto_commit=True,
        )
        self.consumer_thread: threading.Thread = threading.Thread(
            target=self.consume_messages
        )
        self.consumer_thread.daemon = True

    def start(self) -> None:
        """
        Start the consumer thread to listen for messages.
        """
        self.consumer_thread.start()

    def produce_message(self, message: str) -> None:
        """
        Produce a message to the Kafka topic.

        Args:
            message (str): The message to be sent.
        """
        try:
            future = self.producer.send(self.produce_topic, message.encode("utf-8"))
            result = future.get(timeout=10)
            logger.debug(f"Message sent: {result}")
        except KafkaError as e:
            logger.error(f"KafkaError: {e}")

    def consume_messages(self) -> None:
        """
        Consume messages from the Kafka topics and handle them.
        """
        try:
            for message in self.consumer:
                logger.debug(f"Received message: {message.value.decode('utf-8')}")
                self.handle_message(message.value.decode("utf-8"))
        except KafkaError as e:
            logger.error(f"KafkaError: {e}")

    @abstractmethod
    def handle_message(self, message: str) -> None:
        """
        Abstract method to handle consumed messages. This should be implemented by subclasses.

        Args:
            message (str): The message to handle.
        """
        pass


class ExampleService(KafkaClient):
    """
    An example implementation of KafkaClient that handles messages by logging them.
    """

    def handle_message(self, message: str) -> None:
        """
        Handle the consumed message by logging it.

        Args:
            message (str): The message to handle.
        """
        logger.info(f"Handling message: {message}")


if __name__ == "__main__":
    """
    Main entry point for running the Kafka client.
    """
    logger.add("kafka_client.log", rotation="1 MB")

    service = ExampleService(
        bootstrap_servers="10.161.235.42:9094",
        produce_topic="test-topic",
        consume_topics=["test-topic"],
        group_id="test-group",
    )
    service.start()

    # Example of producing a message
    service.produce_message("Test message")

    # Keep the main thread alive to allow consumer thread to run
    try:
        while True:
            pass
    except KeyboardInterrupt:
        logger.info("Stopping Kafka client")
