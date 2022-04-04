package Plack::App::OAuth2::Info;

use base qw(Plack::Component::Tags::HTML);
use strict;
use warnings;

use Data::Printer;
use Error::Pure qw(err);
use Plack::App::OAuth2::Info::Utils qw(provider_info);
use Plack::Request;
use Plack::Session;
use Tags::HTML::OAuth2::Info;
use Unicode::UTF8 qw(decode_utf8 encode_utf8);

our $VERSION = 0.01;

sub _check_required_middleware {
	my ($self, $env) = @_;

	# Check use of Session before this app.
	if (! defined $env->{'psgix.session'}) {
		err 'No Plack::Middleware::Session present.';
	}

	# Check use of Plack::Middleware::Auth::OAuth2 before this app.
	my $session = Plack::Session->new($env);
	if (! $session->get('oauth2.obj')) {
		err 'No Plack::Middleware::Auth::OAuth2 present.';
	}

	return;
}

sub _prepare_app {
	my $self = shift;

	$self->{'_tags_html_oauth2_info'} = Tags::HTML::OAuth2::Info->new(
		'tags' => $self->tags,
	);

	return;
}

sub _process_actions {
	my ($self, $env) = @_;

	$self->_check_required_middleware($env);

	my $req = Plack::Request->new($env);
	my $session = Plack::Session->new($env);

	my $oauth2 = $session->get('oauth2.obj');
	$self->{'oauth2'} = {
		id => $session->id,
	};
	my $token_string = $session->get('oauth2.token_string');
	if (defined $token_string) {
		provider_info($session, $self->{'oauth2'});

#		# TODO Fix parameter.
#		if ($self->{'oauth2'}->{'login'}) {
#			my $token_string_dump = $session->get('token_string_dump')
#				|| 0;
#			if ($token_string_dump) {
#				my $token_string_out;
#				p $token_string, 'output' => \$token_string_out;
#				$self->{'oauth2'}->{'token_string'}->{'string'}
#					= $token_string_out;
#				$self->{'oauth2'}->{'token_string'}->{'expires_in'}
#					= $oauth2->access_token->expires_in;
#				$self->{'oauth2'}->{'token_string'}->{'can_refresh_tokens'}
#					= $oauth2->can_refresh_tokens;
#			}
#		}
	} else {
		$self->{'oauth2'}->{'login'} = 0;
		$self->{'oauth2'}->{'error'} = "Token string doesn't defined.";
	}
	if (! $self->{'oauth2'}->{'login'}) {
		$self->{'oauth2'}->{'authorization_url'} = $oauth2->authorization_url;
	}

	return;
}

sub _tags_middle {
	my $self = shift;

	$self->{'_tags_html_oauth2_info'}->process($self->{'oauth2'});

	return;
}

1;
