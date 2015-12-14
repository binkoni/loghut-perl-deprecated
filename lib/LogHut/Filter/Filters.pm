package LogHut::Filter::Filters;
use feature ':all';
use FindBin;
use lib "$FindBin::Bin/../../..";
use parent 'LogHut::Filter';
sub new {
    my $class = shift;
    my %params = @_; undef @_;
    my $self = $class->SUPER::new(%params);
    $self->{__filters} = $params{filters};
    return $self;
}
sub test {
    my $self = shift;
    my $target = shift;
    for my $filter (@{$self->{__filters}}) {
        defined $filter or next;
        $filter->test($target) or return undef;
    }
    return 1;
}
return 1;
