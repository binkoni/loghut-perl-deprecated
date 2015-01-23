#This file is part of LogHut.
#
#LogHut is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation, either version 3 of the License, or
#(at your option) any later version.
#
#LogHut is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#
#You should have received a copy of the GNU General Public License
#along with LogHut.  If not, see <http://www.gnu.org/licenses/>.

package LogHut::Request;

use feature ':all';
use FindBin;
use lib "$FindBin::Bin";
use parent 'LogHut::Object';
use LogHut::Log;
use LogHut::URLUtil;

sub new {
    my $class = shift;
    my %params = @_; undef @_;
    my $self = $class->SUPER::new(%params);
    $self->{env} = $params{env};
    defined $self->{env} or confess 'No argument $env';
    $self->{params} = {};
    $self->{cookies} = {};

    for my $pair (split '&', $self->{env}->{QUERY_STRING}) {
        ($key, $value) = split '=', $pair;
        $self->{params}->{LogHut::URLUtil::decode $key} = LogHut::URLUtil::decode $value;
    }

    my $data;
    $self->{env}->{'psgi.input'}->read($data, $self->{env}->{CONTENT_LENGTH});
    $self->{env}->{'psgi.input'} = 'Closed by LogHut::Request';

    for my $pair (split '&', $data) {
        ($key, $value) = split '=', $pair;
        $self->{params}->{LogHut::URLUtil::decode $key} = LogHut::URLUtil::decode $value;
    }

    for my $pair (split /;\s?/, $self->{env}->{HTTP_COOKIE}) {
        ($key, $value) = split '=', $pair;
        $self->{cookies}->{$key} = $value;
    }

    return $self;
}

sub get_cookie {
    my $self = shift;
    my $key = shift;
    defined $key or confess 'No argument $key';
    return $self->{cookies}->{$key};
}

sub get_env {
    my $self = shift;
    return $self->{env};
}

sub get_param {
    my $self = shift;
    my $key = shift;
    defined $key or confess 'No argument $key';
    return $self->{params}->{$key};
}

return 1;
