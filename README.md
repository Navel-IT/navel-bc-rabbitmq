navel-bc-rabbitmq
==================

This broker client implements interfaces for [RabbitMQ](http://www.rabbitmq.com/documentation.html).

Status
------

- master

[![Build Status](https://travis-ci.org/Navel-IT/navel-bc-rabbitmq.svg?branch=master)](https://travis-ci.org/Navel-IT/navel-bc-rabbitmq?branch=master)
[![Coverage Status](https://coveralls.io/repos/github/Navel-IT/navel-bc-rabbitmq/badge.svg?branch=master)](https://coveralls.io/github/Navel-IT/navel-bc-rabbitmq?branch=master)

- devel

[![Build Status](https://travis-ci.org/Navel-IT/navel-bc-rabbitmq.svg?branch=devel)](https://travis-ci.org/Navel-IT/navel-bc-rabbitmq?branch=devel)
[![Coverage Status](https://coveralls.io/repos/github/Navel-IT/navel-bc-rabbitmq/badge.svg?branch=devel)](https://coveralls.io/github/Navel-IT/navel-bc-rabbitmq?branch=devel)

Installation
------------

```bash
cpanm https://github.com/navel-it/navel-bc-rabbitmq.git
```

Configuration
-------------

- Publisher (navel-scheduler)

```json
{
    "publisher_backend": "Navel::Broker::Client::RabbitMQ::Scheduler::Publisher",
    "backend_input": {
        "host": "localhost",
        "port": 5672,
        "user": "guest",
        "password": "guest",
        "timeout": 0,
        "vhost": "/",
        "tls": 0,
        "fanout_exchange": "navel-scheduler-1"
    },
    "queue_size": 0
}
```

- Consumer (navel-dispatcher)

```json
{
    "consumer_backend": "Navel::Broker::Client::RabbitMQ::Dispatcher::Consumer",
    "consumer_backend_input": {
        "host": "localhost",
        "port": 5672,
        "user": "guest",
        "password": "guest",
        "timeout": 0,
        "vhost": "/",
        "tls": 0,
        "queue": "navel-dispatcher-1",
        "fanout_exchange": "navel-scheduler-1"
    },
    "consumer_queue_size": 0
}
```

- Publisher (navel-dispatcher)

```json
{
    "publisher_backend": "Navel::Broker::Client::RabbitMQ::Dispatcher::Publisher",
    "backend_input": {
        "host": "localhost",
        "port": 5672,
        "user": "guest",
        "password": "guest",
        "timeout": 0,
        "vhost": "/",
        "tls": 0,
        "fanout_exchange": "navel-dispatcher-1"
    },
    "publisher_queue_size": 0
}
```

Copyright
---------

Copyright (C) 2015-2017 Yoann Le Garff, Nicolas Boquet and Yann Le Bras

License
-------

navel-bc-rabbitmq is licensed under the Apache License, Version 2.0
