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

package LogHut::ReferenceUtil;

use feature ':all';
use LogHut::Debug;

sub deep_copy {
    my $value = shift;
    my $type = ref $value;
    if($type eq 'SCALAR') {
        my $scalar = ${$value};
        return \$scalar;
    } elsif($type eq 'REF') {
        my $ref = LogHut::ReferenceUtil::deep_copy(${$value});
        return \$ref;
    } elsif($type eq 'ARRAY') {
        my @array;
        for my $element (@{$value}) {
            push @array, LogHut::ReferenceUtil::deep_copy($element);
        }
        return \@array;
    } elsif(! defined $type || $type eq 'CODE' || $type eq 'LVALUE' || $type eq 'FORMAT' || $type eq 'IO' || $type eq 'VSTRING' || $type eq 'Regexp') {
        return $value;
    } else {
        my $hash_ref = {};
        $type ne 'HASH' and bless $hash_ref, $type;
        for my $key (keys %{$value}) {
            $hash_ref->{$key} = LogHut::ReferenceUtil::deep_copy($value->{$key});
        }
        return $hash_ref;
    }
}

return 1;
