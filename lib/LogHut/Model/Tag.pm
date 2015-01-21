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
    $self->{name} = $params{name} or confess 'No argument $self->{name}';
    if($params{post}) {
        $self->{post} = $params{post};
        $self->{local_path} = $self->{post}->get_tag_local_path($self->{name});
    } elsif($params{local_path}) {
        $self->{local_path} = $params{local_path};
        $self->{post} = LogHut::Model::Post->new(local_path => $self->__get_post_local_path());
    }
    return $self;
}

sub __get_post_local_path {
    my $self = shift;
    $self->{local_path} =~ /(\d\d\d\d\/\d\d\/\d\d_\d+\.htmls?)$/;
    return "$LOCAL_PATH/posts/$1";
}

sub get_name {
    my $self = shift;
    return $self->{name};
}

sub get_local_path {
    my $self = shift;
    return $self->{local_path};
}

sub get_post {
    my $self = shift;
    return $self->{post};
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
    open my $tag, '>', $self->{local_path};
    $tag->print('');
    $tag->close();
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

return 1;
