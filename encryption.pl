use feature ':all';
use Digest::SHA 'sha512_hex';
my $salt = rand;
$salt =~ tr/0.//d;
say sha512_hex $ARGV[0] . $salt;
say sha512_hex $ARGV[1] . $salt;
say $salt;
