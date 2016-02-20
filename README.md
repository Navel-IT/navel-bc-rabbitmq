navel-bcb-rabbitmq
==================

[![Build Status](https://travis-ci.org/Navel-IT/navel-bcb-rabbitmq.svg)](https://travis-ci.org/Navel-IT/navel-bcb-rabbitmq)

This broker backend implements interfaces for [RabbitMQ](http://www.rabbitmq.com/documentation.html).

backend_input
-------------

- Publisher

```json
{
    "host": "localhost",
    "port": 5672,
    "user": "guest",
    "password": "guest",
    "timeout": 0,
    "vhost": "/",
    "tls": 0,
    "heartbeat": 30,
    "exchange": "amq.topic",
    "delivery_mode": 2
}
```

- Consumer

Not yet available.
