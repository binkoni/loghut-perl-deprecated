package LogHut::Model::Post;

use feature ':all';
use FindBin;
use lib "$FindBin::Bin/../../";
use parent 'LogHut::Model';
use URI::Escape;
use LogHut::Config;
use LogHut::HTML::Parser;
use LogHut::Log;
use LogHut::Model::Tags;
use LogHut::Tool::Filter::AcceptPosts;

sub new {
    my $class = shift;
    my %params = @_; undef @_;
    my $self = $class->SUPER::new(%params);
    if($params{local_path}) {
        $self->{local_path} = $params{local_path};
    } elsif($params{year}) {
        $self->{local_path} = "$LOCAL_PATH/posts/$params{year}/$params{month}/$params{day}\_$params{index}.html$params{secret}";
    } elsif($params{url_path}) {
        if($params{url_path} =~ /^$URL_PATH\/posts\/(\d\d\d\d)\/(\d\d)\/(\d\d)\_(\d+)\.html$/) {
            $self->{local_path} = "$LOCAL_PATH/posts/$1/$2/$3\_$4.html";
        } elsif($params{url_path} =~ /$URL_PATH\/posts\/(\d\d\d\d)\/(\d\d)\/(\d\d)\_(\d+)\.htmls$/) {
            $self->{local_path} = "$LOCAL_PATH/posts/$1/$2/$3\_$4.htmls";
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
    my $year = $self->get_year() or confess 'No argument $year';
    my $month = $self->get_month() or confess 'No argument $month';
    my $day = $self->get_day() or confess 'No argument $day';
    my $index = $self->get_index() or confess 'No argument $index';
    if($self->get_secret()) {
        return "$URL_PATH/admin/index.pl?action=secret&url_path=" . uri_escape "$URL_PATH/posts/$year/$month/$day\_$index.htmls";
    } else {
        return "$URL_PATH/posts/$year/$month/$day\_$index.html";
    }
}

sub get_encoded_url_path {
    my $self = shift;
    return uri_escape $self->get_url_path();
}

sub get_tag_local_path {
    my $self = shift;
    my $tag_name = shift or confess 'No argument $tag_name';
    $self->{local_path} =~ /(\d\d\d\d\/\d\d\/\d\d_\d+\.htmls?)$/;
    return "$LOCAL_PATH/tags/$tag_name/$1";
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
    $self->{local_path} =~ /^$LOCAL_PATH\/posts\/\d\d\d\d\/\d\d\/\d\d_\d+\.html(s?)$/;
    $1 and return 'checked';
    return undef;
}

sub set_secret {
    my $self = shift;
    my $secret = shift;
    $secret eq 'on' || $secret eq 'checked' and return $self->{local_path} =~ s/^($LOCAL_PATH\/posts\/\d\d\d\d\/\d\d\/\d\d_\d+)\.htmls?$/$1\.htmls/;
    return $self->{local_path} =~ s/^($LOCAL_PATH\/posts\/\d\d\d\d\/\d\d\/\d\d_\d+)\.htmls?$/$1\.html/;
}


sub exists {
    my $self = shift;
    my $year = $self->get_year() or confess 'No argument $year';
    my $month = $self->get_month() or confess 'No argument $month';
    my $day = $self->get_day() or confess 'No argument $day';
    my $index = $self->get_index() or confess 'No argument $index';
    return -e "$LOCAL_PATH/posts/$year/$month/$day\_$index.html" || -e "$LOCAL_PATH/posts/$year/$month/$day\_$index.htmls";
}

sub move {
    my $self = shift;
    my $local_path = shift;
    $self->{local_path} = $local_path;
}

sub create {
    my $self = shift;
    my %params = @_; undef @_;
    my $tags = LogHut::Model::Tags->new();
    my $year = $self->get_year() or confess 'No argument $year';
    my $month = $self->get_month() or confess 'No argument $month';
    my $day = $self->get_day() or confess 'No argument $day';
    $self->set_secret($params{secret});
    $f->mkdir("$LOCAL_PATH/posts/$year/$month");
    $f->process_template("$LOCAL_PATH/admin/res/post.tmpl", { url_path => $URL_PATH, post => { url_path => $self->get_url_path(), title => $params{title}, text => $params{text}, tag_names => $params{tags}, year => $year, month => $month, day => $day } }, $self->{local_path});
    $tags->create($self, $params{tags});
}

sub delete {
    my $self = shift;
    my $month = $self->get_month() or confess 'No argument $month';
    my $year = $self->get_year() or confess 'No argument $year';
    my $tags = LogHut::Model::Tags->new();
    $tags->delete($self);
    $f->unlink($self->{local_path});
    $f->rmdir("$LOCAL_PATH/posts/$year/$month", LogHut::Tool::Filter::AcceptPosts->new());
    $f->rmdir("$LOCAL_PATH/posts/$year", LogHut::Tool::Filter::AcceptPosts->new());
    $self->free();
}

sub free {
    my $self = shift;
    undef $self->{html_tree};
}

return 1;
