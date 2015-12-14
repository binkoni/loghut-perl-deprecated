package LogHut::Filter::Custom;
use feature ':all';
use FindBin;
use lib "$FindBin::Bin/../../..";
use parent 'LogHut::Filter';
sub new {
    my $class = shift;
    my %params = @_;
    my $self = $class->SUPER::new(%params);
    $self->{__test} = $params{test};
    return $self;
}
sub test {
    my $self = shift;
    my $target = shift;
    return $self->{__test}->($target);
}
return 1;
