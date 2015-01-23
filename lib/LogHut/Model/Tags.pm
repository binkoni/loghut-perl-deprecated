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

package LogHut::Model::Tags;

use feature ':all';
use FindBin;
use lib "$FindBin::Bin/../../";
use parent 'LogHut::Model';
use LogHut::Config;
use LogHut::Log;
use LogHut::Model::Tag;

sub new {
    my $class = shift;
    my %params = @_; undef @_;
    my $self = $class->SUPER::new(%params);
    return $self;
}

sub create {
    my $self = shift;
    my $post = shift;
    defined $post or confess 'No argument $post';
    my $tag_names = shift;
    defined $tag_names or confess 'No argument $tag_names';
    my $tag;
    for my $tag_name (@{$tag_names}) {
       $tag = LogHut::Model::Tag->new(name => $tag_name, post => $post);
       $tag->create();
    }
}

sub delete {
    my $self = shift;
    my $post = shift;
    defined $post or confess 'No argument $post';
    for my $tag ($post->get_tags()) {
       $tag->delete();
    }
}


sub get_tag_names {
    my $self = shift;
    return $f->get_directories(local_path => "$LOCAL_PATH/tags");
}

sub get_years {
    my $self = shift;
    my $tag_name = shift;
    defined $tag_name or confess 'No argument $tag_name';
    return $f->get_directories(local_path => "$LOCAL_PATH/tags/$tag_name");
}

sub get_months {
    my $self = shift;
    my $tag_name = shift;
    defined $tag_name or confess 'No argument $tag_name';
    my $year = shift;
    defined $year or confess 'No argument $year';
    return $f->get_directories(local_path => "$LOCAL_PATH/tags/$tag_name/$year");
}

sub get_tags {
    my $self = shift;
    my $tag_name = shift;
    defined $tag_name or confess 'No argument $tag_name';
    my $year = shift;
    defined $year or confess 'No argument $year';
    my $month = shift;
    defined $month or confess 'No aegument $month';
    my @tags;
    for my $tag_path ($f->get_files(local_path => "$LOCAL_PATH/tags/$tag_name/$year/$month", filter => LogHut::Tool::Filter::AcceptPosts->new(), join_enabled => 1)) {
        push @tags, LogHut::Model::Tag->new(name => tag_name, local_path => $tag_path);
    }
    return @tags;
}

sub update_lists {
    my $self = shift;
    my $year = shift;
    defined $year or confess 'No argument $year';
    my $month = shift;
    defined $month or confess 'No argument $month';
    my @tag_names = @_; undef @_;
    $f->process_template("$LOCAL_PATH/admin/res/tag_name_index.tmpl", { tag_names => [$self->get_tag_names()] }, "$LOCAL_PATH/tags/index.html");
    my @years;
    my @months;
    my @tags;
    for my $tag_name (@tag_names) {
        if(@years = $self->get_years($tag_name)) {
            $f->process_template("$LOCAL_PATH/admin/res/year_index.tmpl", { years => [@years] }, "$LOCAL_PATH/tags/$tag_name/index.html");
        }
        if(@months = $self->get_months($tag_name, $year)) {
            $f->process_template("$LOCAL_PATH/admin/res/month_index.tmpl", { months => [@months] }, "$LOCAL_PATH/tags/$tag_name/$year/index.html");
        }
        if(@tags = $self->get_tags($tag_name, $year, $month)) {
            $f->process_template("$LOCAL_PATH/admin/res/tag_index.tmpl", { tags => [@tags] }, "$LOCAL_PATH/tags/$tag_name/$year/$month/index.html");
        }
    }
}

return 1;
