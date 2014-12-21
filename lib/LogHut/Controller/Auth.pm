package LogHut::Controller::Auth;

use feature ':all';
use FindBin;
use lib "$FindBin::Bin/../../";
use parent 'LogHut::Controller';
use CGI::Session '-ip_match';
use LogHut::Config;
use LogHut::Log;

sub new {
    my $class = shift;
    my %params = @_; undef @_;
    my $self = $class->SUPER::new(%params);
    return $self;
}

sub auth {
    my $self = shift;
    my $session;
    eval {
        $session = CGI::Session->load(undef, $q->cookie('CGISESSID'), {Directory => "$LOCAL_PATH/admin/session"});
        if($session->is_expired() || $session->is_empty()){
             $session->delete();
             return undef;
        }
        $session->param(-name => 'admin_id') or return undef;
    } or return undef;
    return $session->param(-name => 'admin_id') eq $ADMIN_ID;
}

sub login {
    my $self = shift;
    my $id = $q->param('id');
    my $password = $q->param('password');
    my $session_time = $SESSION_TIME;
    my $session;
    my $contents;
    if(eval {
        defined $id && defined $password && $ADMIN_ID eq $id && $ADMIN_PASSWORD eq $password or return undef;
        $f->mkdir("$LOCAL_PATH/admin/session");
        $session = CGI::Session->load(undef, $q->cookie('CGISESSID'), {Directory => "$LOCAL_PATH/admin/session"});
        eval {!$session->is_expired() || !$session->is_empty() and $session->delete()};
        $session = CGI::Session->new(undef, $q, {Directory => "$LOCAL_PATH/admin/session"});
        $session->param(-name => 'admin_id', -value => $id);
        $session->flush();
        $session->expire($session_time);
        return 1;
    }) {
        $f->process_template("$LOCAL_PATH/admin/lib/LogHut/View/auth.tmpl", { url_path => $URL_PATH, action => 'login', status => 'success' }, \$contents);
        return $q->psgi_header(-charset => 'utf-8', -cookie => [$q->cookie(-name => 'CGISESSID', -value => $session->id())]), [$contents];
    }
    $f->process_template("$LOCAL_PATH/admin/lib/LogHut/View/auth.tmpl", { url_path => $URL_PATH, action => 'login', status => 'failure' }, \$contents);
    return $q->psgi_header(-charset => 'utf-8'), [$contents];
}
sub logout {
    my $self = shift;
    my $session;
    eval {
        $session = CGI::Session->load(undef, $q->cookie('CGISESSID'), { Directory => "$LOCAL_PATH/admin/session"} );
        $session->delete();
        $session->flush();
    };
    my $contents;
    $f->process_template("$LOCAL_PATH/admin/lib/LogHut/View/auth.tmpl", { url_path => $URL_PATH, action => 'logout', status => 'success' }, \$contents);
    return $q->psgi_header(-charset => 'utf-8'), [$contents];
}

return 1;
