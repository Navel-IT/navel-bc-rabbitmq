# Copyright (C) 2015-2016 Yoann Le Garff, Nicolas Boquet and Yann Le Bras
# navel-bc-rabbitmq is licensed under the Apache License, Version 2.0

#-> BEGIN

#-> initialization

package Navel::Broker::Client::Publisher::RabbitMQ 0.1;

use Navel::Base;

use AnyEvent::RabbitMQ 1.19;

use Navel::Logger::Message;

use Navel::Utils 'blessed';

#-> class variables

my $net;

#-> methods

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
    if (my @channels = values %{$net->channels}) {
        local $@;

        my @events = W::queue()->dequeue;

        W::log(
            [
                'info',
                'sending ' . @events . ' event(s) to exchange ' . W::collector()->{publisher_backend_input}->{exchange} . '.'
            ]
        );

        for (@events) {
            $channels[0]->publish(
                exchange => W::collector()->{publisher_backend_input}->{exchange},
                routing_key => W::collector()->{publisher_backend} . '.' . W::collector()->{collection},
                header => {
                    delivery_mode => W::collector()->{publisher_backend_input}->{delivery_mode}
                },
                body => $_
            );
        }
    } else {
        W::log(
            [
                'err',
                'publisher has no channel opened.'
            ]
        );
    }

    shift->(1);
}

sub connect {
    $net = AnyEvent::RabbitMQ->new->load_xml_spec->connect(
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
        on_success => sub {
            W::log(
                [
                    'notice',
                    'successfully connected.'
                ]
            );

            shift->open_channel(
                on_success => sub {
                    W::log(
                        [
                            'notice',
                            'channel opened.'
                        ]
                    );
                },
                on_failure => sub {
                    W::log(
                        [
                            'err',
                            Navel::Logger::Message->stepped_message('channel failure.', \@_)
                        ]
                    );

                    undef $net;
                },
                on_close => sub {
                    W::log(
                        [
                            'notice',
                            'channel closed.'
                        ]
                    );

                    undef $net;
                }
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
        on_read_failure => sub {
            W::log(
                [
                    'err',
                    Navel::Logger::Message->stepped_message('read failure.', \@_)
                ]
            );

            undef $net;
        },
        on_return => sub {
            W::log(
                [
                    'err',
                    'unable to deliver frame.'
                ]
            );

            undef $net;
        },
        on_close => sub {
            W::log(
                [
                    'notice',
                    'disconnected.'
                ]
            );

            undef $net;
        },
    );

    shift->(1);
}

sub is_net_ready {
    blessed($net) && $net->isa('AnyEvent::RabbitMQ');
}

sub is_connected {
    shift->(1, is_net_ready && $net->is_open);
}

sub is_connecting {
    shift->(1, is_net_ready && $net->{_state} == AnyEvent::RabbitMQ::_ST_OPENING); # Warning, may change
}

sub is_disconnected {
    shift->(1, is_net_ready && $net->{_state} == AnyEvent::RabbitMQ::_ST_CLOSED); # Warning, may change
}

sub is_disconnecting {
    shift->(1, is_net_ready && $net->{_state} == AnyEvent::RabbitMQ::_ST_CLOSING); # Warning, may change
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

navel-bc-rabbitmq is licensed under the Apache License, Version 2.0

=cut
