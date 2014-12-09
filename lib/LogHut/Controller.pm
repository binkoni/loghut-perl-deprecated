package LogHut::Controller;

use latest;
use FindBin;
use lib "$FindBin::Bin";
use parent 'LogHut::Object';

sub new {
    my $class = shift;
    my %params = @_; undef @_;
    my $self = $class->SUPER::new(%params);
    $self->{models} = {};
    $self->{views} = {};
    return $self;
}

sub add_model {
    my $self = shift;
    my $model_name = shift;
    my $model = shift;
    $self->{models}->{$model_name} = $model;
    $self->{models}->{$model_name}->set_controller($self);
    return $self;
}

sub add_view {
    my $self = shift;
    my $view_name = shift;
    my $view = shift;
    $self->{views}->{$view_name} = $view;
    $self->{views}->{$view_name}->set_controller($self);
    return $self;
}

sub get_model {
    my $self = shift;
    my $model_name = shift;
    return $self->{models}->{$model_name};
}

sub get_view {
    my $self = shift;
    my $view_name = shift;
    return $self->{views}->{$view_name};
}

return 1;
