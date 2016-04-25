# Copyright 2015 Navel-IT
# navel-bcb-rabbitmq is developed by Yoann Le Garff, Nicolas Boquet and Yann Le Bras under GNU GPL v3

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
    my ($done, $publisher_definition, $serialized_events) = @_;

    if (my @channels = values %{$net->channels()}) {
        Navel::Broker::Client::Fork::Worker::log(
            [
                'info',
                'sending ' . @{$serialized_events} . ' event(s) to exchange ' . $publisher_definition->{backend_input}->{exchange} . '.'
            ]
        );

        for (@{$serialized_events}) {
            $channels[0]->publish(
                exchange => $publisher_definition->{backend_input}->{exchange},
                routing_key => $publisher_definition->{backend} . '.' . $publisher_definition->{name},
                header => {
                    delivery_mode => $publisher_definition->{backend_input}->{delivery_mode}
                },
                body => $_,
                # on_ack => sub {
                # },
                # on_nack => sub {
                # }
            );
        }
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
    my ($done, $publisher_definition) = @_;

    $net = AnyEvent::RabbitMQ->new()->load_xml_spec()->connect(
        host => $publisher_definition->{backend_input}->{host},
        port => $publisher_definition->{backend_input}->{port},
        user => $publisher_definition->{backend_input}->{user},
        pass => $publisher_definition->{backend_input}->{password},
        vhost => $publisher_definition->{backend_input}->{vhost},
        timeout => $publisher_definition->{backend_input}->{timeout},
        tls => $publisher_definition->{backend_input}->{tls},
        tune => {
            heartbeat => $publisher_definition->{backend_input}->{heartbeat}
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
    shift->(is_net_ready() && $net == AnyEvent::RabbitMQ::_ST_OPENING); # Warning, may change
}

sub is_disconnected {
    shift->(is_net_ready() && $net == AnyEvent::RabbitMQ::_ST_CLOSED); # Warning, may change
}

sub is_disconnecting {
    shift->(is_net_ready() && $net == AnyEvent::RabbitMQ::_ST_CLOSING); # Warning, may change
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

=head1 AUTHOR

Yoann Le Garff, Nicolas Boquet and Yann Le Bras

=head1 LICENSE

GNU GPL v3

=cut
