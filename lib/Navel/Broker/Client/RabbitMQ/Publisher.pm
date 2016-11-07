# Copyright (C) 2015-2016 Yoann Le Garff, Nicolas Boquet and Yann Le Bras
# navel-bc-rabbitmq is licensed under the Apache License, Version 2.0

#-> BEGIN

#-> initialization

package Navel::Broker::Client::RabbitMQ::Publisher 0.1;

use Navel::Base;

use AnyEvent::RabbitMQ 1.19;

use Navel::Utils::Broker::Client::RabbitMQ;
use Navel::Logger::Message;
use Navel::Utils 'encode_sereal_constructor';

#-> class variables

my $net;

my $encode_sereal_constructor = encode_sereal_constructor;

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

sub publish {
    my $done = shift;

    if (my @channels = values %{$net->channels}) {
        my $events = W::queue()->dequeue;

        W::log(
            [
                'info',
                'sending ' . @{$events} . ' event(s) to exchange ' . W::collector()->{publisher_backend_input}->{exchange} . '.'
            ]
        );

        my $encoded_events = $encode_sereal_constructor->encode($events);

        $channels[0]->publish(
            exchange => W::collector()->{publisher_backend_input}->{exchange},
            routing_key => W::collector()->{publisher_backend} . '.' . (W::collector()->{backend}->EVENT_CLASS // ''),
            header => {
                delivery_mode => W::collector()->{publisher_backend_input}->{delivery_mode}
            },
            body => $encoded_events,
            on_ack => sub {
                W::log(
                    [
                        'info',
                        'publicaton successfully done.'
                    ]
                );

                $done->(1);
            },
            on_nack => sub {
                W::log(
                    [
                        'warning',
                        'an error occurred during the publicaton.'
                    ]
                );

                my $size_left = W::queue()->size_left;

                W::queue()->enqueue($size_left < 0 ? @{$events} : @{$events}[-$size_left..-1]);

                $done->(1);
            }
        );
    } else {
        W::log(
            [
                'err',
                'publisher has no channel opened.'
            ]
        );
    }
}

sub connect {
    $net = Navel::Utils::Broker::Client::RabbitMQ::connect(
        host => W::collector()->{publisher_backend_input}->{host},
        port => W::collector()->{publisher_backend_input}->{port},
        user => W::collector()->{publisher_backend_input}->{user},
        pass => W::collector()->{publisher_backend_input}->{password},
        vhost => W::collector()->{publisher_backend_input}->{vhost},
        timeout => W::collector()->{publisher_backend_input}->{timeout},
        tls => W::collector()->{publisher_backend_input}->{tls},
        tune => {
            heartbeat => W::collector()->{publisher_backend_input}->{heartbeat}
        },
        on_channel_opened => sub {
            shift->confirm;
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

Navel::Broker::Client::RabbitMQ::Publisher

=head1 COPYRIGHT

Copyright (C) 2015-2016 Yoann Le Garff, Nicolas Boquet and Yann Le Bras

=head1 LICENSE

navel-bc-rabbitmq is licensed under the Apache License, Version 2.0

=cut
