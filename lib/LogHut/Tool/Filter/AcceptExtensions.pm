package LogHut::Tool::Filter::AcceptExtensions;
use feature ':all';
use FindBin;
use lib "$FindBin::Bin/../../";
use parent ('LogHut::Tool::Filter');
sub new {
    my $class = shift;
    my %params = @_;
    my $self = $class->SUPER::new(%params);
    $self->{extensions} = $params{extensions};
    return $self;
}
sub test {
    my $self = shift;
    my $target = shift;
    for my $extension (@{$self->{extensions}}) {
        $target =~ /\.$extension$/ or return undef;
    }
    return 1;
}
return 1;
