package LogHut::Filter::AcceptTags;
use feature ':all';
use FindBin;
use lib "$FindBin::Bin/../../";
use parent 'LogHut::Filter';
use LogHut::Model::Post;
sub new {
    my $class = shift;
    my %params = @_;
    my $self = $class->SUPER::new(%params);
    $self->{tag_names} = $params{tag_names};
    return $self;
}
sub test {
    my $self = shift;
    my $target = shift;
    -f $target or return undef;
    my %tag_test;
    for my $tag_name (LogHut::Model::Post->new(local_path => $target)->get_tag_names()) {
        $tag_test{$tag_name} = 1;
    }
    for my $tag_name (@{$self->{tag_names}}) {
        $tag_test{$tag_name} or return undef;
    }
    return 1;
}
return 1;
