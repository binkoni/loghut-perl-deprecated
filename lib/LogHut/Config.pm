package LogHut::Config;

use latest;
use parent 'Exporter';
use FindBin;
use lib "$FindBin::Bin/../";
use LogHut::Log;
use LogHut::Tool::File;

our @EXPORT = ('$URL_PATH', '$LOCAL_PATH', '$ADMIN_ID', '$ADMIN_PASSWORD', '$SESSION_TIME', '$q', '$f', '$env');
our $URL_PATH;
our $LOCAL_PATH;
our $ADMIN_ID;
our $ADMIN_PASSWORD;
our $SESSION_TIME;
our $env;

our $q;
our $f;

*URL_PATH = \"http://gonapps.io/blog";
*LOCAL_PATH = \'/mnt/web/blog';
*ADMIN_ID = \'admin';
*ADMIN_PASSWORD = \'gonny95';
*SESSION_TIME = \'+1h';

*f = \LogHut::Tool::File->new(gzip_enabled => 1);
$LogHut::Log::enabled = undef;

return 1;
