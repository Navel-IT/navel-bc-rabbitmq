# Copyright 2015 Navel-IT
# navel-bcb-rabbitmq is developed by Yoann Le Garff, Nicolas Boquet and Yann Le Bras under GNU GPL v3

#-> BEGIN

#-> initialization

package Navel::Broker::Publisher::Backend::RabbitMQ 0.1;

use Navel::Base;

use AnyEvent::RabbitMQ 1.19;

use Navel::Utils 'blessed';

# backend features

our $IS_CONNECTABLE = 1;

#-> methods

# mandatory methods

sub publish {
    my ($class, %options) = @_;

    my $routing_key = $options{event}->{collection} . '.' . $options{event}->{status_code};

    $options{logger}->('info', 'sending one event with routing key ' . $routing_key . ' to exchange ' . $options{backend_input}->{exchange} . '.');

    if (my @channels = values %{$options{net}->channels()}) {
        $channels[0]->publish(
            exchange => $options{backend_input}->{exchange},
            routing_key => $routing_key,
            header => {
                delivery_mode => $options{backend_input}->{delivery_mode}
            },
            body => $options{serialized_event}
        );
    } else {
        $options{logger}->('error', 'publisher has no channel opened.');
    }
}

sub connect {
    my ($class, %options) = @_;

    AnyEvent::RabbitMQ->new()->load_xml_spec()->connect(
        host => $options{backend_input}->{host},
        port => $options{backend_input}->{port},
        user => $options{backend_input}->{user},
        pass => $options{backend_input}->{password},
        vhost => $options{backend_input}->{vhost},
        timeout => $options{backend_input}->{timeout},
        tls => $options{backend_input}->{tls},
        tune => {
            heartbeat => $options{backend_input}->{heartbeat}
        },
        on_success => sub {
            my $amqp_connection = shift;

            $options{logger}->('notice', 'successfully connected.');

            $amqp_connection->open_channel(
                on_success => sub {
                    $options{logger}->('notice', 'channel opened.');
                },
                on_failure => sub {
                    $options{logger}->('error',
                        [
                            'channel failure.',
                            \@_
                        ]
                    );
                },
                on_close => sub {
                    $options{logger}->('notice', 'channel closed.');
                }
            );
        },
        on_failure => sub {
            $options{logger}->('error',
                [
                    'failure.',
                    \@_
                ]
            );
        },
        on_read_failure => sub {
            $options{logger}->('error',
                [
                    'read failure.',
                    \@_
                ]
            );
        },
        on_return => sub {
            $options{logger}->('error', 'unable to deliver frame.');
        },
        on_close => sub {
            $options{logger}->('notice', 'disconnected.');
        },
    );
}

sub disconnect {
}

sub is_connected {
    my ($class, %options) = @_;

    is_net_ready($options{net}) && $options{net}->is_open();
}

sub is_connecting {
    my ($class, %options) = @_;

    is_net_ready($options{net}) && $options{net}->{_state} == AnyEvent::RabbitMQ::_ST_OPENING; # Warning, may change
}

sub is_disconnected {
    my ($class, %options) = @_;

    is_net_ready($options{net}) && $options{net}->{_state} == AnyEvent::RabbitMQ::_ST_CLOSED; # Warning, may change
}

sub is_disconnecting {
    my ($class, %options) = @_;

    is_net_ready($options{net}) && $options{net}->{_state} == AnyEvent::RabbitMQ::_ST_CLOSING; # Warning, may change
}

# others methods

sub is_net_ready {
    my $net = shift;

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

Navel::Broker::Publisher::Backend::RabbitMQ

=head1 AUTHOR

Yoann Le Garff, Nicolas Boquet and Yann Le Bras

=head1 LICENSE

GNU GPL v3

=cut
