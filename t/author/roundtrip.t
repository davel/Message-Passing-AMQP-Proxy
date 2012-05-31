use strict;
use warnings;
use Test::More;

use AnyEvent;
use Message::Passing::Input::AMQP;
use Message::Passing::Output::AMQP;
use Message::Passing::Output::Test;

my $cv = AnyEvent->condvar;
my $input = Message::Passing::Input::AMQP->new(
    exchange_name => "log_stash_test",
    output_to => Message::Passing::Output::Test->new(
        cb => sub { $cv->send }
    ),
);

my $output = Message::Passing::Output::AMQP->new(
    exchange_name => "log_stash_test",
);

my $this_cv = AnyEvent->condvar;
my $timer; $timer = AnyEvent->timer(after => 2, cb => sub {
    undef $timer;
    $this_cv->send;
});
$this_cv->recv;
$output->consume({foo => 'bar'});
$cv->recv;

is $input->output_to->message_count, 1;
is_deeply([$input->output_to->messages], [{foo => 'bar'}]);

done_testing;
