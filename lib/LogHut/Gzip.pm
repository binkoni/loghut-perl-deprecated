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

package LogHut::Gzip;

use feature ':all';
use FindBin;
use lib "$FindBin::Bin/../../';
use parent 'LogHut::Object';
use LogHut::Debug;
use LogHut::FileUtil;

sub new {
    my $class = shift;
    my %params = @_; undef @_;
    my $self = $class->SUPER::new(%params);
    $self->{file_util} = LogHut::FileUtil->new(enable_gzip => 1,filters => $params{filters});
    return $self;
}

sub compress {
    my $self = shift;
    my $current_path = shift;
    defined $current_path or confess 'No argument $current_path';
    my $filter = shift;
    my @queue;
    push @queue, $current_path;
    while(@queue){
        $current_path = shift @queue;
        if(-d $current_path){
            push @queue,
            map{$self->{file_util}->join_paths($current_path, $_)} self->{file_util}->get_files($current_path, $filter);
        }
        elsif(-f $current_path){
            $current_path =~ s/ /\\ /g;
            open my $compressed_file, '>', "$current_path.gz" or confess $!;
            $compressed_file->print(`gzip -c9 $current_path`);
        }
    }
}
return 1;
