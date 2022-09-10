package Plack::App::OAuth2::Info::Utils;

use base qw(Exporter);
use strict;
use warnings;

use Error::Pure qw(err);
use JSON::XS;
use Readonly;

# Constants.
Readonly::Array our @EXPORT => qw(provider_info);

our $VERSION = 0.01;

sub provider_info {
	my ($session, $oauth2_hr) = @_;

	my $service_provider = $session->get('oauth2.service_provider');
	if ($service_provider eq 'Google') {
		return _google($session, $oauth2_hr);
	} elsif ($service_provider eq 'Wikimedia') {
		return _wikimedia($session, $oauth2_hr);
	} else {
		err "Service provider '$service_provider' doesn't supported.";
	}
}

sub _google {
	my ($session, $oauth2_hr) = @_;

	my $oauth2 = $session->get('oauth2.obj');

	my $res = $oauth2->get('https://www.googleapis.com/userinfo/v2/me');
	if ($res->is_success) {
		$oauth2_hr->{'profile'} = _json()->decode($res->decoded_content);
		$oauth2_hr->{'login'} = 1;
	} else {
		$oauth2_hr->{'error'} = $res->status_line;
		$oauth2_hr->{'login'} = 0;
	}

	return;
}

sub _json {
	my $json = JSON::XS->new;
	$json->boolean_values(0, 1);
	return $json->utf8->allow_nonref;
}

sub _wikimedia {
	my ($session, $oauth2_hr) = @_;

	my $oauth2 = $session->get('oauth2.obj');
	my $res = $oauth2->get('https://meta.wikimedia.org/w/rest.php/oauth2/resource/profile');
	if ($res->is_success) {
		$oauth2_hr->{'profile'} = _json()->decode($res->decoded_content);
		$oauth2_hr->{'login'} = 1;
	} else {
		$oauth2_hr->{'error'} = $res->status_line;
		$oauth2_hr->{'login'} = 0;
	}

	# TODO scopes https://meta.wikimedia.org/w/rest.php/oauth2/resource/scopes
}

1;
