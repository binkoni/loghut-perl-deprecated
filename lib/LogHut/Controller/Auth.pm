#This file is part of LogHut.
#
#LogHut is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation, either version 3 of the License, or
#(at your option) any later version.
#
#LogHut is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#
#You should have received a copy of the GNU General Public License
#along with LogHut.  If not, see <http://www.gnu.org/licenses/>.

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
        $session->read($q->get_cookie('SESSION_ID'));
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
        my $admin_id = $q->get_param('id');
        my $password = $q->get_param('password');
        defined $admin_id && $admin_id eq $ADMIN_ID && $ADMIN_PASSWORD eq $password or return undef;
        $f->mkdir("$LOCAL_PATH/admin/session");
        my $sessions = LogHut::Sessions->new(directory_path => "$LOCAL_PATH/admin/session");
        $sessions->delete_expired();
        $session = LogHut::Session->new(directory_path => "$LOCAL_PATH/admin/session");
        $session->create(expiration_time => $SESSION_TIME, user_data => { admin_id => $admin_id });
        return 1;
    }) {
        return 200, ['Content-Type' => 'text/html; charset=utf-8', 'Set-Cookie' => 'SESSION_ID=' . $session->get_id()],
            [$f->process_template("$LOCAL_PATH/admin/lib/LogHut/View/auth.tmpl", { url_path => $URL_PATH, action => 'login', status => 'success' })];
    }

    return 200, ['Content-Type' => 'text/html; charset=utf-8'], [$f->process_template("$LOCAL_PATH/admin/lib/LogHut/View/auth.tmpl", { url_path => $URL_PATH, action => 'login', status => 'failure' })];
}

sub logout {
    my $self = shift;
    if(eval {
        my $sessions = LogHut::Sessions->new(directory_path => "$LOCAL_PATH/admin/session");
        $sessions->delete_all();
        return 1;
    }) {
        return 200, ['Content-Type' => 'text/html; charset=utf-8'], [$f->process_template("$LOCAL_PATH/admin/lib/LogHut/View/auth.tmpl", { url_path => $URL_PATH, action => 'logout', status => 'success' })];
    }
    return 200, ['Content-Type' => 'text/html; charset=utf-8'], [$f->process_template("$LOCAL_PATH/admin/lib/LogHut/View/auth.tmpl", { url_path => $URL_PATH, action => 'logout', status => 'failure' })];
}

return 1;
