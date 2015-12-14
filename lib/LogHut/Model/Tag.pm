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

package LogHut::Model::Tag;

use feature ':all';
use FindBin;
use lib "$FindBin::Bin/../../";
use parent 'LogHut::Model';
use LogHut::Global;
use LogHut::Debug;
use LogHut::Model::Post;
use LogHut::FileUtil;
use LogHut::Filter::AcceptPosts;

my $__file_util = LogHut::FileUtil->new(gzip_enabled => 1);

sub new {
    my $class = shift;
    my %params = @_; undef @_;
    my $self = $class->SUPER::new(%params);
    $self->{__name} = $params{name};
    defined $self->{__name} or confess 'No argument $params{name}';
    if(defined $params{post}) {
        $self->{__post} = $params{post};
    } elsif(defined $params{local_path}) {
        $self->{__post} = LogHut::Model::Post->new(local_path => $self->__get_post_local_path($params{local_path}));
    } else {
        confess 'Insufficient arguments';
    }

    return $self;
}

sub __get_post_local_path {
    my $self = shift;
    my $local_path = shift;
    $local_path =~ /(\d\d\d\d\/\d\d\/\d\d_\d+\.htmls?)$/;
    return "$LogHut::Global::settings->{posts_local_path}/$1";
}

sub get_name {
    my $self = shift;
    return $self->{__name};
}

sub get_local_path {
    my $self = shift;
    return $self->{__post}->get_tag_local_path($self->{__name});
}

sub get_post {
    my $self = shift;
    return $self->{__post};
}

#sub move {
#    my $self = shift;
#    my $local_path = shift;
#    defined $local_path or confess 'No argument $local_path';
#    $self->{__local_path} = $local_path;
#}

sub create {
    my $self = shift;
    my $tag_name = $self->get_name();
    my $year = $self->{__post}->get_year();
    my $month = $self->{__post}->get_month();
    $__file_util->mkdir("$LogHut::Global::settings->{tags_local_path}/$tag_name/$year/$month");
    open my $tag, '>', $self->get_local_path();
    $tag->close();
}

sub delete {
    my $self =  shift;
    my $tag_name = $self->{__name};
    my $year = $self->{__post}->get_year();
    my $month = $self->{__post}->get_month();
    $__file_util->unlink($self->get_local_path());
    $__file_util->rmdir("$LogHut::Global::settings->{tags_local_path}/$tag_name/$year/$month", LogHut::Filter::AcceptPosts->new());
    $__file_util->rmdir("$LogHut::Global::settings->{tags_local_path}/$tag_name/$year", LogHut::Filter::AcceptPosts->new());
    $__file_util->rmdir("$LogHut::Global::settings->{tags_local_path}/$tag_name", LogHut::Filter::AcceptPosts->new());
}

return 1;
