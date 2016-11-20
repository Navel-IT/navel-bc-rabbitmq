# Copyright (C) 2015-2016 Yoann Le Garff, Nicolas Boquet and Yann Le Bras
# navel-bc-rabbitmq is licensed under the Apache License, Version 2.0

#-> BEGIN

#-> initialization

use strict;
use warnings;

use Test::More tests => 3;

BEGIN {
    use_ok('Navel::Broker::Client::RabbitMQ::Scheduler::Publisher');
    use_ok('Navel::Broker::Client::RabbitMQ::Dispatcher::Consumer');
    use_ok('Navel::Broker::Client::RabbitMQ::Dispatcher::Publisher');
}

#-> main

#-> END

__END__
