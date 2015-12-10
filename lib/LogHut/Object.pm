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

package LogHut::Object;

use feature ':all';
use LogHut::ReferenceUtil;

sub new {
    my $class = shift;
    return bless {}, $class;
}

sub shallow_copy {
    my $self = shift;
    my $new_object = bless {}, ref($self);
    for my $key (keys %{$self}) {
        $new_object->{$key} = $self->{$key};
    }
    return $new_object;
}


sub deep_copy {
    my $self = shift;
    return LogHut::ReferenceUtil::deep_copy($self);
}

return 1;
