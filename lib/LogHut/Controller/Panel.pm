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
    my $action = $q->get_param('action');
    defined $action or $action = 'default';
    my $auth = LogHut::Controller::Auth->new();
    my $posts = LogHut::Controller::Posts->new();
    if($action eq 'login') {
        return $auth->login();
    } elsif($auth->auth()) {
        if($action eq 'logout') {
           return $auth->logout();
        } elsif($action eq 'secret') {
            return 200, ['Content-Type' => 'text/html; charset=utf-8'], [$posts->secret()];

        } elsif($action eq 'search') {
            return 200, ['Content-Type' => 'text/html; charset=utf-8'], [$f->process_template("$LOCAL_PATH/admin/lib/LogHut/View/frame.tmpl", { url_path => $URL_PATH, contents => $posts->search() })];

        } elsif($action eq 'create') {
            return 200, ['Content-Type' => 'text/html; charset=utf-8'], [$f->process_template("$LOCAL_PATH/admin/lib/LogHut/View/frame.tmpl", { url_path => $URL_PATH, contents => $posts->create() })];

        } elsif($action eq 'creation_form') {
            return 200, ['Content-Type' => 'text/html; charset=utf-8'], [$f->process_template("$LOCAL_PATH/admin/lib/LogHut/View/frame.tmpl", { url_path => $URL_PATH, contents => $posts->creation_form() })];

        } elsif($action eq 'modify') {
            return 200, ['Content-Type' => 'text/html; charset=utf-8'], [$f->process_template("$LOCAL_PATH/admin/lib/LogHut/View/frame.tmpl", { url_path => $URL_PATH, contents => $posts->modify() })];

        } elsif($action eq 'modification_form') {
            return 200, ['Content-Type' => 'text/html; charset=utf-8'], [$f->process_template("$LOCAL_PATH/admin/lib/LogHut/View/frame.tmpl", { url_path => $URL_PATH, contents => $posts->modification_form() })];

        } elsif($action eq 'delete') {
            return 200, ['Content-Type' => 'text/html; charset=utf-8'], [$f->process_template("$LOCAL_PATH/admin/lib/LogHut/View/frame.tmpl", { url_path => $URL_PATH, contents => $posts->delete() })];

        } elsif($action eq 'backup') {
            return $posts->backup();
        } elsif($action eq 'refresh') {
            return 200, ['Content-Type' => 'text/html; charset=utf-8'], [$f->process_template("$LOCAL_PATH/admin/lib/LogHut/View/frame.tmpl", { url_path => $URL_PATH, contents => $posts->refresh() })];

        } else {
            return 200, ['Content-Type' => 'text/html; charset=utf-8'], [$f->process_template("$LOCAL_PATH/admin/lib/LogHut/View/frame.tmpl", { url_path => $URL_PATH, contents => $f->process_template("$LOCAL_PATH/admin/lib/LogHut/View/main.tmpl", { env => $q->get_env() }) })];
        }
    } else {
         return 200, ['Content-Type' => 'text/html; charset=utf-8'],
             [$f->process_template("$LOCAL_PATH/admin/lib/LogHut/View/frame.tmpl", { url_path => $URL_PATH, contents => $f->process_template("$LOCAL_PATH/admin/lib/LogHut/View/login_form.tmpl", { url_path => $URL_PATH }) })];
    }
}

return 1;
