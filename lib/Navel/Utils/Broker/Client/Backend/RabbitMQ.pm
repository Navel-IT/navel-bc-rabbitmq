# Copyright (C) 2015-2017 Yoann Le Garff, Nicolas Boquet and Yann Le Bras
# navel-broker-client-backend-rabbitmq is licensed under the Apache License, Version 2.0

#-> BEGIN

#-> initialization

package Navel::Utils::Broker::Client::Backend::RabbitMQ 0.1;

use Navel::Base;

use AnyEvent::RabbitMQ 1.19;

use Navel::Logger::Message;
use Navel::Utils qw/
    croak
    blessed
/;

#-> functions

sub connect {
    my %options = @_;

    my ($on_channel_opened, $on_error) = delete @options{qw/
        on_channel_opened
        on_error
    /};

    my $on_failure = sub {
        W::log(
            [
                'err',
                Navel::Logger::Message->stepped_message('failure.', \@_)
            ]
        );

        $on_error->() if ref $on_error eq 'CODE';
    };

    AnyEvent::RabbitMQ->new->load_xml_spec->connect(
        %options,
        on_success => sub {
            W::log(
                [
                    'notice',
                    'connected.'
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

                    $on_channel_opened->(@_) if ref $on_channel_opened eq 'CODE';
                },
                on_failure => $on_failure,
                on_close => sub {
                    W::log(
                        [
                            'notice',
                            'channel closed.'
                        ]
                    );

                    $on_error->() if ref $on_error eq 'CODE';
                }
            );
        },
        on_failure => $on_failure,
        on_read_failure => $on_failure,
        on_return => $on_failure,
        on_close => sub {
            W::log(
                [
                    'notice',
                    'disconnected.'
                ]
            );

            $on_error->() if ref $on_error eq 'CODE';
        }
    );
}

sub is_net_ready {
    my $net = shift;

    blessed($net) && $net->isa('AnyEvent::RabbitMQ');
}

sub is_connected {
    my $net = shift;

    is_net_ready($net) && $net->is_open;
}

sub is_connecting {
    my $net = shift;

    is_net_ready($net) && $net->{_state} == AnyEvent::RabbitMQ::_ST_OPENING; # Warning, may change
}

sub is_disconnected {
    my $net = shift;

    is_net_ready($net) && $net->{_state} == AnyEvent::RabbitMQ::_ST_CLOSED; # Warning, may change
}

sub is_disconnecting {
    my $net = shift;

    is_net_ready($net) && $net->{_state} == AnyEvent::RabbitMQ::_ST_CLOSING; # Warning, may change
}

1;

#-> END

__END__

=pod

=encoding utf8

=head1 NAME

Navel::Utils::Broker::Client::Backend::RabbitMQ

=head1 COPYRIGHT

Copyright (C) 2015-2017 Yoann Le Garff, Nicolas Boquet and Yann Le Bras

=head1 LICENSE

navel-broker-client-backend-rabbitmq is licensed under the Apache License, Version 2.0

=cut
