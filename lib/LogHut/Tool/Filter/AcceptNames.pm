package LogHut::Tool::Filter::AcceptNames;
use feature ':all';
use FindBin;
use lib "$FindBin::Bin/../../";
use parent ('LogHut::Tool::Filter');
sub new {
    my $class = shift;
    my %params = @_;
    my $self = $class->SUPER::new(%params);
    $self->{names} = $params{names};
    return $self;
}
sub test {
    my $self = shift;
    my $target = shift;
    foreach my $name (@{$self->{names}}) {
        $target eq $name or return undef;
    }
    return 1;
}
return 1;
