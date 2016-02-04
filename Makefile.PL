# Copyright 2015 Navel-IT
# navel-bcb-rabbitmq is developed by Yoann Le Garff, Nicolas Boquet and Yann Le Bras under GNU GPL v3

#-> BEGIN

#-> initialization

use strict;
use warnings;

use ExtUtils::MakeMaker 6.64;

#-> main

my $min_perl_version = '5.18.0';

WriteMakefile(
    NAME => 'Navel::Broker::Publisher::Backend::RabbitMQ',
    VERSION_FROM => 'lib/Navel/Broker/Publisher/Backend/RabbitMQ.pm',
    ABSTRACT => 'navel-bcb-rabbitmq',
    AUTHOR => 'Yoann Le Garff, Nicolas Boquet and Yann Le Bras',
    LICENSE => 'GNU GPL v3',
    META_MERGE => {
        requires => {
            perl => $min_perl_version
        },
        resources => {
            license => 'http://www.gnu.org/copyleft/gpl.html',
            repository => 'http://github.com/Navel-IT/navel-bcb-rabbitmq'
        },
        no_index => {
            directory => ['t']
        }
    },
    MIN_PERL_VERSION => $min_perl_version,
    PREREQ_PM => {
        'Navel::Base' => 0,
        'AnyEvent::RabbitMQ' => 1.19
    },
    TEST_REQUIRES => {
        'Test::More' => 0,
        'Test::Exception' => 0
    },
    test => {
        TESTS => 't/*.t'
    }
);

#-> END

__END__
