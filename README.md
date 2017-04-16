navel-broker-client-backend-rabbitmq
====================================

This broker client implements interfaces for [RabbitMQ](http://www.rabbitmq.com/documentation.html).

Status
------

- master

[![Build Status](https://travis-ci.org/Navel-IT/navel-broker-client-backend-rabbitmq.svg?branch=master)](https://travis-ci.org/Navel-IT/navel-broker-client-backend-rabbitmq?branch=master)
[![Coverage Status](https://coveralls.io/repos/github/Navel-IT/navel-broker-client-backend-rabbitmq/badge.svg?branch=master)](https://coveralls.io/github/Navel-IT/navel-broker-client-backend-rabbitmq?branch=master)

- devel

[![Build Status](https://travis-ci.org/Navel-IT/navel-broker-client-backend-rabbitmq.svg?branch=devel)](https://travis-ci.org/Navel-IT/navel-broker-client-backend-rabbitmq?branch=devel)
[![Coverage Status](https://coveralls.io/repos/github/Navel-IT/navel-broker-client-backend-rabbitmq/badge.svg?branch=devel)](https://coveralls.io/github/Navel-IT/navel-broker-client-backend-rabbitmq?branch=devel)

Installation
------------

```bash
cpanm https://github.com/navel-it/navel-broker-client-backend-rabbitmq.git
```

Configuration
-------------

- Publisher (navel-collector-manager)

```json
{
    "publisher_backend": "Navel::Broker::Client::Backend::RabbitMQ::Collector::Publisher",
    "backend_input": {
        "host": "localhost",
        "port": 5672,
        "user": "guest",
        "password": "guest",
        "timeout": 0,
        "vhost": "/",
        "tls": 0,
        "fanout_exchange": "navel-collector-manager-1"
    },
    "queue_size": 0
}
```

- Consumer (navel-dispatcher-manager)

```json
{
    "consumer_backend": "Navel::Broker::Client::Backend::RabbitMQ::Dispatcher::Consumer",
    "consumer_backend_input": {
        "host": "localhost",
        "port": 5672,
        "user": "guest",
        "password": "guest",
        "timeout": 0,
        "vhost": "/",
        "tls": 0,
        "queue": "navel-dispatcher-manager-1",
        "fanout_exchange": "navel-collector-manager-1"
    },
    "consumer_queue_size": 0
}
```

- Publisher (navel-dispatcher-manager)

```json
{
    "publisher_backend": "Navel::Broker::Client::Backend::RabbitMQ::Dispatcher::Publisher",
    "backend_input": {
        "host": "localhost",
        "port": 5672,
        "user": "guest",
        "password": "guest",
        "timeout": 0,
        "vhost": "/",
        "tls": 0,
        "fanout_exchange": "navel-dispatcher-manager-1"
    },
    "publisher_queue_size": 0
}
```

Copyright
---------

Copyright (C) 2015-2017 Yoann Le Garff, Nicolas Boquet and Yann Le Bras

License
-------

navel-broker-client-backend-rabbitmq is licensed under the Apache License, Version 2.0
