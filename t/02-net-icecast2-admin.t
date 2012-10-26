use warnings;
use strict;
use Test::More;
use Test::Fatal;
use Test::MockModule;

my $ua_mock = new Test::MockModule('LWP::UserAgent');
$ua_mock->mock( 'get', \&ua_mock_get );

plan tests => 4;

    use_ok( 'Net::Icecast2::Admin' );

    my $icecast_admin = new Net::Icecast2::Admin(
        login    => 'test_admin',
        password => 'test_password',
    );

    isa_ok( $icecast_admin, 'Net::Icecast2::Admin' );

    is_deeply(
        $icecast_admin->stats,
        { message => 'stats success' },
        'Validate correct stats method',
    );

    is_deeply(
        $icecast_admin->list_mounts,
        { message => 'listmounts success' },
        'Validate correct list mounts method',
    );

done_testing;

sub ua_mock_get {
    my $ua   = shift;
    my $path = shift;
    my $head = new HTTP::Headers;

    $path =~ /\/(stats)$/g
        and return new HTTP::Response( 200, '', $head,
        "<request><message>$1 success</message></request>");

    $path =~ /\/(listmounts)$/g
        and return new HTTP::Response( 200, '', $head,
        "<request><source><message>$1 success</message></source></request>");
}
