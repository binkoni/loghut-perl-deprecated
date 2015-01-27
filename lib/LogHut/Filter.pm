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

package LogHut::Filter;

use feature ':all';
use FindBin;
use lib "$FindBin::Bin/../../";
use parent 'LogHut::Object';

sub new {
    my $class = shift;
    my %params = @_;
    my $self = $class->SUPER::new(%params);
    return $self;
}

sub test {
    my $self = shift;
}

return 1;
