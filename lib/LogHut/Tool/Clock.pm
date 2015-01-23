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

package LogHut::Tool::Clock;

use feature ':all';
use FindBin;
use lib "$FindBin::Bin/../../";
use parent 'LogHut::Object';
use LogHut::Log;
use Time::Piece;

sub new {
    my $class = shift;
    my %params = @_; undef @_;
    my $self = $class->SUPER::new(%params);
    
    return $self;
}

sub get_time {
    my $self = shift;
    my $time = localtime();
    return (sprintf('%04d', $time->year), sprintf('%02d', $time->mon), sprintf('%02d', $time->mday));
}

return 1;
