use strict;
use warnings;

use Plack::App::OAuth2::Info::Utils;
use Test::More 'tests' => 2;
use Test::NoWarnings;

# Test.
is($Plack::App::OAuth2::Info::Utils::VERSION, 0.01, 'Version.');
