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

package LogHut::Model::Post;

use feature ':all';
use FindBin;
use lib "$FindBin::Bin/../../";
use parent 'LogHut::Model';
use LogHut::Global;
use LogHut::HTML::Parser;
use LogHut::Debug;
use LogHut::Model::Tags;
use LogHut::FileUtil;
use LogHut::Filter::AcceptPosts;
use LogHut::URLUtil;

my $file_util = LogHut::FileUtil->new(gzip_enabled => 1);

sub new {
    my $class = shift;
    my %params = @_; undef @_;
    my $self = $class->SUPER::new(%params);
    if(defined $params{local_path}) {
        $self->{local_path} = $params{local_path};
    } elsif(defined $params{year}) {
        $self->{local_path} = "$LogHut::Global::settings->{posts_local_path}/$params{year}/$params{month}/$params{day}\_$params{index}.html$params{secret}";
    } elsif(defined $params{url_path}) {
        if($params{url_path} =~ /^$LogHut::Global::settings->{posts_url_path}\/(\d\d\d\d)\/(\d\d)\/(\d\d)\_(\d+)\.html$/) {
            $self->{local_path} = "$LogHut::Global::settings->{posts_local_path}/$1/$2/$3\_$4.html";
        } elsif($params{url_path} =~ /$LogHut::Global::settings->{posts_url_path}\/(\d\d\d\d)\/(\d\d)\/(\d\d)\_(\d+)\.htmls$/) {
            $self->{local_path} = "$LogHut::Global::settings->{posts_local_path}/$1/$2/$3\_$4.htmls";
        } else {
            confess "Wrong argument \$params{url_path}($params{url_path})";
        }
    } else {
        confess "No proper arguments";
    }

    return $self;
}

sub get_local_path {
    my $self = shift;
    return $self->{local_path};
}

sub get_url_path {
    my $self = shift;
    my $year = $self->get_year();
    my $month = $self->get_month();
    my $day = $self->get_day();
    my $index = $self->get_index();
    if($self->get_secret()) {
        return "$LogHut::Global::settings->{admin_url_path}/index.pl?action=secret&url_path=" . LogHut::URLUtil::encode "$LogHut::Global::settings->{url_path}/posts/$year/$month/$day\_$index.htmls";
    } else {
        return "$LogHut::Global::settings->{posts_url_path}/$year/$month/$day\_$index.html";
    }
}

sub get_encoded_url_path {
    my $self = shift;
    return LogHut::URLUtil::encode $self->get_url_path();
}

sub get_tag_local_path {
    my $self = shift;
    my $tag_name = shift;
    defined $tag_name or confess 'No argument $tag_name';
    $self->{local_path} =~ /(\d\d\d\d\/\d\d\/\d\d_\d+\.htmls?)$/;
    return "$LogHut::Global::settings->{tags_local_path}/$tag_name/$1";
}

sub get_year {
    my $self = shift;
    $self->{local_path} =~ /(\d\d\d\d)\/\d\d\/\d\d_\d+\.htmls?$/;
    return $1;
}

sub get_month {
    my $self = shift;
    $self->{local_path} =~ /\d\d\d\d\/(\d\d)\/\d\d_\d+\.htmls?$/;
    return $1;
}

sub get_day {
    my $self = shift;
    $self->{local_path} =~ /\d\d\d\d\/\d\d\/(\d\d)_\d+\.htmls?$/;
    return $1;
}

sub get_index {
    my $self = shift;
    $self->{local_path} =~ /\d\d\d\d\/\d\d\/\d\d_(\d+)\.htmls?$/;
    return $1;
}

sub get_id {
    my $self = shift;
    return $self->get_year() . $self->get_month() . $self->get_day() . $self->get_index();
}

sub get_title {
    my $self = shift;
    $self->{html_tree} or $self->{html_tree} = LogHut::HTML::Parser->new()->parse_file($self->{local_path});
    return $self->{html_tree}->find_child('id', 'post_title')->get_value('contents');
}

