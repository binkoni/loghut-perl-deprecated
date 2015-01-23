#This file is part of LogHut.
#
#LogHut is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation, either version 3 of the License, or
#(at your option) any later version.
#
#LogHut is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#
#You should have received a copy of the GNU General Public License
#along with LogHut.  If not, see <http://www.gnu.org/licenses/>.

package LogHut::Config;

use feature ':all';
use parent 'Exporter';
use FindBin;
use lib "$FindBin::Bin/../";
use LogHut::Log;
use LogHut::Tool::File;

our @EXPORT = ('$URL_PATH', '$LOCAL_PATH', '$ADMIN_ID', '$ADMIN_PASSWORD', '$SESSION_TIME', '$POSTS_PER_PAGE', '$q', '$f', '$env');
our $URL_PATH;
our $LOCAL_PATH;
our $ADMIN_ID;
our $ADMIN_PASSWORD;
our $SESSION_TIME;
our $POSTS_PER_PAGE;

our $q;
our $f;

*URL_PATH = \"http://gonapps.io/blog";
*LOCAL_PATH = \'/mnt/web/blog';
*ADMIN_ID = \'admin';
*ADMIN_PASSWORD = \'gonny95';
*SESSION_TIME = \3600;
*POSTS_PER_PAGE = \10;

*f = \LogHut::Tool::File->new(gzip_enabled => 1);
$LogHut::Log::enabled = 0;

return 1;
