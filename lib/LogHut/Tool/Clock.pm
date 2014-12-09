package LogHut::Tool::Clock;

use latest;
use FindBin;
use lib "$FindBin::Bin/../../";
use parent 'LogHut::Object';
use LogHut::Log;
use Time::Piece;

sub new {
    my $class = shift;
    my %params = @_; undef @_;
    my $self = $class->SUPER::new(%params);
    
    return $self;
}

sub get_time {
    my $self = shift;
    my $time = localtime();
    return (sprintf("%04d", $time->year), sprintf("%02d", $time->mon), sprintf("%02d", $time->mday));
}

return 1;
