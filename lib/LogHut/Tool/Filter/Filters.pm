package LogHut::Tool::Filter::Filters;
use feature ':all';
use FindBin;
use lib "$FindBin::Bin/../../..";
use parent ('LogHut::Tool::Filter');
sub new {
    my $class = shift;
    my %params = @_; undef @_;
    my $self = $class->SUPER::new(%params);
    $self->{filters} = $params{filters};
    return $self;
}
sub test {
    my $self = shift;
    my $target = shift;
    for my $filter (@{$self->{filters}}) {
        $filter->test($target) or return undef;
    }
    return 1;
}
return 1;
