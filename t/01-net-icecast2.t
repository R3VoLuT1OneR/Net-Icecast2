use warnings;
use strict;
use Test::More;
use Test::Fatal;
use Test::MockModule;
use Net::Icecast2;

my $ua_mock = new Test::MockModule('LWP::UserAgent');
$ua_mock->mock( 'credentials', \&credentials_ok );
$ua_mock->mock( 'get', \&ua_mock_get );

plan tests => 9;

    like(
        exception { new Net::Icecast2 },
        qr/^Missing required arguments: login, password/,
        'Validate require login and password',
    );

    my $net_icecast =  Net::Icecast2->new(
        login    => 'test_login',
        password => 'test_password',
    );

    isa_ok( $net_icecast, 'Net::Icecast2', 'Correct module construction' );

    like(
        exception { $net_icecast->request( '/test?wrong=creadentials' ) },
        qr/^Error on request: wrong credentials/,
        'Wrong credentials error message',
    );

    like(
        exception { $net_icecast->request( '/test_error?request' ) },
        qr/^Error on request: 404 Page Not Found/,
        'Page not found error message',
    );

    is_deeply(
        $net_icecast->request( '/test_success' ),
        { success => 1 },
        'Success response (parse XML)'
    );

done_testing;

sub credentials_ok {
    my $ua = shift;
    is( shift, 'localhost:8000', 'Validate UserAgent url' );
    is( shift, 'Icecast2 Server', 'Validate UserAgent realm' );
    is( shift, 'test_login', 'Validate UserAgent login' );
    is( shift, 'test_password', 'Validate UserAgent password' );
};

sub ua_mock_get {
    my $ua   = shift;
    my $path = shift;
    my $head = new HTTP::Headers;
    my $msg  = '<response><success>1</success></response>';
    my $url  = 'http://localhost:8000/admin';

    $path eq "$url/test?wrong=creadentials"
        and return new HTTP::Response( 401 );

    $path eq "$url/test_error?request"
        and return new HTTP::Response( 404, 'Page Not Found' );

    $path eq "$url/test_success"
        and return new HTTP::Response( 200, 'Ok', $head, $msg );

    new HTTP::Response( 500 );
};

