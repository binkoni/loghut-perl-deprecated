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

package LogHut::Debug;

use feature ':all';
use parent 'Exporter';
use Carp ();

BEGIN {
    *CORE::GLOBAL::die = \&LogHut::Debug::confess;
    *CORE::GLOBAL::warn = \&LogHut::Debug::carp;
    $SIG{__WARN__} = \&LogHut::Debug::carp;
    $SIG{__DIE__} = \&LogHut::Debug::confess;
}

our @EXPORT = ('confess', 'carp');
our $enabled = 1;

sub die {
    CORE::die(@_);
}

sub confess {
    if($enabled) {
        open my $debug, '>>', 'debug';
        $debug->print(Carp::longmess(@_));
        $debug->close();
    }
    LogHut::Debug::die();
}

sub carp {
    if($enabled) {
        open my $debug, '>>', 'debug';
        $debug->print(Carp::shortmess(@_));
        $debug->close();
    }
}

return 1;
