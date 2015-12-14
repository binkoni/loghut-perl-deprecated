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

package LogHut::Controller::Posts;

use feature ':all';
use FindBin;
use lib "$FindBin::Bin/../../";
use parent 'LogHut::Controller';
use LogHut::FileUtil;
use LogHut::Global;
use LogHut::Debug;
use LogHut::Model::Posts;
use LogHut::Filter::AcceptYears;
use LogHut::Filter::AcceptMonths;
use LogHut::Filter::AcceptDays;
use LogHut::Filter::AcceptTags;
use LogHut::Filter::AcceptTitle;
use LogHut::URLUtil;

my $__file_util = LogHut::FileUtil->new(gzip_enabled => 1);

sub new {
    my $class = shift;
    my %params = @_; undef @_;
    my $self = $class->SUPER::new(%params);
    $self->add_model('Posts' => LogHut::Model::Posts->new());
    $self->{__request} = $params{request} or confess 'No argument $request';

    return $self;
}

sub search {
    my $self = shift;
    my @filters;
    my $years = $self->{__request}->get_param('years');
    my $months = $self->{__request}->get_param('months');
    my $days = $self->{__request}->get_param('days');
    my $tags = $self->{__request}->get_param('tags');
    my $title = $self->{__request}->get_param('title');
    my $page = $self->{__request}->get_param('page');
    my $query_string = $self->{__request}->get_env()->{QUERY_STRING};
    $query_string =~ s/&page=\d+//;
    defined $years and push @filters, LogHut::Filter::AcceptYears->new(years => [split ',', $years]);
    defined $months and push @filters, LogHut::Filter::AcceptMonths->new(months => [split ',', $months]);
    defined $days and push @filters, LogHut::Filter::AcceptDays->new(days => [split ',', $days]);
    defined $tags and push @filters, LogHut::Filter::AcceptTags->new(tag_names => [split(',', $tags)]);
    defined $title and push @filters, LogHut::Filter::AcceptTitle->new(title => $title);
    return $__file_util->process_template("$LogHut::Global::settings->{admin_local_path}/lib/LogHut/View/posts.tmpl", {
         action => 'search',
         url_path => $LogHut::Global::settings->{url_path},
         posts => [$self->get_model('Posts')->search(filters => [@filters], page => $page)],
         previous_page => $self->get_model('Posts')->get_previous_page($page),
         current_page => $page,
         next_page => $self->get_model('Posts')->get_next_page($page),
         last_page => $self->get_model('Posts')->get_last_page(),
         query_string => $query_string
    });
}

sub secret {
    my $self = shift;
    return $self->get_model('Posts')->secret(LogHut::URLUtil::decode $self->{__request}->get_param('url_path'));
}

sub creation_form {
    my $self = shift;
    return $__file_util->process_template("$LogHut::Global::settings->{admin_local_path}/lib/LogHut/View/creation_form.tmpl", {url_path => $LogHut::Global::settings->{url_path}});
}

sub create {
    my $self = shift;
    my %params;
    $params{title} = $self->{__request}->get_param('title', 'No Title');
    $params{text} = $self->{__request}->get_param('text' , '<br/>');
    $params{tags} = [split ',', $self->{__request}->get_param('tags')];
    $params{secret} = $self->{__request}->get_param('secret');
    my $post = $self->get_model('Posts')->create(%params);
    return $__file_util->process_template("$LogHut::Global::settings->{admin_local_path}/lib/LogHut/View/post.tmpl", { action => 'create', post => $post, url_path => $LogHut::Global::settings->{url_path} });
}

sub modification_form {
    my $self = shift;
    my $post = LogHut::Model::Post->new(url_path => LogHut::URLUtil::decode $self->{__request}->get_param('url_path'));
    return $__file_util->process_template("$LogHut::Global::settings->{admin_local_path}/lib/LogHut/View/modification_form.tmpl", { post => $post, url_path => $LogHut::Global::settings->{url_path} });
}

sub modify {
    my $self = shift;
    my %params;
    $params{url_path} = LogHut::URLUtil::decode $self->{__request}->get_param('url_path');
    $params{title} = $self->{__request}->get_param('title', 'No Title');
    $params{text} = $self->{__request}->get_param('text', '<br/>');
    $params{tags} = [split ',', $self->{__request}->get_param('tags')];
    $params{secret} = $self->{__request}->get_param('secret');
    my $post = $self->get_model('Posts')->modify(%params);
    return $__file_util->process_template("$LogHut::Global::settings->{admin_local_path}/lib/LogHut/View/post.tmpl", { action => 'modify', post => $post, url_path => $LogHut::Global::settings->{url_path} });
}

sub delete {
    my $self = shift;
    my %params;
    my $url_path = $self->{__request}->get_param('url_path');
    $params{url_path} = LogHut::URLUtil::decode $url_path;
    $self->get_model('Posts')->delete(%params);
    return $__file_util->process_template("$LogHut::Global::settings->{admin_local_path}/lib/LogHut/View/post.tmpl", { action => 'delete', post_url_path => $url_path, url_path => $LogHut::Global::settings->{url_path} });
}

sub backup {
    my $self = shift;
    return 200, ['Content-Type' => 'application/x-gzip', 'Content-Disposition' => 'attachment; filename="BACKUP.tar.gz"'], [$self->get_model('Posts')->backup()];
}

sub refresh {
    my $self = shift;
    $self->get_model('Posts')->refresh();
    return $__file_util->process_template("$LogHut::Global::settings->{admin_local_path}/lib/LogHut/View/posts.tmpl", { action => 'refresh', url_path => $LogHut::Global::settings->{url_path} });
}

return 1;
