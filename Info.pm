package Plack::App::OAuth2::Info;

use base qw(Plack::Component::Tags::HTML);
use strict;
use warnings;

use Data::Printer;
use Error::Pure qw(err);
use Plack::Request;
use Plack::Session;
use Unicode::UTF8 qw(decode_utf8 encode_utf8);
use Plack::App::OAuth2::Info::Utils qw(provider_info);

our $VERSION = 0.01;

sub _check_required_middleware {
	my ($self, $env) = @_;

	# Check use of Session before this app.
	if (! defined $env->{'psgix.session'}) {
		err 'No Plack::Middleware::Session present.';
	}

	# Check use of Plack::Middleware::Auth::OAuth2 before this app.
	my $session = Plack::Session->new($env);
	if (! $session->get('oauth2')) {
		err 'No Plack::Middleware::Auth::OAuth2 present.';
	}

	return;
}

sub _process_actions {
	my ($self, $env) = @_;

	$self->_check_required_middleware($env);

	my $req = Plack::Request->new($env);
	my $session = Plack::Session->new($env);

	my $oauth2 = $session->get('oauth2');
	$self->{'oauth2'} = {
		id => $session->id,
	};
	my $token_string = $session->get('token_string');
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

	$self->{'tags'}->put(
		['b', 'html'],
		['b', 'body'],
		['b', 'div'],
		['a', 'class', 'head'],
		['d', 'ID: '.$self->{'oauth2'}->{'id'}],
		['b', 'a'],
		['a', 'style', 'float:right;'],
	);
	if ($self->{'oauth2'}->{'login'}) {
		$self->{'tags'}->put(
			['a', 'href', '/logout'],
			['d', 'Logout'],
		);
	} else {
		$self->{'tags'}->put(
			['a', 'href', $self->{'oauth2'}->{'authorization_url'}],
			['d', 'Login'],
		);
	}
	$self->{'tags'}->put(
		['e', 'a'],
		['b', 'hr'],
		['a', 'style', 'clear:both;'],
		['e', 'hr'],
		['e', 'div'],

		['b', 'div'],
		['a', 'class', 'content'],
	);
	if ($self->{'oauth2'}->{'login'}) {
		$self->{'tags'}->put(
			['b', 'div'],
			['a', 'style', 'border: 1px solid black;'],
		);
		if (exists $self->{'oauth2'}->{'token_string'}
			&& exists $self->{'oauth2'}->{'token_string'}->{'string'}) {

			$self->{'tags'}->put(
				['b', 'a'],
				['a', 'href', '/token_string_dump?view=0'],
				['d', decode_utf8('Vypnout zobrazení dumpu')],
				['e', 'a'],

				['b', 'pre'],
				['d', $self->{'oauth2'}->{'token_string'}->{'string'}],
				['e', 'pre'],

				['b', 'dl'],
				['b', 'dt'],
				['d', 'Token string expired'],
				['e', 'dt'],
				['b', 'dd'],
				['d', $self->{'oauth2'}->{'token_string'}->{'expires_in'}],
				['e', 'dd'],

				['b', 'dt'],
				['d', 'Can refresh token string'],
				['e', 'dt'],
				['b', 'dd'],
				['d', $self->{'oauth2'}->{'token_string'}->{'can_refresh_tokens'}],
				['e', 'dd'],
				['e', 'dl'],
			);
		} else {
			$self->{'tags'}->put(
				['b', 'a'],
				['a', 'href', '/token_string_dump?view=1'],
				['d', 'Zobrazit dump'],
				['e', 'a'],
			);	
		}
		$self->{'tags'}->put(
			['e', 'div'],

			['b', 'img'],
			['a', 'src', $self->{'oauth2'}->{'profile'}->{'picture'}],
			['a', 'style', 'float:right;'],
			['e', 'img'],

			['b', 'dl'],
			['a', 'style', 'clear:left;'],
		);
		foreach my $item ('name', 'given_name', 'family_name', 'email', 'gender', 'locale', 'id') {
			$self->{'tags'}->put(
				['b', 'dt'],
				['d', $item],
				['e', 'dt'],
				['b', 'dd'],
				['d', $self->{'oauth2'}->{'profile'}->{$item} ? decode_utf8($self->{'oauth2'}->{'profile'}->{$item}) : ''],
				['e', 'dd'],
			);
		}
		$self->{'tags'}->put(
			['e', 'dl'],
		);
	} else {
		$self->{'tags'}->put(
			['d', decode_utf8('Obsah není přístupný.')],
			$self->{'oauth2'}->{'error'} ? (
				['b', 'p'],
				['a', 'style', 'color:red'],
				['d', $self->{'oauth2'}->{'error'}],
				['e', 'p'],
			) : (),
		);
	}
	$self->{'tags'}->put(
		['e', 'div'],
		['e', 'body'],
		['e', 'html'],
	);

	return;
}

1;
