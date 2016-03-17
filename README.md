navel-bcb-rabbitmq
==================

This broker backend implements interfaces for [RabbitMQ](http://www.rabbitmq.com/documentation.html).

Status
------

- master

[![Build Status](https://travis-ci.org/Navel-IT/navel-bcb-rabbitmq.svg?branch=master)](https://travis-ci.org/Navel-IT/navel-bcb-rabbitmq?branch=master)
[![Coverage Status](https://coveralls.io/repos/github/Navel-IT/navel-bcb-rabbitmq/badge.svg?branch=master)](https://coveralls.io/github/Navel-IT/navel-bcb-rabbitmq?branch=master)

- devel

[![Build Status](https://travis-ci.org/Navel-IT/navel-bcb-rabbitmq.svg?branch=devel)](https://travis-ci.org/Navel-IT/navel-bcb-rabbitmq?branch=devel)
[![Coverage Status](https://coveralls.io/repos/github/Navel-IT/navel-bcb-rabbitmq/badge.svg?branch=devel)](https://coveralls.io/github/Navel-IT/navel-bcb-rabbitmq?branch=devel)

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
