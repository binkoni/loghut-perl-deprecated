package LogHut::Tool::Filter::Pipe;
use latest;
use FindBin;
use lib "$FindBin::Bin/../../..";
use parent ('LogHut::Tool::Filter');
sub new{
    my $class = shift;
    my %params = @_;
    my $self = $class->SUPER::new(%params);
    return $self;
}
sub test{
    my $self = shift;
    my $target = shift;
    return ! -p $target;
}
return 1;