sub get_text {
    my $self = shift;
    $self->{html_tree} or $self->{html_tree} = LogHut::HTML::Parser->new()->parse_file($self->{local_path});
    return $self->{html_tree}->find_child('id', 'post_text')->get_value('contents');
}

sub get_tags {
    my $self = shift;
    my @tags;
    $self->{html_tree} or $self->{html_tree} = LogHut::HTML::Parser->new()->parse_file($self->{local_path});
    for my $tag_name (@{$self->{html_tree}->find_child('id', 'post_tags')->get_children()}) {
        push @tags, LogHut::Model::Tag->new(name => $tag_name->get_value('contents'), post => $self);
    }
    return @tags;
}

sub get_tag_names {
    my $self = shift;
    my @tag_names;
    $self->{html_tree} or $self->{html_tree} = LogHut::HTML::Parser->new()->parse_file($self->{local_path});
    for my $tag_name (@{$self->{html_tree}->find_child('id', 'post_tags')->get_children()}) {
        push @tag_names, $tag_name->get_value('contents');
    }
    return @tag_names;
}

sub get_contents {
    my $self = shift;
    $self->{html_tree} or $self->{html_tree} = LogHut::HTML::Parser->new()->parse_file($self->{local_path});
    return $self->{html_tree}->get_value('contents');
}

sub get_secret {
    my $self = shift;
    $self->{local_path} =~ /^$LogHut::Global::settings->{posts_local_path}\/\d\d\d\d\/\d\d\/\d\d_\d+\.html(s?)$/;
    $1 and return 'checked';
    return undef;
}

sub set_secret {
    my $self = shift;
    my $secret = shift;
    $secret eq 'on' || $secret eq 'checked' and return $self->{local_path} =~ s/^($LogHut::Global::settings->{posts_local_path}\/\d\d\d\d\/\d\d\/\d\d_\d+)\.htmls?$/$1\.htmls/;
    return $self->{local_path} =~ s/^($LogHut::Global::settings->{posts_local_path}\/\d\d\d\d\/\d\d\/\d\d_\d+)\.htmls?$/$1\.html/;
}


sub exists {
    my $self = shift;
    my $year = $self->get_year();
    my $month = $self->get_month();
    my $day = $self->get_day();
    my $index = $self->get_index();
    return -e "$LogHut::Global::settings->{posts_local_path}/$year/$month/$day\_$index.html" || -e "$LogHut::Global::settings->{posts_local_path}/$year/$month/$day\_$index.htmls";
}

sub move {
    my $self = shift;
    my $local_path = shift;
    defined $local_path or confess 'No argument $local_path';
    $self->{local_path} = $local_path;
}

sub create {
    my $self = shift;
    my %params = @_; undef @_;
    my $tags = LogHut::Model::Tags->new();
    my $year = $self->get_year();
    my $month = $self->get_month();
    my $day = $self->get_day();
    $self->set_secret($params{secret});
    $file_util->mkdir("$LogHut::Global::settings->{posts_local_path}/$year/$month");
    $file_util->process_template("$LogHut::Global::settings->{admin_local_path}/res/post.tmpl",
        { url_path => $LogHut::Global::settings->{url_path}, post => { url_path => $self->get_url_path(), title => $params{title}, text => $params{text}, tag_names => $params{tags}, year => $year, month => $month, day => $day } }, $self->{local_path});
    $tags->create($self, $params{tags});
}

sub delete {
    my $self = shift;
    my $month = $self->get_month();
    my $year = $self->get_year();
    my $tags = LogHut::Model::Tags->new();
    $tags->delete($self);
    $file_util->unlink($self->{local_path});
    $file_util->rmdir("$LogHut::Global::settings->{posts_local_path}/$year/$month", LogHut::Filter::AcceptPosts->new());
    $file_util->rmdir("$LogHut::Global::settings->{posts_local_path}/$year", LogHut::Filter::AcceptPosts->new());
    $self->free();
}

sub free {
    my $self = shift;
    undef $self->{html_tree};
}

return 1;
