# Copyright 2015 Navel-IT
# navel-bcb-rabbitmq is developed by Yoann Le Garff, Nicolas Boquet and Yann Le Bras under GNU GPL v3

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
