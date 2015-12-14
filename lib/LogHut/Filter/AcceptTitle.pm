package LogHut::Filter::AcceptTitle;
use feature ':all';
use FindBin;
use lib "$FindBin::Bin/../../../";
use parent 'LogHut::Filter';
use LogHut::Model::Post;
sub new {
    my $class = shift;
    my %params = @_;
    my $self = $class->SUPER::new(%params);
    $self->{__title} = $params{title};
    return $self;
}
sub test {
    my $self = shift;
    my $target = shift;
    -f $target or return undef;
    return LogHut::Model::Post->new(local_path => $target)->get_title() =~ /$self->{__title}/;
}
return 1;
