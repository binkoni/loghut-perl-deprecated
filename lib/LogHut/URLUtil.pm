package LogHut::URLUtil;
use feature ':all';

sub encode {
    my $url = shift;
    $url =~ s/([^0-9A-z!_\.\-\(\)])/sprintf('%%%02X', ord $1)/eg;
    return $url;
}

sub decode
{
    my $url = shift;
    $url =~ s/%([0-9A-F]{2})/chr(hex $1)/eg;
    return $url;
}

return 1;

