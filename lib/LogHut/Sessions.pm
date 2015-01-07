package LogHut::Sessions;

use feature ':all';
use FindBin;
use lib "$FindBin::Bin";
use parent 'LogHut::Object';
use LogHut::Tool::File;
use LogHut::Session;

my $file_tool = LogHut::Tool::File->new();

sub new {
    my $class = shift;
    my %params = @_; undef @_;
    my $self = $class->SUPER::new(%params);
    $self->{directory_path} = $params{directory_path};
    return $self;
}

sub read_all {
    my $self = shift;
    return map { LogHut::Session->new(directory_path => $self->{directory_path})->read($_) } $file_tool->get_files(local_path => $self->{directory_path});
}

sub delete_all {
    my $self = shift;
    for my $session ($self->read_all()) {
        $session->delete();
    }
}

sub delete_expired {
    my $self = shift;
    for my $session ($self->read_all()) {
        $session->is_expired() and $session->delete();
    }
}
