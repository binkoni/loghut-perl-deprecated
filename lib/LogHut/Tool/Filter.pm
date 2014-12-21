package LogHut::Tool::Filter;

use feature ':all';
use FindBin;
use lib "$FindBin::Bin/../../";
use parent 'LogHut::Object';

sub new{
    my $class = shift;
    my %params = @_;
    my $self = $class->SUPER::new(%params);
    return $self;
}

sub test{
    my $self = shift;
}

return 1;
