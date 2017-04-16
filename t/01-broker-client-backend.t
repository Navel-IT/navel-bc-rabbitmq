# Copyright (C) 2015-2017 Yoann Le Garff, Nicolas Boquet and Yann Le Bras
# navel-broker-client-backend-rabbitmq is licensed under the Apache License, Version 2.0

#-> BEGIN

#-> initialization

use strict;
use warnings;

use Test::More tests => 3;

BEGIN {
    use_ok('Navel::Broker::Client::Backend::RabbitMQ::Collector::Publisher');
    use_ok('Navel::Broker::Client::Backend::RabbitMQ::Dispatcher::Consumer');
    use_ok('Navel::Broker::Client::Backend::RabbitMQ::Dispatcher::Publisher');
}

#-> main

#-> END

__END__
