package LogHut::Controller::Posts;

use feature ':all';
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
    my @filters;
    my $years = $q->param('years');
    my $months = $q->param('months');
    my $days = $q->param('days');
    my $tags = $q->param('tags');
    my $title = $q->param('title');
    my $page = $q->param('page');
    $years and  push @filters, LogHut::Tool::Filter::AcceptYears->new(years => [split /,/, $years]);
    $months and push @filters, LogHut::Tool::Filter::AcceptMonths->new(months => [split /,/, $months]);
    $days and push @filters, LogHut::Tool::Filter::AcceptDays->new(days => [split /,/, $days]);
    $tags and push @filters, LogHut::Tool::Filter::AcceptTags->new(tag_names => [split(/,/, $tags)]);
    $title and push @filters, LogHut::Tool::Filter::AcceptTitle->new(title => $title);
    return $f->process_template("$LOCAL_PATH/admin/lib/LogHut/View/posts.tmpl", {
         action => 'search',
         url_path => $URL_PATH,
         posts => [$self->get_model('Posts')->search(filters => [@filters], page => $page)],
         previous_page => $self->get_model('Posts')->get_previous_page($page),
         current_page => $page,
         next_page => $self->get_model('Posts')->get_next_page($page),
         last_page => $self->get_model('Posts')->get_last_page()
    });
}

sub secret {
    my $self = shift;
    return $self->get_model('Posts')->secret(uri_unescape $q->param('url_path'));
}

sub creation_form {
    my $self = shift;
    return $f->process_template("$LOCAL_PATH/admin/lib/LogHut/View/creation_form.tmpl", {url_path => $URL_PATH});
}

sub create {
    my $self = shift;
    my %params;
    $params{title} = $q->param('title') || 'No Title';
    $params{text} =  $q->param('text') || '<br/>';
    $params{tags} = [split /,/, $q->param('tags')];
    $params{secret} = $q->param('secret');
    my $post = $self->get_model('Posts')->create(%params);
    return $f->process_template("$LOCAL_PATH/admin/lib/LogHut/View/post.tmpl", { action => 'create', post => $post, url_path => $URL_PATH });
}

sub modification_form {
    my $self = shift;
    my $post = LogHut::Model::Post->new(url_path => uri_unescape $q->param('url_path'));
    return $f->process_template("$LOCAL_PATH/admin/lib/LogHut/View/modification_form.tmpl", { post => $post, url_path => $URL_PATH });
}

sub modify {
    my $self = shift;
    my %params;
    $params{url_path} = uri_unescape $q->param('url_path');
    $params{title} = $q->param('title') || 'No Title';
    $params{text} = $q->param('text') || '<br/>';
    $params{tags} = [split /,/, $q->param('tags')];
    $params{secret} = $q->param('secret');
    my $post = $self->get_model('Posts')->modify(%params);
    return $f->process_template("$LOCAL_PATH/admin/lib/LogHut/View/post.tmpl", { action => 'modify', post => $post, url_path => $URL_PATH });
}

sub delete {
    my $self = shift;
    my %params;
    my $url_path = $q->param('url_path');
    $params{url_path} = uri_unescape $url_path;
    $self->get_model('Posts')->delete(%params);
    return $f->process_template("$LOCAL_PATH/admin/lib/LogHut/View/post.tmpl", { action => 'delete', post_url_path => $url_path, url_path => $URL_PATH });
}

sub backup {
    my $self = shift;
    return 200, ['Content-type', 'application/x-gzip', 'Content-disposition', 'attachment; filename="BACKUP.tar.gz"'], [$self->get_model('Posts')->backup()];
}

sub refresh {
    my $self = shift;
    $self->get_model('Posts')->refresh();
    return $f->process_template("$LOCAL_PATH/admin/lib/LogHut/View/posts.tmpl", { action => 'refresh', url_path => $URL_PATH });
}

return 1;
