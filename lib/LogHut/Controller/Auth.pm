# This file is part of LogHut.
#
# LogHut is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# LogHut is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with LogHut.  If not, see <http://www.gnu.org/licenses/>.

package LogHut::Controller::Auth;

use feature ':all';
use FindBin;
use lib "$FindBin::Bin/../../";
use parent 'LogHut::Controller';
use Digest::SHA 'sha512_hex';
use LogHut::Global;
use LogHut::Debug;
use LogHut::FileUtil;
use LogHut::Sessions;
use LogHut::Session;
use LogHut::TemporaryStores;
use LogHut::TemporaryStore;

my $file_util = LogHut::FileUtil->new(gzip_enabled => 1);

sub new {
    my $class = shift;
    my %params = @_; undef @_;
    my $self = $class->SUPER::new(%params);
    $self->{request} = $params{request} or confess 'No argument $request';

    return $self;
}

sub auth {
    my $self = shift;
    return eval {
        my $session = LogHut::Session->new(directory_path => $LogHut::Global::settings->{session_local_path});
        my $session_id = $self->{request}->get_cookie('SESSION_ID');
        defined $session_id or return undef;
        $session->read($session_id) or return undef;
        if($session->is_expired()) {
            $session->delete();
            return undef;
        }
        my %user_data = $session->get_user_data();
        $user_data{admin_id} eq $LogHut::Global::settings->{admin_id} or return undef;
        if($LogHut::Global::settings->{session_ip_match}) { $user_data{ip} eq $self->{request}->get_env()->{HTTP_X_FORWARDED_FOR} or return undef; }
        return $session->update_time();
    };
}

sub login {
    my $self = shift;
    my $session;
    if(eval {
        my $admin_id = $self->{request}->get_param('id');
        my $password = $self->{request}->get_param('password');
        defined $admin_id or return undef;
        sha512_hex($admin_id . $LogHut::Global::settings->{admin_salt}) eq $LogHut::Global::settings->{admin_id} or return undef;
        sha512_hex($password . $LogHut::Global::settings->{admin_salt}) eq $LogHut::Global::settings->{admin_password} or return undef;
        $file_util->mkdir($LogHut::Global::settings->{session_local_path});
        my $sessions = LogHut::Sessions->new(directory_path => $LogHut::Global::settings->{session_local_path});
        $sessions->delete_expired();
        $session = LogHut::Session->new(directory_path => $LogHut::Global::settings->{session_local_path});
        my %user_data = (admin_id => sha512_hex $admin_id . $LogHut::Global::settings->{admin_salt});
        $LogHut::Global::settings->{session_ip_match} and $user_data{ip} = $self->{request}->get_env()->{HTTP_X_FORWARDED_FOR};
        $session->create(expiration_time => $LogHut::Global::settings->{session_time}, user_data => \%user_data );
        return 1;
    }) {
        return 200, ['Content-Type' => 'text/html; charset=utf-8', 'Set-Cookie' => 'SESSION_ID=' . $session->get_id()],
            [$file_util->process_template("$LogHut::Global::settings->{admin_local_path}/lib/LogHut/View/auth.tmpl",
                { url_path => $LogHut::Global::settings->{url_path}, action => 'login', original_query_string => $self->{request}->get_param('original_query_string'), status => 'success' })];
    }

    return 200, ['Content-Type' => 'text/html; charset=utf-8'], [$file_util->process_template("$LogHut::Global::settings->{admin_local_path}/lib/LogHut/View/auth.tmpl", { url_path => $LogHut::Global::settings->{url_path}, action => 'login', status => 'failure' })];
}

sub logout {
    my $self = shift;
    if(eval {
        my $sessions = LogHut::Sessions->new(directory_path => $LogHut::Global::settings->{session_local_path});
        $sessions->delete_all();
        return 1;
    }) {
        return 200, ['Content-Type' => 'text/html; charset=utf-8'], [$file_util->process_template("$LogHut::Global::settings->{admin_local_path}/lib/LogHut/View/auth.tmpl", { url_path => $LogHut::Global::settings->{url_path}, action => 'logout', status => 'success' })];
    }
    return 200, ['Content-Type' => 'text/html; charset=utf-8'], [$file_util->process_template("$LogHut::Global::settings->{admin_local_path}/lib/LogHut/View/auth.tmpl", { url_path => $LogHut::Global::settings->{url_path}, action => 'logout', status => 'failure' })];
}

return 1;
