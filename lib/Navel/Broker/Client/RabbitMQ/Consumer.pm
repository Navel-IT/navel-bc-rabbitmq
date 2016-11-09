# Copyright (C) 2015-2016 Yoann Le Garff, Nicolas Boquet and Yann Le Bras
# navel-bc-rabbitmq is licensed under the Apache License, Version 2.0

#-> BEGIN

#-> initialization

package Navel::Broker::Client::RabbitMQ::Consumer 0.1;

use Navel::Base;

use AnyEvent::RabbitMQ 1.19;

use Navel::Utils::Broker::Client::RabbitMQ;
use Navel::Logger::Message;
use Navel::Utils 'decode_sereal_constructor';

#-> class variables

my $net;

my $decode_sereal_constructor = decode_sereal_constructor;

#-> functions

sub init {
}

sub enable {
    shift->(1);
}

sub disable {
    undef $net;

    shift->(1);
}

sub is_connectable {
    shift->(1, 1);
}

sub connect {
    $net = Navel::Utils::Broker::Client::RabbitMQ::connect(
        host => W::storekeeper()->{consumer_backend_input}->{host},
        port => W::storekeeper()->{consumer_backend_input}->{port},
        user => W::storekeeper()->{consumer_backend_input}->{user},
        pass => W::storekeeper()->{consumer_backend_input}->{password},
        vhost => W::storekeeper()->{consumer_backend_input}->{vhost},
        timeout => W::storekeeper()->{consumer_backend_input}->{timeout},
        tls => W::storekeeper()->{consumer_backend_input}->{tls},
        tune => {
            heartbeat => W::storekeeper()->{consumer_backend_input}->{heartbeat}
        },
        on_channel_opened => sub {
            shift->consume(
                queue => W::storekeeper()->{consumer_backend_input}->{queue},
                on_success => sub {
                    W::log(
                        [
                            'notice',
                            'subscribed to the queue.'
                        ]
                    );
                },
                on_failure => sub {
                    W::log(
                        [
                            'err',
                            Navel::Logger::Message->stepped_message('failure.', \@_)
                        ]
                    );

                    undef $net;
                },
                on_cancel => sub {
                    W::log(
                        [
                            'err',
                            Navel::Logger::Message->stepped_message('cancelled.', \@_)
                        ]
                    );

                    undef $net;
                },
                on_consume => sub {
                    local $@;

                    my @events = eval {
                        @{$decode_sereal_constructor->decode(shift->{body}->{payload})};
                    };

                    unless ($@) {
                        W::log(
                            [
                                'info',
                                'received ' . @events . ' event(s) from queue ' . W::storekeeper()->{consumer_backend_input}->{queue} . '.'
                            ]
                        );

                        W::queue()->enqueue(@events);
                    } else {
                        W::log(
                            [
                                'err',
                                Navel::Logger::Message->stepped_message('an error occurred during the decoding.',
                                    [
                                        $@
                                    ]
                                )
                            ]
                        );
                    }
                }
            );
        },
        on_error => sub {
            undef $net;
        }
    );

    shift->(1);
}

*is_net_ready = \&Navel::Utils::Broker::Client::RabbitMQ::is_net_ready;

sub is_connected {
    shift->(1, Navel::Utils::Broker::Client::RabbitMQ::is_connected($net));
}

sub is_connecting {
    shift->(1, Navel::Utils::Broker::Client::RabbitMQ::is_connecting($net));
}

sub is_disconnected {
    shift->(1, Navel::Utils::Broker::Client::RabbitMQ::is_disconnected($net));
}

sub is_disconnecting {
    shift->(1, Navel::Utils::Broker::Client::RabbitMQ::is_disconnecting($net));
}

1;

#-> END

__END__

=pod

=encoding utf8

=head1 NAME

Navel::Broker::Client::RabbitMQ::Consumer

=head1 COPYRIGHT

Copyright (C) 2015-2016 Yoann Le Garff, Nicolas Boquet and Yann Le Bras

=head1 LICENSE

navel-bc-rabbitmq is licensed under the Apache License, Version 2.0

=cut
