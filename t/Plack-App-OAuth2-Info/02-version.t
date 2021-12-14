use strict;
use warnings;

use Plack::App::OAuth2::Info;
use Test::More 'tests' => 2;
use Test::NoWarnings;

# Test.
is($Plack::App::OAuth2::Info::VERSION, 0.01, 'Version.');
