package LogHut::Filter::AcceptDays;
use feature ':all';
use FindBin;
use lib "$FindBin::Bin/../../";
use parent 'LogHut::Filter';
sub new {
    my $class = shift;
    my %params = @_;
    my $self = $class->SUPER::new(%params);
    $self->{days} = $params{days};
    return $self;
}
sub test {
    my $self = shift;
    my $target = shift;
    -f $target or return undef;
    $target =~ /\d\d\d\d\/\d\d\/(\d\d)_\d+\.htmls?$/;
    for my $day (@{$self->{days}}) {
        sprintf("%02d", $day) eq $1 and return 1;
    }
    return undef;
}
return 1;
