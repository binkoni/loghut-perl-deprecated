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

package LogHut::Store;

use feature ':all';
use FindBin;
use lib "$FindBin::Bin";
use parent 'LogHut::Object';
use Digest::SHA 'sha512_hex';
use Storable;
use LogHut::Debug;
use LogHut::FileUtil;

my $__file_util = LogHut::FileUtil->new();

sub new {
    my $class = shift;
    my %params = @_; undef @_;
    my $self = $class->SUPER::new(%params);
    $self->{_file_util} = $__file_util;
    $self->{_directory_path} = $params{directory_path};
    defined $self->{_directory_path} or confess 'No argument $directory_path';
    $self->{_data} = {};
    return $self;
}

sub create {
    my $self = shift;
    my %params = @_; undef @_;
    $self->{_id} = $params{id};
    defined $self->{_id} or confess 'No argument $id';
    undef $params{id};
    for my $key (keys %params) {
        $self->{_data}->{$key} = $params{$key};
    }
    return store $self->{_data}, $self->{_file_util}->join_paths($self->{_directory_path}, $self->{_id}) || confess 'store() failed';
}

sub read {
    my $self = shift;
    $self->{_id} = shift;
    defined $self->{_id} or confess 'No argument $id';
    my $store_path = $self->{_file_util}->join_paths($self->{_directory_path}, $self->{_id});
    -f $store_path or return undef;
    $self->{_data} = retrieve $store_path;
    return $self;
}

sub update {
    my $self = shift;
    defined $self->{_id} or confess 'No attribute $id';
    return $self->create(%{$self->{_data}}, id => $self->{_id});
}

sub delete {
    my $self = shift;
    $self->{_file_util}->unlink($self->{_file_util}->join_paths($self->{_directory_path}, $self->{_id}));
}

sub get_id {
    my $self = shift;
    defined $self->{_id} or confess 'No attribute $id';
    return $self->{_id};
}

sub get_user_data {
    my $self = shift;
    return %{$self->{_data}->{user_data}}; # user_data can be empty
}

sub set_user_data {
    my $self = shift;
    my %params = @_; undef @_;
    $self->{_data}->{user_data} = \%params;
}

return 1;
