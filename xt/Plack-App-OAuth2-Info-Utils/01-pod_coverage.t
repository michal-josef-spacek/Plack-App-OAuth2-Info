use strict;
use warnings;

use Test::NoWarnings;
use Test::Pod::Coverage 'tests' => 2;

# Test.
pod_coverage_ok('Plack::App::OAuth2::Info::Utils', 'Plack::App::OAuth2::Info::Utils is covered.');
