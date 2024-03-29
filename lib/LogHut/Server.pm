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

package LogHut::Server;

use feature ':all';
use FindBin;
use lib "$FindBin::Bin";
use parent 'LogHut::Object';
use LogHut::Debug;
use Encode ();
use IO::Socket::IP;
use POSIX;


$SIG{ALRM} = 'IGNORE';
$SIG{PIPE} = 'IGNORE';
local $/ = "\r\n";
my %reason_phrases = (
    100 => 'Continue',
    101 => 'Switching Protocols',
    102 => 'Processing',
    200 => 'OK',
    201 => 'Created',
    202 => 'Accepted',
    203 => 'Non-Authoritative Information',
    204 => 'No Content',
    205 => 'Reset Content',
    206 => 'Partial Content',
    207 => 'Multi-Status',
    300 => 'Multiple Choices',
    301 => 'Moved Permanently',
    302 => 'Found',
    303 => 'See Other',
    304 => 'Not Modified',
    305 => 'Use Proxy',
    307 => 'Temporary Redirect',
    400 => 'Bad Request',
    401 => 'Unauthorized',
    402 => 'Payment Required',
    403 => 'Forbidden',
    404 => 'Not Found',
    405 => 'Method Not Allowed',
    406 => 'Not Acceptable',
    407 => 'Proxy Authentication Required',
    408 => 'Request Timeout',
    409 => 'Conflict',
    410 => 'Gone',
    411 => 'Length Required',
    412 => 'Precondition Failed',
    413 => 'Request Entity Too Large',
    414 => 'Request-URI Too Large',
    415 => 'Unsupported Media Type',
    416 => 'Request Range Not Satisfiable',
    417 => 'Expectation Failed',
    422 => 'Unprocessable Entity',
    423 => 'Locked',
    424 => 'Failed Dependency',
    425 => 'No code',
    426 => 'Upgrade Required',
    449 => 'Retry with',
    500 => 'Internal Server Error',
    501 => 'Not Implemented',
    502 => 'Bad Gateway',
    503 => 'Service Unavailable',
    504 => 'Gateway Timeout',
    505 => 'HTTP Version Not Supported',
    506 => 'Variant Also Negotiates',
    507 => 'Insufficient Storage',
    509 => 'Bandwidth Limit Exceeded',
    510 => 'Not Extended',
);

sub new {
    my $class = shift;
    my %params = @_; undef @_;
    my $self = $class->SUPER::new(%params);
    $self->{__app} = $params{app};
    defined $self->{__app} or confess 'No argument $app';
    $self->{__ip} = $params{ip};
    defined $self->{__ip} or $self->{__ip} = '127.0.0.1';
    $self->{__port} = $params{port};
    defined $self->{__port} or $self->{__port} = '8080';
    return $self;
}

sub __process_request {
    my $self = shift;  
    $self->__process_request_line();
    $self->__process_headers();
    $self->__process_data();
    $self->{__env}->{SERVER_NAME} = $self->{__ip};
    $self->{__env}->{SERVER_PORT} = $self->{__port};
    $self->{__env}->{'psgi.version'} = [1, 1];
    $self->{__env}->{'psgi.url_scheme'} = 'http';
    $self->{__env}->{'psgi.errors'} = 0;
    $self->{__env}->{'psgi.multithread'} = 0;
    $self->{__env}->{'psgi.multiprocess'} = 0;
    $self->{__env}->{'psgi.run_once'} = 0;
    $self->{__env}->{'psgi.nonblocking'} = 0;
    $self->{__env}->{'psgi.streaming'} = 0;  
    $self->{__env}->{'psgix.io'} = $self->{__client_socket};
    $self->{__env}->{'psgix.input.buffered'} = 0;
#    $self->{__env}->{psgix.logger} = undef;
#    $self->{__env}->{psgix.session} = undef;
#    $self->{__env}->{psgix.session.options} = undef;
#    $self->{__env}->{psgix.harakiri} = 0;
#    $self->{__env}->{psgix.cleanup} = 1;
#    $self->{__env}->{psgix.cleanup.handlers} = undef;
}
 
