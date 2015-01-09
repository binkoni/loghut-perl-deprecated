package LogHut::Controller::Panel;

use feature ':all';
use FindBin;
use lib "$FindBin::Bin/../../";
use parent 'LogHut::Controller';
use LogHut::Config;
use LogHut::Controller::Auth;
use LogHut::Controller::Posts;
use LogHut::Log;

sub new {
    my $class = shift;
    my %params = @_; undef @_;
    my $self = $class->SUPER::new(%params);
    return $self;
}

sub run {
    my $self = shift;
    my $action = $q->param('action') || 'default';
    my $auth = LogHut::Controller::Auth->new();
    my $posts = LogHut::Controller::Posts->new();
    if($action eq 'login') {
        return $auth->login();
    } elsif($auth->auth()) {
        if($action eq 'logout') {
           return $auth->logout();
        } elsif($action eq 'secret') {
            return $q->psgi_header(-charset => 'utf-8'), [$f->process_template("$LOCAL_PATH/admin/lib/LogHut/View/frame.tmpl", { url_path => $URL_PATH, contents => $posts->secret() })];

        } elsif($action eq 'search') {
            return $q->psgi_header(-charset => 'utf-8'), [$f->process_template("$LOCAL_PATH/admin/lib/LogHut/View/frame.tmpl", { url_path => $URL_PATH, contents => $posts->search() })];

        } elsif($action eq 'create') {
            return $q->psgi_header(-charset => 'utf-8'), [$f->process_template("$LOCAL_PATH/admin/lib/LogHut/View/frame.tmpl", { url_path => $URL_PATH, contents => $posts->create() })];

        } elsif($action eq 'creation_form') {
            return $q->psgi_header(-charset => 'utf-8'), [$f->process_template("$LOCAL_PATH/admin/lib/LogHut/View/frame.tmpl", { url_path => $URL_PATH, contents => $posts->creation_form() })];

        } elsif($action eq 'modify') {
            return $q->psgi_header(-charset => 'utf-8'), [$f->process_template("$LOCAL_PATH/admin/lib/LogHut/View/frame.tmpl", { url_path => $URL_PATH, contents => $posts->modify() })];

        } elsif($action eq 'modification_form') {
            return $q->psgi_header(-charset => 'utf-8'), [$f->process_template("$LOCAL_PATH/admin/lib/LogHut/View/frame.tmpl", { url_path => $URL_PATH, contents => $posts->modification_form() })];

        } elsif($action eq 'delete') {
            return $q->psgi_header(-charset => 'utf-8'), [$f->process_template("$LOCAL_PATH/admin/lib/LogHut/View/frame.tmpl", { url_path => $URL_PATH, contents => $posts->delete() })];

        } elsif($action eq 'backup') {
            return $posts->backup();
        } elsif($action eq 'refresh') {
            return $q->psgi_header(-charset => 'utf-8'), [$f->process_template("$LOCAL_PATH/admin/lib/LogHut/View/frame.tmpl", { url_path => $URL_PATH, contents => $posts->refresh() })];

        } else {
            return $q->psgi_header(-charset => 'utf-8'), [$f->process_template("$LOCAL_PATH/admin/lib/LogHut/View/frame.tmpl", { url_path => $URL_PATH, contents => $f->process_template("$LOCAL_PATH/admin/lib/LogHut/View/main.tmpl", { env => $env }) })];
        }
    } else {
         return $q->psgi_header(-charset => 'utf-8'),
             [$f->process_template("$LOCAL_PATH/admin/lib/LogHut/View/frame.tmpl", { url_path => $URL_PATH, contents => $f->process_template("$LOCAL_PATH/admin/lib/LogHut/View/login_form.tmpl", { url_path => $URL_PATH }) })];
    }
}

sub process_template {
    my $self = shift;
}

return 1;
