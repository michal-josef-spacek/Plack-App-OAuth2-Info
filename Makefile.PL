use lib '.';
use strict;
use warnings;

use inc::Module::Install;

# Definition.
abstract 'Plack OAuth2 info app.';
author 'Michal Josef Spacek <skim@cpan.org>';
author_requires 'English' => 0;
author_requires 'File::Object' => 0;
author_requires 'Test::More' => 0;
author_requires 'Test::NoWarnings' => 0;
author_requires 'Test::Pod' => 0;
author_requires 'Test::Pod::Coverage' => 0;
license 'bsd';
name 'Plack-App-OAuth2-Info';
perl_version 5.008;
readme_from 'Info.pm';
recursive_author_tests('xt');
requires 'Data::Printer' => 0;
requires 'Error::Pure' => 0;
requires 'Plack::Component::Tags::HTML' => 0;
requires 'Plack::Request' => 0;
requires 'Plack::Session' => 0;
requires 'Unicode::UTF8' => 0;
resources 'bugtracker' => 'https://github.com/michal-josef-spacek/Plack-App-OAuth2-Info/issues';
resources 'homepage' => 'https://github.com/michal-josef-spacek/Plack-App-OAuth2-Info';
resources 'repository' => 'git://github.com/michal-josef-spacek/Plack-App-OAuth2-Info';
test_requires 'Test::More' => 0;
test_requires 'Test::NoWarnings' => 0;
tests_recursive;
version '0.01';

# Run.
WriteAll();
