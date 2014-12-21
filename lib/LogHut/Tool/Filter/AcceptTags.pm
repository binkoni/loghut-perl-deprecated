package LogHut::Tool::Filter::AcceptTags;
use feature ':all';
use FindBin;
use lib "$FindBin::Bin/../../";
use parent ('LogHut::Tool::Filter');
use LogHut::Model::Post;
sub new{
    my $class = shift;
    my %params = @_;
    my $self = $class->SUPER::new(%params);
    $self->{tags} = $params{tags};
    return $self;
}
sub test{
    my $self = shift;
    my $target = shift;
    -f $target or return undef;
    my %tag_test;
    for my $tag (LogHut::Model::Post->new(local_path => $target)->get_tags()){
        $tag_test{$tag} = 1;
    }
    for my $tag (@{$self->{tags}}){
        $tag_test{$tag} or return undef;
    }
    return 1;
}
return 1;
