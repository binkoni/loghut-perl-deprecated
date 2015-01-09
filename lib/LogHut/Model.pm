package LogHut::Model;

use feature ':all';
use FindBin;
use lib "$FindBin::Bin";
use parent 'LogHut::Object';

sub new {
    my $class = shift;
    my %params = @_; undef @_;
    my $self = $class->SUPER::new(%params);
    return $self;
}

sub set_controller {
    my $self = shift;
    $self->{controller} = shift;
    return $self;
}

sub get_controller {
    my $self = shift;
    return $self->{controller};
}

return 1;
