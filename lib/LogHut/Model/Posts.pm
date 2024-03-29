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

package LogHut::Model::Posts;

use feature ':all';
use FindBin;
use lib "$FindBin::Bin/../../";
use parent 'LogHut::Model';
use LogHut::Global;
use POSIX;
use LogHut::Debug;
use LogHut::Model::Post;
use LogHut::Model::Tags;
use LogHut::Clock;
use LogHut::FileUtil;
use LogHut::Filter::AcceptPosts;
use LogHut::Filter::Filters;
use LogHut::URLUtil;
no warnings;

my $__file_util = LogHut::FileUtil->new(gzip_enabled => 1);

sub new {
    my $class = shift;
    my %params = @_; undef @_;
    my $self = $class->SUPER::new(%params);

    return $self;
}

sub search {
    my $self = shift;
    my %params = @_; undef @_;
    my $filters = LogHut::Filter::Filters->new(filters => [LogHut::Filter::AcceptPosts->new(), eval { return @{$params{filters}} }]);
    my @posts;
    for my $post_local_path ($__file_util->bfs($LogHut::Global::settings->{posts_local_path}, $filters)) {
        push @posts, LogHut::Model::Post->new(local_path => $post_local_path);
    }
    @posts = $self->__sort_posts(posts => \@posts);
    $self->{__posts} = \@posts;
    if($params{page} >= 1) {
        my $start_index = ($params{page} - 1) * $LogHut::Global::settings->{posts_per_page};
        my $end_index = $start_index + $LogHut::Global::settings->{posts_per_page} - 1;
        $end_index > $#posts and $end_index = $#posts;
        return @posts[$start_index .. $end_index];
    }
    return @posts;
}

sub secret {
    my $self = shift;
    my $url_path = shift;
    defined $url_path or confess 'No argument $url_path';
    return LogHut::Model::Post->new(url_path => $url_path)->get_contents();
}

sub create {
    my $self = shift;
    my %params = @_; undef @_;
    my($year, $month, $day) = LogHut::Clock::get_time();
    my $post = $self->__get_available_post($year, $month, $day);
    $post->create(%params);
    $self->update_lists($year, $month);
    defined $self->{__tags} or $self->{__tags} = LogHut::Model::Tags->new();
    $self->{__tags}->update_lists($year, $month, @{$params{tags}});
    $post->get_secret() or $self->__set_main_post($post);
    return $post;
}

sub modify {
    my $self = shift;
    my %params = @_; undef @_;
    defined $params{url_path} or confess 'No argument $url_path';
    my $post = LogHut::Model::Post->new(url_path => $params{url_path});
    $post->delete();
    $post->create(%params);
    my $year = $post->get_year();
    my $month = $post->get_month();
    $self->update_lists($year, $month);
    defined $self->{__tags} or $self->{__tags} = LogHut::Model::Tags->new();
    $self->{__tags}->update_lists($year, $month, @{$params{tags}});
    $self->__set_main_post();
    return $post;
}

sub delete {
    my $self = shift;
    my %params = @_; undef @_;
    defined $params{url_path} or confess 'No argument $url_path';
    my $post = LogHut::Model::Post->new(url_path => $params{url_path});
    my $year = $post->get_year();
    my $month = $post->get_month();
    my @tag_names = $post->get_tag_names();
    $post->delete();
    $self->update_lists($year, $month);
    defined $self->{__tags} or $self->{__tags} = LogHut::Model::Tags->new();
    $self->{__tags}->update_lists($year, $month, @tag_names);
    $self->__set_main_post();
}

sub backup {
    my $self = shift;
    return `tar -cf - $LogHut::Global::settings->{local_path}/index.html $LogHut::Global::settings->{local_path}/index.html.gz $LogHut::Global::settings->{posts_local_path} $LogHut::Global::settings->{tags_local_path} 2>/dev/null | gzip -cf9`;
}

sub refresh {
    my $self = shift;
    my %params;
    my %list_check;
    my $post_year;
    my $post_month;
    for my $post ($self->search()) {
        $params{url_path} = LogHut::URLUtil::decode $post->get_url_path();
        $params{title} = $post->get_title();
        $params{text} = $post->get_text();
        $params{tags} = [$post->get_tag_names()];
        $params{secret} = $post->get_secret();
        $post_year = $post->get_year();
        $post_month = $post->get_month();
        defined $list_check{$post_year} or $list_check{$post_year} = {};
        defined $list_check{$post_year}->{$post_month} or $list_check{$post_year}->{$post_month} = {};
        for my $tag_name ($post->get_tag_names()) {
            $list_check{$post_year}->{$post_month}->{$tag_name} = 1;
        }
        $post->delete();
        $post->create(%params);
    }
    defined $self->{__tags} or $self->{__tags} = LogHut::Model::Tags->new();
    for my $year (keys %list_check) {
        for my $month (keys %{$list_check{$year}}) {
            $self->update_lists($year, $month);
            $self->{__tags}->update_lists($year, $month, keys %{$list_check{$year}->{$month}});
        }
    }
    $self->__set_main_post();
}