sub __process_request_line {
    my $self = shift;
    my $line = $self->{__client_socket}->getline();
    chomp $line;
    $line =~ m/([\x{21}\x{23}-\x{27}\x{2A}\x{2B}\x{2D}\x{2F}-\x{39}\x{41}-x{5A}\x{5E}-\x{7A}\x{7C}\x{7E}]+) ([[:print:]]+) (HTTP\/[0-9]\.[0-9])/;
    $self->{__env}->{REQUEST_METHOD} = $1;
    defined $self->{__env}->{REQUEST_METHOD} or confess 'No $REQUEST_METHOD';
    $self->{__env}->{REQUEST_URI} = $2;
    defined $self->{__env}->{REQUEST_URI} or confess 'No $REQUEST_URI';
    ($self->{__env}->{PATH_INFO}, $self->{__env}->{QUERY_STRING}) = split '\?', $self->{__env}->{REQUEST_URI};
    $self->{__env}->{SCRIPT_NAME} = undef; #index.pl
    $self->{__env}->{SERVER_PROTOCOL} = $3;
    defined $self->{__env}->{SERVER_PROTOCOL} or confess 'No $SERVER_PROTOCOL';
}

sub __process_headers {
    my $self = shift;
    my($name, $value);
    while(($line = $self->{__client_socket}->getline()) ne "\r\n") {
        $content .= $line;
        chomp $line;

#field-content = field-vchar [ 1*( SP / HTAB ) field-vchar ]
#field-vchar    = VCHAR / obs-text
#field-value = *( field-content / obs-fold )
#obs-fold = CRLF 1*( SP / HTAB )
#obs-text       = %x80-FF
#VCHAR (any visible [USASCII] character).

        $line =~ m/([\x{21}\x{23}-\x{27}\x{2A}\x{2B}\x{2D}\x{2F}-\x{39}\x{41}-x{5A}\x{5E}-\x{7A}\x{7C}\x{7E}]+)\: ?([[:print:]]*) ?/;
        ($name, $value) = ($1, $2);
        if($name =~ m/^Content-Length$/i) {
            $self->{__env}->{CONTENT_LENGTH} = $value;
        } elsif($name =~ m/^Content-Type$/i) {
            $self->{__env}->{CONTENT_TYPE} = $value;
        } else {
            $name =~ tr/-/_/;
            $name = 'HTTP_' . uc $name;
            if(defined $self->{__env}->{$name}) {
                $self->{__env}->{$name} = ",$value";
            } else {
                $self->{__env}->{$name} = $value;
            }
        }
    }
}

sub __process_data {
    my $self = shift;
    my $data;
    $self->{__env}->{CONTENT_LENGTH} and $self->{__client_socket}->read($data, $self->{__env}->{CONTENT_LENGTH});
    open $self->{__env}->{'psgi.input'}, '<', \$data;
}

sub __respond {
    my $self = shift;
    my $result = shift;
    if(ref $result eq 'ARRAY') {
        $self->{__client_socket}->say("$self->{__env}->{SERVER_PROTOCOL} $result->[0] $reason_phrases{$result->[0]}");
        $self->{__client_socket}->say('Server: LogHut::Server');
        my %headers = @{$result->[1]};
        my $content = join '', @{$result->[2]};
        $headers{'Content-Type'} =~ m/^text\// and $content = Encode::encode 'utf-8', $content;
        $headers{'Content-Length'} = length $content;
        for my $key (keys %headers) {
            $self->{__client_socket}->say("$key: $headers{$key}");
        }
        $self->{__client_socket}->say();
        $self->{__client_socket}->print($content);
    } elsif(ref $result eq 'CODE') {
        $result->(sub {
             my $result = shift;
             $self->__respond($result)
        });
    }
}


sub run {
    my $self = shift;
    my $backlog = shift;
    defined $backlog or $backlog = 1;

    if(my $pid = fork) {
        say $pid;
        exit;
    }

    my $server_socket = IO::Socket::IP->new(LocalAddr => $self->{__ip}, LocalPort => $self->{__port}, Family => AF_INET, Type => SOCK_STREAM, Proto => 'tcp', ReuseAddr => 1, Blocking => 1) or confess $!;
    $server_socket->listen($backlog);

    while($self->{__client_socket} = $server_socket->accept()) {
        $self->{__env} = {};
        if(eval {
            local $SIG{ALRM} = sub { die 'ALRM' };
            alarm 1;
            $self->__process_request();
            return 1;
        }) {
            eval { $self->__respond($self->{__app}->($self->{__env})) };
        } else {
            carp '__process_request() failed';
            $self->__respond([400, ['Content-Type' => 'text/html'], ["<h1>$reason_phrases{400}</h1>"]])
        }
        $self->{__client_socket}->close();
    }
}
