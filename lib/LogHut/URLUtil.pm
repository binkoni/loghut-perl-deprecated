package LogHut::URLUtil;
use feature ':all';
use LogHut::Log;

sub encode {
    my $url = shift;
    defined $url or confess 'No argument $url';
    $url =~ s/([^0-9A-z!_\.\-\(\)])/sprintf('%%%02X', ord $1)/eg;
    return $url;
}

sub decode
{
    my $url = shift;
    defined $url or confess 'No argument $url';
    $url =~ tr/+/ /;
    $url =~ s/%([0-9A-F]{2})/chr(hex $1)/eg;
    return $url;
}

return 1;
