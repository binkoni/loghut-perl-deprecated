package LogHut::Tool::Filter::Custom;
use feature ':all';
use FindBin;
use lib "$FindBin::Bin/../../..";
use parent ('LogHut::Tool::Filter');
sub new{
    my $class = shift;
    my %params = @_;
    my $self = $class->SUPER::new(%params);
    $self->{test} = $params{test};
    return $self;
}
sub test{
    my $self = shift;
    my $target = shift;
    return $self->{test}->($target);
}
return 1;
