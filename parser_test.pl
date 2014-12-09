use latest;
use FindBin;
use lib "$FindBin::Bin/lib/";
use LogHut::HTML::Parser;
my $parser = LogHut::HTML::Parser->new(debug => 1);
my $root = $parser->parse_file('../index.html');
print $root->find_child('id', 'post_text')->get_value('contents');
