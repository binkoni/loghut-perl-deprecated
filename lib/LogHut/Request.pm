# This file is part of LogHut.
#
# LogHut is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# LogHut is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with LogHut.  If not, see <http://www.gnu.org/licenses/>.

package LogHut::Request;

use feature ':all';
use FindBin;
use lib "$FindBin::Bin";
use parent 'LogHut::Object';
use Encode ();
use LogHut::Debug;
use LogHut::URLUtil;

sub new {
    my $class = shift;
    my %params = @_; undef @_;
    my $self = $class->SUPER::new(%params);
    $self->{__env} = $params{env};
    defined $self->{__env} or confess 'No argument $env';
    $self->{__params} = {};
    $self->{__cookies} = {};

    for my $pair (split '&', $self->{__env}->{QUERY_STRING}) {
        ($key, $value) = split '=', $pair;
        $self->{__params}->{Encode::decode 'utf8', LogHut::URLUtil::decode($key)} = Encode::decode 'utf8', LogHut::URLUtil::decode($value);
    }

    my $data;
    {
        local $/;
        undef $/;
        $data = $self->{__env}->{'psgi.input'}->getline();
    }

    for my $pair (split '&', $data) {
        ($key, $value) = split '=', $pair;
        $self->{__params}->{Encode::decode 'utf8', LogHut::URLUtil::decode($key)} = Encode::decode 'utf8', LogHut::URLUtil::decode($value);
    }

    for my $pair (split /;\s?/, $self->{__env}->{HTTP_COOKIE}) {
        ($key, $value) = split '=', $pair;
        $self->{__cookies}->{$key} = $value;
    }

    return $self;
}

sub get_cookie {
    my $self = shift;
    my $key = shift;
    defined $key or confess 'No argument $key';
    $key = LogHut::URLUtil::decode $key;
    my $default_value = shift;
    $self->{__cookies}->{$key} =~ tr/\0//d;
    $self->{__params}->{$key} eq '' and $self->{__params}->{$key} = $default_value;
    return LogHut::URLUtil::decode $self->{__cookies}->{$key};
}

sub get_env {
    my $self = shift;
    return $self->{__env};
}

sub get_param {
    my $self = shift;
    my $key = shift;
    my $default_value = shift;
    defined $key or confess 'No argument $key';
    $self->{__params}->{$key} =~ tr/\0//d;
    $self->{__params}->{$key} eq '' and $self->{__params}->{$key} = $default_value;
    return $self->{__params}->{$key};
}

return 1;
