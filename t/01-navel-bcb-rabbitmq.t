# Copyright (C) 2015 Yoann Le Garff, Nicolas Boquet and Yann Le Bras
# navel-bcb-rabbitmq is licensed under the Apache License, Version 2.0

#-> BEGIN

#-> initialization

use strict;
use warnings;

use Test::More tests => 1;

BEGIN {
    use_ok('Navel::Broker::Client::Fork::Publisher::Backend::RabbitMQ');
}

#-> main

#-> END

__END__
