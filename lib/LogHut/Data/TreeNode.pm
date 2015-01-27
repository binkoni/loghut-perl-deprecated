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

package LogHut::Data::TreeNode;

use feature ':all';
use FindBin;
use lib "$FindBin::Bin/../../";
use parent 'LogHut::Object';
use LogHut::Debug;
no warnings;

sub new {
    my $class = shift;
    my %params = @_; undef @_;
    my $self = $class->SUPER::new(%params);
    $self->{children} = [];
    return $self;
}

sub get_value {
    my $self = shift;
    my $key = shift;
    return $self->{$key};
}

sub set_value {
    my $self = shift;
    my $key = shift;
    my $value = shift;
    $self->{$key} = $value;
    return $self;
}

sub find_child {
    my $self = shift;
    my $key = shift;
    my $value = shift;
    my $result;
    $self->get_value($key) && $self->get_value($key) eq $value and return $self;
    for my $child (@{$self->{children}}) {
         $result = $child->find_child($key, $value);
         $result and return $result;
    }
    return undef;
}

sub get_children {
    my $self = shift;
    return $self->{children};
}

sub add_child {
    my $self = shift;
    my $child = shift;
    $self->{children}->[scalar @{$self->{children}}] = $child;
    return $child;
}

return 1;
