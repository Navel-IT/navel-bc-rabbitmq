# Copyright (C) 2015-2016 Yoann Le Garff, Nicolas Boquet and Yann Le Bras
# navel-bc-rabbitmq is licensed under the Apache License, Version 2.0

#-> BEGIN

#-> initialization

use strict;
use warnings;

use Test::More tests => 2;

BEGIN {
    use_ok('Navel::Broker::Client::RabbitMQ::Publisher');
    use_ok('Navel::Broker::Client::RabbitMQ::Consumer');
}

#-> main

#-> END

__END__
