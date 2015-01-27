# This file is part of LogHut.
#
# LogHut is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# LogHut is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with LogHut.  If not, see <http://www.gnu.org/licenses/>.

package LogHut::Global;

use feature ':all';
use parent 'Exporter';
use FindBin;
use lib "$FindBin::Bin/../";
use LogHut::Debug;
use LogHut::FileUtil;

our $settings = {
    local_path => '/mnt/web/blog',
    url_path => 'http://gonapps.io/blog',
    posts_local_path =>'/mnt/web/blog/posts',
    posts_url_path => 'http://gonapps.io/blog/posts',
    tags_local_path =>'/mnt/web/blog/tags',
    tags_url_path => 'http://gonapps.io/blog/tags',
    admin_local_path =>'/mnt/web/blog/admin',
    admin_url_path => 'http://gonapps.io/blog/admin',
    admin_id => 'e9294f655bea6eec3ab210e65c021a6cd97da44639955ec46d64f2a35b9b5c59d5f7db25f86716a317d75b78c4908e4fb4294759a7db91044ca6ed0aa8a976d7',
    admin_password => 'ce3f228eaa3ecdd8200a892e8e790545565c33618c7f3a6d10369b7efd3eb54a82a96b02f3a2e493e5e409acfe09698d30b83f7b5ecb974475c307f9de6089e5',
    admin_salt => '74157975222822',
    session_local_path => '/mnt/web/blog/admin/session',
    session_time => 3600,
    session_ip_match => 1,
    visitors_local_path => '/mnt/web/blog/admin/visitors', 
    posts_per_page => 10,
};

$LogHut::Debug::enabled = 0;

return 1;
