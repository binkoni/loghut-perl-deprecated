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

package LogHut::TemporaryStore;

use feature ':all';
use FindBin;
use lib "$FindBin::Bin";
use parent 'LogHut::Store';
use Digest::SHA 'sha512_hex';
use Storable;
use LogHut::Debug;
use LogHut::FileUtil;

sub new {
    my $class = shift;
    my %params = @_; undef @_;
    my $self = $class->SUPER::new(%params);
    return $self;
}

sub create {
    my $self = shift;
    my %params = @_; undef @_;
    $self->SUPER::create(update_time => time, %params);
}

sub update_time {
    my $self = shift;
    $self->{_data}->{update_time} = time;
    return $self->update();
}

sub get_update_time {
    my $self = shift;
    return $self->{_data}->{update_time};
}

sub get_expiration_time {
    my $self = shift;
    return $self->{_data}->{expiration_time};
}

sub is_expired {
    my $self = shift;
    $self->{_data}->{expiration_time} or return undef;
    return time - $self->{_data}->{update_time} > $self->{_data}->{expiration_time};
}

return 1;
