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

package LogHut::Log;

use feature ':all';
use parent 'Exporter';
use Carp ();

BEGIN {
    *CORE::GLOBAL::die = \&LogHut::Log::confess;
    *CORE::GLOBAL::warn = \&LogHut::Log::carp;
    $SIG{__WARN__} = \&LogHut::Log::carp;
    $SIG{__DIE__} = \&LogHut::Log::confess;
}

our @EXPORT = ('confess', 'carp');
our $enabled = 1;

sub die {
    CORE::die(@_);
}

sub confess {
    if($enabled) {
        open my $log, '>>', 'log';
        $log->print(Carp::longmess(@_));
        $log->close();
        LogHut::Log::die();
    }
}

sub carp {
    if($enabled) {
        open my $log, '>>', 'log';
        $log->print(Carp::shortmess(@_));
        $log->close();
    }
}

return 1;
