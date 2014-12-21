package LogHut::Model::Tag;

use feature ':all';
use FindBin;
use lib "$FindBin::Bin/../../";
use parent 'LogHut::Model';
use LogHut::Config;
use LogHut::Log;
use LogHut::Model::Post;
use LogHut::Tool::Filter::AcceptPosts;

sub new {
    my $class = shift;
    my %params = @_; undef @_;
    my $self = $class->SUPER::new(%params);
    $self->{name} = $params{name};
    if($params{post}) {
        $self->{post} = $params{post};
        $self->{local_path} = $self->{post}->get_tag_local_path($self->{name});
    } elsif($params{local_path}) {
        $self->{local_path} = $params{local_path};
        $self->{post} = LogHut::Model::Post->new(local_path => $self->get_post_local_path());
    }
    return $self;
}

sub get_name {
    my $self = shift;
    return $self->{name};
}

sub get_local_path {
    my $self = shift;
    return $self->{local_path};
}

sub get_url_path {
    my $self = shift;
    return $self->{post}->get_url_path();
}

sub get_post_local_path {
    my $self = shift;
    $self->{local_path} =~ /(\d\d\d\d\/\d\d\/\d\d_\d+\.htmls?)$/;
    return "$LOCAL_PATH/posts/$1";
}

sub move {
    my $self = shift;
    my $local_path = shift;

    $self->{local_path} = $local_path;
}

sub create {
    my $self = shift;
    my $tag_name = $self->get_name();
    my $year = $self->{post}->get_year() or confess 'No argument $year';
    my $month = $self->{post}->get_month() or confess 'No argument $month';
    $f->mkdir("$LOCAL_PATH/tags/$tag_name/$year/$month");
    $f->copy($self->{post}->get_local_path(), $self->{local_path});
}

sub delete {
    my $self =  shift;
    my $tag_name = $self->{name} or confess 'No argument $tag_name';
    my $year = $self->{post}->get_year() or confess 'No argument $year';
    my $month = $self->{post}->get_month() or confess 'No argument $month';
    $f->unlink($self->{local_path});
    $f->rmdir("$LOCAL_PATH/tags/$tag_name/$year/$month", LogHut::Tool::Filter::AcceptPosts->new());
    $f->rmdir("$LOCAL_PATH/tags/$tag_name/$year", LogHut::Tool::Filter::AcceptPosts->new());
    $f->rmdir("$LOCAL_PATH/tags/$tag_name", LogHut::Tool::Filter::AcceptPosts->new());
}

sub solid {
    my $self = shift;
    $self->{url_path} = $self->get_url_path();
    $self->{year} = $self->{post}->get_year();
    $self->{month} = $self->{post}->get_month();
    $self->{day} = $self->{post}->get_day();
    $self->{index} = $self->{post}->get_index();
    $self->{secret} = $self->{post}->get_secret();
    $self->{title} = $self->{post}->get_title();
    $self->{text} = $self->{post}->get_text();
    $self->{tags} = [$self->{post}->get_tags()];
}

return 1;
