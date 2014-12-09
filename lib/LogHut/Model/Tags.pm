package LogHut::Model::Tags;

use latest;
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
    my $tags = shift;
    my $tag;
    for my $tag_name (@{$tags}) {
       $tag = LogHut::Model::Tag->new(name => $tag_name, post => $post);
       $tag->create();
    }
}

sub delete {
    my $self = shift;
    my $post = shift;
    my $tag;
    for my $tag_name ($post->get_tags()) {
       $tag = LogHut::Model::Tag->new(name => $tag_name, post => $post);
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
    return $f->get_directories(local_path => "$LOCAL_PATH/tags/$tag_name");
}

sub get_months {
    my $self = shift;
    my $tag_name = shift;
    my $y = shift;
    return $f->get_directories(local_path => "$LOCAL_PATH/tags/$tag_name/$y");
}

sub get_tags {
    my $self = shift;
    my $tag_name = shift;
    my $y = shift;
    my $m = shift;
    my $solid_enabled = shift;
    my @tags;
    my $tag;
    for my $tag_path ($f->get_files(local_path => "$LOCAL_PATH/tags/$tag_name/$y/$m", filter => LogHut::Tool::Filter::AcceptPosts->new(), join_enabled => 1)) {
        $tag = LogHut::Model::Tag->new(local_path => $tag_path);
        $solid_enabled and $tag->solid();
        push @tags, $tag;
    }
    return @tags;
}

sub update_lists {
    my $self = shift;
    my $year = shift or confess 'No argument $year';
    my $month = shift or confess 'No argument $month';
    my @tag_names = @_; undef @_;
    $f->process_template("$LOCAL_PATH/admin/res/index.tmpl", { list => [$self->get_tag_names()] }, "$LOCAL_PATH/tags/index.html");
    my @years;
    my @months;
    my @tags;
    for my $tag_name (@tag_names) {
        if(@years = $self->get_years($tag_name)) {
            $f->process_template("$LOCAL_PATH/admin/res/index.tmpl", { list => [@years] }, "$LOCAL_PATH/tags/$tag_name/index.html");
        }
        if(@months = $self->get_months($tag_name, $year)) {
            $f->process_template("$LOCAL_PATH/admin/res/index.tmpl", { list => [@months] }, "$LOCAL_PATH/tags/$tag_name/$year/index.html");
        }
        if(@tags = $self->get_tags($tag_name, $year, $month, 1)) {
            $f->process_template("$LOCAL_PATH/admin/res/index2.tmpl", { posts => [@tags] }, "$LOCAL_PATH/tags/$tag_name/$year/$month/index.html");
        }
    }
}

return 1;
