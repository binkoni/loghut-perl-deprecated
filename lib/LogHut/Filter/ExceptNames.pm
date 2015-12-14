package LogHut::Filter::ExceptNames;
use feature ':all';
use FindBin;
use lib "$FindBin::Bin/../../..";
use parent 'LogHut::Filter';
sub new {
    my $class = shift;
    my %params = @_;
    my $self = $class->SUPER::new(%params);
    $self->{__names} = $params{names};
    return $self;
}
sub test {
    my $self = shift;
    my $target = shift;
    foreach my $name (@{$self->{__names}}) {
        $target eq $name and return undef;
    }
    return 1;
}
return 1;
