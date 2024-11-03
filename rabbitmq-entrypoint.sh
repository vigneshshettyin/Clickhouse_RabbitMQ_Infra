#!/bin/bash

# Start RabbitMQ server in the background
rabbitmq-server -detached

# Wait until RabbitMQ is ready
until rabbitmqctl await_startup; do
  sleep 1
done

# Set permissions
rabbitmqctl set_permissions -p / ${RABBITMQ_DEFAULT_USER} ".*" ".*" ".*"
rabbitmqctl set_topic_permissions -p / ${RABBITMQ_DEFAULT_USER} amq.topic "eurl_click_analytics" "eurl_click_analytics"

# Bring RabbitMQ server back to foreground
rabbitmq-server
