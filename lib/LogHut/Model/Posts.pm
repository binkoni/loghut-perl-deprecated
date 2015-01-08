package LogHut::Model::Posts;

use feature ':all';
use FindBin;
use lib "$FindBin::Bin/../../";
use parent 'LogHut::Model';
use URI::Escape;
use LogHut::Config;
use LogHut::Log;
use LogHut::Model::Post;
use LogHut::Tool::Clock;
use LogHut::Tool::Filter::AcceptPosts;
use LogHut::Tool::Filter::Filters;
no warnings;

sub new {
    my $class = shift;
    my %params = @_; undef @_;
    my $self = $class->SUPER::new(%params);
    return $self;
}

sub search {
    my $self = shift;
    my $filters = LogHut::Tool::Filter::Filters->new(filters => [LogHut::Tool::Filter::AcceptPosts->new(), @_]); undef @_;
    my @posts;
    for my $post_local_path ($f->bfs("$LOCAL_PATH/posts", $filters)) {
        push @posts, LogHut::Model::Post->new(local_path => $post_local_path);
    }
    return $self->__sort_posts(posts => [@posts]);
}

sub secret {
    my $self = shift;
    my $url_path = shift;
    my $post =  LogHut::Model::Post->new(url_path => $url_path);
    return $post->get_content();
}

sub create {
    my $self = shift;
    my %params = @_; undef @_;
    my($year, $month, $day) = LogHut::Tool::Clock->new()->get_time();
    my $post = $self->__get_available_post($year, $month, $day);
    $post->create(%params);
    $self->update_lists($year, $month);
    LogHut::Model::Tags->new()->update_lists($year, $month, @{$params{tags}});
    $self->__set_main_post($post);
    return $post;
}

sub modify {
    my $self = shift;
    my %params = @_; undef @_;
    my $post = LogHut::Model::Post->new(url_path => $params{url_path});
    $post->delete();
    $post->create(%params);
    my $year = $post->get_year();
    my $month = $post->get_month();
    $self->update_lists($year, $month);
    LogHut::Model::Tags->new()->update_lists($year, $month, @{$params{tags}});
    $self->__set_main_post();
    return $post;
}

sub delete {
    my $self = shift;
    my %params = @_; undef @_;
    my $post = LogHut::Model::Post->new(url_path => $params{url_path});
    my $year = $post->get_year();
    my $month = $post->get_month();
    my @tags = $post->get_tags();
    $post->delete();
    $self->update_lists($year, $month, @tags);
    $self->__set_main_post();
}

sub backup {
    my $self = shift;
    return `tar -cf - $LOCAL_PATH/index.html $LOCAL_PATH/index.html.gz $LOCAL_PATH/posts $LOCAL_PATH/tags 2>/dev/null | gzip -cf9`;
}

sub refresh {
    my $self = shift;
    my %params;
    for my $post ($self->search()) {
        $params{url_path} = uri_unescape $post->get_url_path();
        $params{title} = $post->get_title();
        $params{text} = $post->get_text();
        $params{tags} = [$post->get_tags()];
        $params{secret} = $post->get_secret();
        $self->modify(%params);
    }
}

sub get_years {
    my $self = shift;
    my $sorting_enabled = shift;
    my @years = $f->get_directories(local_path => "$LOCAL_PATH/posts");
    $sorting_enabled and return sort { $b <=> $a } @years;
    return @years;
}

sub get_months {
    my $self = shift;
    my $y = shift;
    my $sorting_enabled = shift;
    my @months = $f->get_directories(local_path => "$LOCAL_PATH/posts/$y");
    $sorting_enabled and return sort { $b <=> $a } @months;
    return @months;
}

sub get_posts {
    my $self = shift;
    my $year = shift;
    my $month = shift;
    my $solid_enabled = shift;
    my @posts;
    my $post;
    for my $post_path ($f->get_files(local_path => "$LOCAL_PATH/posts/$year/$month", filter => LogHut::Tool::Filter::AcceptPosts->new(), join_enabled => 1)) {
        $post = LogHut::Model::Post->new(local_path => $post_path);
        $solid_enabled and $post->solid();
        push @posts, $post;
    }
    return $self->__sort_posts(posts => [@posts]);
}

sub __set_main_post {
    my $self = shift;
    my $post = shift;
    if(eval {!$post->get_secret()}){
        $f->copy($post->get_local_path(), "$LOCAL_PATH/index.html");
    } else {
        my($year) = $self->get_years(1);
        my($month) = $self->get_months($year, 1);
        for my $latest_post ($self->get_posts($year, $month)) { #만약 첫번째 포스트를 삭제할 경우에는 어떻게 해야할지 생각해야한다
            if(!$latest_post->get_secret()) {
                $self->__set_main_post($latest_post);
                last;
            }
        }
    }
}

sub update_lists {
    my $self = shift;
    my $year = shift or confess 'No argument $year';
    my $month = shift or confess 'No argument $month';
    my @tags = @_; undef @_;
    $f->process_template("$LOCAL_PATH/admin/res/index.tmpl", { list => [$self->get_years()] }, "$LOCAL_PATH/posts/index.html");
    if(my @months = sort { $b <=> $a } $self->get_months($year)) {
        $f->process_template("$LOCAL_PATH/admin/res/index.tmpl", { list => [@months] }, "$LOCAL_PATH/posts/$year/index.html");
    }
    if(my @posts = $self->get_posts($year, $month, 1)) {
        $f->process_template("$LOCAL_PATH/admin/res/index2.tmpl", { posts => [@posts] }, "$LOCAL_PATH/posts/$year/$month/index.html");
    }
}

sub __get_available_post {
    my $self = shift;
    my $year = shift or confess 'No argument $year';
    my $month = shift or confess 'No argument $month';
    my $day = shift or confess 'No argument $day';
    my($latest_post) = $self->get_posts($year, $month);
    my $index = sprintf "%02d", ((eval {$latest_post->get_day() eq $day && $latest_post->get_index()}) + 1);
    return LogHut::Model::Post->new(year => $year, month => $month, day => $day, index => $index);
}

sub __sort_posts {
    my $self = shift;
    my %params = @_; undef @_;
    
    if($params{inversed}) {
        return sort {$a->get_id() <=> $b->get_id()} @{$params{posts}};
    } else {
        return sort {$b->get_id() <=> $a->get_id()} @{$params{posts}};
    }
}

return 1;
