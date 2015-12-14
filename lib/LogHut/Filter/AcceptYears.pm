package LogHut::Filter::AcceptYears;
use feature ':all';
use FindBin;
use lib "$FindBin::Bin/../../";
use parent 'LogHut::Filter';
sub new {
    my $class = shift;
    my %params = @_;
    my $self = $class->SUPER::new(%params);
    $self->{__years} = $params{years};
    return $self;
}
sub test {
    my $self = shift;
    my $target = shift;
    -f $target or return undef;
    $target =~ /(\d\d\d\d)\/\d\d\/\d\d_\d+\.htmls?$/;
    for my $year (@{$self->{__years}}){
        $year eq $1 and return 1;
    }
    return undef;
}
return 1;
