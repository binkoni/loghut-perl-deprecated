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

package LogHut::Stores;

use feature ':all';
use FindBin;
use lib "$FindBin::Bin";
use parent 'LogHut::Object';
use LogHut::Debug;
use LogHut::FileUtil;
use LogHut::Store;

my $__file_util = LogHut::FileUtil->new();

sub new {
    my $class = shift;
    my %params = @_; undef @_;
    my $self = $class->SUPER::new(%params);
    $self->{_file_util} = $__file_util;
    $self->{_directory_path} = $params{directory_path};
    defined $self->{_directory_path} or confess 'No argument $directory_path';
    return $self;
}

sub read_all {
    my $self = shift;
    return map { LogHut::Session->new(directory_path => $self->{_directory_path})->read($_) } $self->{_file_util}->get_files(local_path => $self->{_directory_path});
}

sub delete_all {
    my $self = shift;
    for my $session ($self->read_all()) {
        $session->delete();
    }
}

