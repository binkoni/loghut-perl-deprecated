package LogHut::Tool::Filter::Link;
use feature ':all';
use FindBin;
use lib "$FindBin::Bin/../../..";
use parent ('LogHut::Tool::Filter');
sub new {
    my $class = shift;
    my %params = @_;
    my $self = $class->SUPER::new(%params);
    return $self;
}
sub test {
    my $self = shift;
    my $target = shift;
    return -l $target;
}
return 1;
