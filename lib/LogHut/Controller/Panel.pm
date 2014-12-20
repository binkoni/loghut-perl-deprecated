package LogHut::Controller::Panel;

use latest;
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
    my($contents, $contents2);
    if($action eq 'login') {
        return $auth->login();
    }
    elsif($auth->auth()) {
        if($action eq 'logout') {
           return $auth->logout();
        } elsif($action eq 'secret') {
            $contents = $posts->secret();
            $f->process_template("$LOCAL_PATH/admin/lib/LogHut/View/frame.tmpl", { url_path => $URL_PATH, contents => $contents }, \$contents2);
            return $q->psgi_header(-charset => 'utf-8'), [$contents2];

        } elsif($action eq 'search') {
            $contents = $posts->search();
            $f->process_template("$LOCAL_PATH/admin/lib/LogHut/View/frame.tmpl", { url_path => $URL_PATH, contents => $contents }, \$contents2);
            return $q->psgi_header(-charset => 'utf-8'), [$contents2];

        } elsif($action eq 'create') {
            $contents = $posts->create();
            $f->process_template("$LOCAL_PATH/admin/lib/LogHut/View/frame.tmpl", { url_path => $URL_PATH, contents => $contents }, \$contents2);
            return $q->psgi_header(-charset => 'utf-8'), [$contents2];

        } elsif($action eq 'creation_form') {
            $contents = $posts->creation_form();
            $f->process_template("$LOCAL_PATH/admin/lib/LogHut/View/frame.tmpl", { url_path => $URL_PATH, contents => $contents }, \$contents2);
            return $q->psgi_header(-charset => 'utf-8'), [$contents2];

        } elsif($action eq 'modify') {
            $contents = $posts->modify();
            $f->process_template("$LOCAL_PATH/admin/lib/LogHut/View/frame.tmpl", { url_path => $URL_PATH, contents => $contents }, \$contents2);
            return $q->psgi_header(-charset => 'utf-8'), [$contents2];

        } elsif($action eq 'modification_form') {
            $contents = $posts->modification_form();
            $f->process_template("$LOCAL_PATH/admin/lib/LogHut/View/frame.tmpl", { url_path => $URL_PATH, contents => $contents }, \$contents2);
            return $q->psgi_header(-charset => 'utf-8'), [$contents2];

        } elsif($action eq 'delete') {             
            $contents = $posts->delete();
            $f->process_template("$LOCAL_PATH/admin/lib/LogHut/View/frame.tmpl", { url_path => $URL_PATH, contents => $contents }, \$contents2);
            return $q->psgi_header(-charset => 'utf-8'), [$contents2];

        } elsif($action eq 'backup') {
            return $posts->backup();
        } else {
            $f->process_template("$LOCAL_PATH/admin/lib/LogHut/View/main.tmpl", { env => $env }, \$contents);
            $f->process_template("$LOCAL_PATH/admin/lib/LogHut/View/frame.tmpl", { url_path => $URL_PATH, contents => $contents }, \$contents2);
            return $q->psgi_header(-charset => 'utf-8'), [$contents2];
        }
    } else {
         $f->process_template("$LOCAL_PATH/admin/lib/LogHut/View/login_form.tmpl", { url_path => $URL_PATH }, \$contents);
         $f->process_template("$LOCAL_PATH/admin/lib/LogHut/View/frame.tmpl", { url_path => $URL_PATH, contents => $contents }, \$contents2);
         return $q->psgi_header(-charset => 'utf-8'), [$contents2];
    }
}
return 1;
