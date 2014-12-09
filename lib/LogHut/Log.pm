package LogHut::Log;

use latest;
use parent 'Exporter';
use Carp ();

BEGIN {
    *CORE::GLOBAL::die = \&LogHut::Log::confess;
    *CORE::GLOBAL::warn = \&LogHut::Log::carp;
    $SIG{__WARN__} = \&LogHut::Log::carp;
    $SIG{__DIE__} = \&LogHut::Log::confess;
}

our @EXPORT = ('confess', 'carp');
our $enabled = 1;

sub die {
    CORE::die(@_);
}

sub confess {
    if($enabled) {
        open my $log, '>>', 'log';
        $log->print(Carp::longmess(@_));
        close $log;
        LogHut::Log::die();
    }
}

sub carp {
    if($enabled) {
        open my $log, '>>', 'log';
        $log->print(Carp::shortmess(@_));
        close $log;
    }
}

return 1;