sub get_years {
    my $self = shift;
    my $sorting_enabled = shift;
    my @years = $__file_util->get_directories(local_path => $LogHut::Global::settings->{posts_local_path});
    $sorting_enabled and return sort { $b <=> $a } @years;
    return @years;
}

sub get_months {
    my $self = shift;
    my $year = shift;
    defined $year or confess 'No argument $year';
    my $sorting_enabled = shift;
    my @months = $__file_util->get_directories(local_path => "$LogHut::Global::settings->{posts_local_path}/$year");
    $sorting_enabled and return sort { $b <=> $a } @months;
    return @months;
}

sub get_posts {
    my $self = shift;
    my $year = shift;
    defined $year or confess 'No argument $year';
    my $month = shift;
    defined $month or confess 'No argument $month';
    my @posts;
    my $post;
    for my $post_path ($__file_util->get_files(local_path => "$LogHut::Global::settings->{posts_local_path}/$year/$month", filter => LogHut::Filter::AcceptPosts->new(), join_enabled => 1)) {
        $post = LogHut::Model::Post->new(local_path => $post_path);
        push @posts, $post;
    }
    return $self->__sort_posts(posts => [@posts]);
}

sub get_previous_page {
    my $self = shift;
    my $current_page = shift;
    defined $current_page or return undef;
    $current_page > 1 && $current_page - 1 < $self->get_last_page() and return $current_page - 1;
    return undef;
}

sub get_next_page {
    my $self = shift;
    my $current_page = shift;
    defined $current_page or return undef;
    defined $self->{__posts} or $self->search();
    $current_page + 1 <= $self->get_last_page() and return $current_page + 1;
    return undef;
}

sub get_last_page {
    my $self = shift;
    defined $self->{__posts} or $self->search();
    return ceil((scalar @{$self->{__posts}} - 1) / $LogHut::Global::settings->{posts_per_page});
}

sub __set_main_post {
    my $self = shift;
    my $post = shift;
    if(defined $post) {
        $__file_util->process_template("$LogHut::Global::settings->{admin_local_path}/res/main_index.tmpl", {
            url_path => $LogHut::Global::settings->{url_path},
            post => $post
        }, "$LogHut::Global::settings->{local_path}/index.html");
    } else {
        loops:
        for my $year ($self->get_years(1)) {
            for my $month ($self->get_months($year, 1)) {
                for my $latest_post ($self->get_posts($year, $month)) { #만약 첫번째 포스트를 삭제할 경우에는 어떻게 해야할지 생각해야한다
                    if(! $latest_post->get_secret()) {
                        $self->__set_main_post($latest_post);
                        last loops;
                    }
                }
            }
        }
    }
}

sub update_lists {
    my $self = shift;
    my $year = shift;
    defined $year or confess 'No argument $year';
    my $month = shift;
    defined $month or confess 'No argument $month';
    if(my @years = $self->get_years(1)) { $__file_util->process_template("$LogHut::Global::settings->{admin_local_path}/res/year_index.tmpl", { years => [@years] }, "$LogHut::Global::settings->{posts_local_path}/index.html");}
    if(my @months = $self->get_months($year, 1)) { $__file_util->process_template("$LogHut::Global::settings->{admin_local_path}/res/month_index.tmpl", { months => [@months] }, "$LogHut::Global::settings->{posts_local_path}/$year/index.html");}
    if(my @posts = $self->get_posts($year, $month)) { $__file_util->process_template("$LogHut::Global::settings->{admin_local_path}/res/post_index.tmpl", { posts => [@posts] }, "$LogHut::Global::settings->{posts_local_path}/$year/$month/index.html");}
}

sub __get_available_post {
    my $self = shift;
    my $year = shift;
    defined $year or confess 'No argument $year';
    my $month = shift;
    defined $month or confess 'No argument $month';
    my $day = shift;
    defined $day or confess 'No argument $day';
    my($latest_post) = $self->get_posts($year, $month);
    my $index = sprintf '%02d', ((eval {$latest_post->get_day() eq $day && $latest_post->get_index()}) + 1);
    return LogHut::Model::Post->new(year => $year, month => $month, day => $day, index => $index);
}

sub __sort_posts {
    my $self = shift;
    my %params = @_; undef @_;
    defined $params{posts} or confess 'No argument $posts';
    if($params{inversed}) {
        return sort {$a->get_id() <=> $b->get_id()} @{$params{posts}};
    } else {
        return sort {$b->get_id() <=> $a->get_id()} @{$params{posts}};
    }
}

return 1;
