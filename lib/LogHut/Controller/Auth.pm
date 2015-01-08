package LogHut::Controller::Auth;

use feature ':all';
use FindBin;
use lib "$FindBin::Bin/../../";
use parent 'LogHut::Controller';
use LogHut::Config;
use LogHut::Log;
use LogHut::Sessions;
use LogHut::Session;

sub new {
    my $class = shift;
    my %params = @_; undef @_;
    my $self = $class->SUPER::new(%params);
    return $self;
}

sub auth {
    my $self = shift;
    return eval {
        my $session = LogHut::Session->new(directory_path => "$LOCAL_PATH/admin/session");
        $session->read($q->cookie('SESSION_ID'));
        if($session->is_expired()) {
            $session->delete();
            return undef;
        }
        my %user_data = $session->get_user_data();
        $user_data{admin_id} eq $ADMIN_ID or return undef;
        return $session->update_time();
    };
}

sub login {
    my $self = shift;
    my $session;
    if(eval {
        my $admin_id = $q->param('id');
        my $password = $q->param('password');
        defined $admin_id && $admin_id eq $ADMIN_ID && $ADMIN_PASSWORD eq $password or return undef;
        $f->mkdir("$LOCAL_PATH/admin/session");
        my $sessions = LogHut::Sessions->new(directory_path => "$LOCAL_PATH/admin/session");
        $sessions->delete_expired();
        $session = LogHut::Session->new(directory_path => "$LOCAL_PATH/admin/session");
        return $session->create(expiration_time => $SESSION_TIME, user_data => { admin_id => $admin_id });
    }) {
        return $q->psgi_header(-charset => 'utf-8', -cookie => [$q->cookie(-name => 'SESSION_ID', -value => $session->get_id())]),
            [$f->process_template("$LOCAL_PATH/admin/lib/LogHut/View/auth.tmpl", { url_path => $URL_PATH, action => 'login', status => 'success' })];
    }
    return $q->psgi_header(-charset => 'utf-8'), [$f->process_template("$LOCAL_PATH/admin/lib/LogHut/View/auth.tmpl", { url_path => $URL_PATH, action => 'login', status => 'failure' })];
}
sub logout {
    my $self = shift;
    if(eval {
        my $sessions = LogHut::Sessions->new(directory_path => "$LOCAL_PATH/admin/session");
        $sessions->delete_all();
        return 1;
    }) {
        return $q->psgi_header(-charset => 'utf-8'), [$f->process_template("$LOCAL_PATH/admin/lib/LogHut/View/auth.tmpl", { url_path => $URL_PATH, action => 'logout', status => 'success' })];
    }
    return $q->psgi_header(-charset => 'utf-8'), [$f->process_template("$LOCAL_PATH/admin/lib/LogHut/View/auth.tmpl", { url_path => $URL_PATH, action => 'logout', status => 'failure' })];
}

return 1;
