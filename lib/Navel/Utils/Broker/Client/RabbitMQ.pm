# Copyright (C) 2015-2016 Yoann Le Garff, Nicolas Boquet and Yann Le Bras
# navel-bc-rabbitmq is licensed under the Apache License, Version 2.0

#-> BEGIN

#-> initialization

package Navel::Utils::Broker::Client::RabbitMQ 0.1;

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

    AnyEvent::RabbitMQ->new->load_xml_spec->connect(
        %options,
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

                    $on_channel_opened->(@_) if ref $on_channel_opened eq 'CODE';
                },
                on_failure => sub {
                    W::log(
                        [
                            'err',
                            Navel::Logger::Message->stepped_message('channel failure.', \@_)
                        ]
                    );

                    $on_error->() if ref $on_error eq 'CODE';
                },
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
        on_failure => sub {
            W::log(
                [
                    'err',
                    Navel::Logger::Message->stepped_message('failure.', \@_)
                ]
            );

            $on_error->() if ref $on_error eq 'CODE';
        },
        on_read_failure => sub {
            W::log(
                [
                    'err',
                    Navel::Logger::Message->stepped_message('read failure.', \@_)
                ]
            );

            $on_error->() if ref $on_error eq 'CODE';
        },
        on_return => sub {
            W::log(
                [
                    'err',
                    'unable to deliver frame.'
                ]
            );

            $on_error->() if ref $on_error eq 'CODE';
        },
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

# sub AUTOLOAD {}

# sub DESTROY {}

1;

#-> END

__END__

=pod

=encoding utf8

=head1 NAME

Navel::Utils::Broker::Client::RabbitMQ

=head1 COPYRIGHT

Copyright (C) 2015-2016 Yoann Le Garff, Nicolas Boquet and Yann Le Bras

=head1 LICENSE

navel-bc-rabbitmq is licensed under the Apache License, Version 2.0

=cut
