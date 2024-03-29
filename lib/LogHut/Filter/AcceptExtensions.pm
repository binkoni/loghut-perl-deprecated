package LogHut::Filter::AcceptExtensions;
use feature ':all';
use FindBin;
use lib "$FindBin::Bin/../../";
use parent 'LogHut::Filter';
sub new {
    my $class = shift;
    my %params = @_;
    my $self = $class->SUPER::new(%params);
    $self->{__extensions} = $params{extensions};
    return $self;
}
sub test {
    my $self = shift;
    my $target = shift;
    for my $extension (@{$self->{__extensions}}) {
        $target =~ /\.$extension$/ or return undef;
    }
    return 1;
}
return 1;
