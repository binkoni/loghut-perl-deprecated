package LogHut::Object;

use feature ':all';

sub new {
    my $class = shift;
    return bless {}, $class;
}

return 1;
