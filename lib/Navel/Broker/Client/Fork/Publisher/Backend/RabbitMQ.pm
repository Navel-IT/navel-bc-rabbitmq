# Copyright (C) 2015-2016 Yoann Le Garff, Nicolas Boquet and Yann Le Bras
# navel-bcb-rabbitmq is licensed under the Apache License, Version 2.0

#-> BEGIN

#-> initialization

package Navel::Broker::Client::Fork::Publisher::Backend::RabbitMQ 0.1;

use Navel::Base;

use AnyEvent::RabbitMQ 1.19;

use Navel::Logger::Message;
use Navel::Utils 'blessed';

#-> class variables

my $net;

#-> methods

sub publish {
    my ($done, $meta, $definition, $events) = @_;

    if (my @channels = values %{$net->channels()}) {
        local $@;

        my $serialization_errors = 0;

        Navel::Broker::Client::Fork::Worker::log(
            [
                'info',
                'sending ' . @{$events} . ' event(s) to exchange ' . $definition->{backend_input}->{exchange} . '.'
            ]
        );

        for (@{$events}) {
            my $serialized_event = eval {
                $_->serialize();
            };

            unless ($@) {
                $channels[0]->publish(
                    exchange => $definition->{backend_input}->{exchange},
                    routing_key => $definition->{backend} . '.' . $_->{collection},
                    header => {
                        delivery_mode => $definition->{backend_input}->{delivery_mode}
                    },
                    body => $serialized_event,
                    # on_ack => sub {
                    # },
                    # on_nack => sub {
                    # }
                );
            } else {
                $serialization_errors++;
            }
        }

        Navel::Broker::Client::Fork::Worker::log(
            [
                'err',
                $serialization_errors . ' serialization error(s).'
            ]
        ) if $serialization_errors;
    } else {
        Navel::Broker::Client::Fork::Worker::log(
            [
                'err',
                'publisher has no channel opened.'
            ]
        );
    }

    $done->();
}

sub connect {
    my ($done, $meta, $definition) = @_;

    $net = AnyEvent::RabbitMQ->new()->load_xml_spec()->connect(
        host => $definition->{backend_input}->{host},
        port => $definition->{backend_input}->{port},
        user => $definition->{backend_input}->{user},
        pass => $definition->{backend_input}->{password},
        vhost => $definition->{backend_input}->{vhost},
        timeout => $definition->{backend_input}->{timeout},
        tls => $definition->{backend_input}->{tls},
        tune => {
            heartbeat => $definition->{backend_input}->{heartbeat}
        },
        on_success => sub {
            Navel::Broker::Client::Fork::Worker::log(
                [
                    'notice',
                    'successfully connected.'
                ]
            );

            shift->open_channel(
                on_success => sub {
                    # shift->confirm();

                    Navel::Broker::Client::Fork::Worker::log(
                        [
                            'notice',
                            'channel opened.'
                        ]
                    );
                },
                on_failure => sub {
                    Navel::Broker::Client::Fork::Worker::log(
                        [
                            'err',
                            Navel::Logger::Message->stepped_message('channel failure.', \@_)
                        ]
                    );
                },
                on_close => sub {
                    Navel::Broker::Client::Fork::Worker::log(
                        [
                            'notice',
                            'channel closed.'
                        ]
                    );
                }
            );
        },
        on_failure => sub {
            Navel::Broker::Client::Fork::Worker::log(
                [
                    'err',
                    Navel::Logger::Message->stepped_message('failure.', \@_)
                ]
            );
        },
        on_read_failure => sub {
            Navel::Broker::Client::Fork::Worker::log(
                [
                    'err',
                    Navel::Logger::Message->stepped_message('read failure.', \@_)
                ]
            );
        },
        on_return => sub {
            Navel::Broker::Client::Fork::Worker::log(
                [
                    'err',
                    'unable to deliver frame.'
                ]
            );
        },
        on_close => sub {
            Navel::Broker::Client::Fork::Worker::log(
                [
                    'notice',
                    'disconnected.'
                ]
            );
        },
    );

    $done->();
}

sub disconnect {
    undef $net;

    $_[0]->();
}

sub is_connected {
    shift->(is_net_ready() && $net->is_open());
}

sub is_connecting {
    shift->(is_net_ready() && $net->{_state} == AnyEvent::RabbitMQ::_ST_OPENING); # Warning, may change
}

sub is_disconnected {
    shift->(is_net_ready() && $net->{_state} == AnyEvent::RabbitMQ::_ST_CLOSED); # Warning, may change
}

sub is_disconnecting {
    shift->(is_net_ready() && $net->{_state} == AnyEvent::RabbitMQ::_ST_CLOSING); # Warning, may change
}

sub is_net_ready {
    blessed($net) && $net->isa('AnyEvent::RabbitMQ');
}

# sub AUTOLOAD {}

# sub DESTROY {}

1;

#-> END

__END__

=pod

=encoding utf8

=head1 NAME

Navel::Broker::Client::Fork::Publisher::Backend::RabbitMQ

=head1 COPYRIGHT

Copyright (C) 2015-2016 Yoann Le Garff, Nicolas Boquet and Yann Le Bras

=head1 LICENSE

navel-bcb-rabbitmq is licensed under the Apache License, Version 2.0

=cut
