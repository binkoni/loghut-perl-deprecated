package LogHut::Controller::Posts;

use latest;
use FindBin;
use lib "$FindBin::Bin/../../";
use parent 'LogHut::Controller';
use URI::Escape;
use LogHut::Config;
use LogHut::Log;
use LogHut::Model::Posts;
use LogHut::Tool::Filter::AcceptYears;
use LogHut::Tool::Filter::AcceptMonths;
use LogHut::Tool::Filter::AcceptDays;
use LogHut::Tool::Filter::AcceptTags;
use LogHut::Tool::Filter::AcceptTitle;

sub new {
    my $class = shift;
    my %params = @_; undef @_;
    my $self = $class->SUPER::new(%params);
    $self->add_model('Posts' => LogHut::Model::Posts->new());
    return $self;
}

sub search {
    my $self = shift;
    my $years = $q->param('years');
    my $months = $q->param('months');
    my $days = $q->param('days');
    my $tags = $q->param('tags');
    my $title = $q->param('title');
    my @params;
    $years and  push @params, LogHut::Tool::Filter::AcceptYears->new(years => [split /,/, $years]);
    $months and push @params, LogHut::Tool::Filter::AcceptMonths->new(months => [split /,/, $months]);
    $days and push @params, LogHut::Tool::Filter::AcceptDays->new(days => [split /,/, $days]);
    $tags and push @params, LogHut::Tool::Filter::AcceptTags->new(tags => [split /,/, $tags]);
    $title and push @params, LogHut::Tool::Filter::AcceptTitle->new(title => $title);
    my $contents;
    $f->process_template("$LOCAL_PATH/admin/lib/LogHut/View/posts.tmpl", { url_path => $URL_PATH, posts => [map {$_->solid();$_} $self->get_model('Posts')->search(@params)] }, \$contents);
    return $contents;
}

sub secret {
    my $self = shift;
    my $url_path = $q->param('url_path');
    return $self->get_model('Posts')->secret(uri_unescape $url_path);
}

sub creation_form {
    my $self = shift;
    my $contents;
    $f->process_template("$LOCAL_PATH/admin/lib/LogHut/View/creation_form.tmpl", {url_path => $URL_PATH}, \$contents);
    return $contents;
}

sub create {
    my $self = shift;
    my %params;
    my $title = $q->param('title') || 'No Title';
    my $text = $q->param('text') || '<br/>';
    my $tags = $q->param('tags');
    my $secret = $q->param('secret') && 's';
    $params{title} = $title;
    $params{text} =  $text || '</br>';
    $params{tags} = [split /,/, $tags];
    $params{secret} = $secret;
    my $post = $self->get_model('Posts')->create(%params);
    my $contents;
    $f->process_template("$LOCAL_PATH/admin/lib/LogHut/View/post_result.tmpl", { action => 'create', post_url_path => uri_unescape $post->get_url_path() }, \$contents);
    return $contents;
}

sub modification_form {
    my $self = shift;
    my $url_path = $q->param('url_path');
    my $post = LogHut::Model::Post->new(url_path => uri_unescape $url_path);
    $post->solid();
    my $contents;
    $f->process_template("$LOCAL_PATH/admin/lib/LogHut/View/modification_form.tmpl", { url_path => $URL_PATH, post => $post }, \$contents);
    return $contents;
}

sub modify {
    my $self = shift;
    my %params;
    my $url_path = $q->param('url_path');
    my $title = $q->param('title') || 'No Title';
    my $text = $q->param('text') || '<br/>';
    my $tags = $q->param('tags');
    my $secret = $q->param('secret') && 's';
    $params{url_path} = uri_unescape $url_path;
    $params{title} = $title;
    $params{text} = $text;
    $params{tags} = [split /,/, $tags];
    $params{secret} = $secret;
    my $post = $self->get_model('Posts')->modify(%params);
    my $contents;
    $f->process_template("$LOCAL_PATH/admin/lib/LogHut/View/post_result.tmpl", { action => 'modify', post_url_path => uri_unescape $post->get_url_path() }, \$contents);
    return $contents;
}

sub delete {
    my $self = shift;
    my $url_path = uri_unescape $q->param('url_path');
    my %params;
    $params{url_path} = $url_path;
    $self->get_model('Posts')->delete(%params);
    my $contents;  
    $f->process_template("$LOCAL_PATH/admin/lib/LogHut/View/post_result.tmpl", { action => 'delete', post_url_path => $url_path }, \$contents);
    return $contents;
    
}

sub backup {
    my $self = shift;
    my $contents;
    return 200, ['Content-type', 'application/x-gzip', 'Content-disposition', q(attachment; filename="BACKUP.tar.gz")], [$self->get_model('Posts')->backup()];
}

return 1;
