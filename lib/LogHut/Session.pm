package LogHut::Session;

use feature ':all';
use FindBin;
use lib "$FindBin::Bin";
use parent 'LogHut::Object';
use Digest::SHA 'sha512_hex';
use Storable;
use LogHut::Log;
use LogHut::Tool::File;

my $file_tool = LogHut::Tool::File->new();

sub new {
    my $class = shift;
    my %params = @_; undef @_;
    my $self = $class->SUPER::new(%params);
    $self->{directory_path} = $params{directory_path};
    $self->{data} = {};
    return $self;
}

sub create {
    my $self = shift;
    my %params = @_; undef @_;
    $self->{data}->{expiration_time} = $params{expiration_time}; # expire after seconds
    $self->{data}->{user_data} = $params{user_data};
    $self->{data}->{update_time} = time;
    $self->{id} = sha512_hex $self->{data}->{update_time};
    store $self->{data}, $file_tool->join_paths($self->{directory_path}, $self->{id}) or confess 'store() failed';
}

sub update_time {
    my $self = shift;
    $self->{id} or return undef;
    $self->{data}->{update_time} = time;
    return store $self->{data}, $file_tool->join_paths($self->{directory_path}, $self->{id});
}

sub read {
    my $self = shift;
    $self->{id} = shift;
    defined $self->{id} or confess 'No argument $id';
    $self->{data} = retrieve $file_tool->join_paths($self->{directory_path}, $self->{id});
    return $self;
}

sub delete {
    my $self = shift;
    $file_tool->unlink($file_tool->join_paths($self->{directory_path}, $self->{id}));
}

sub get_update_time {
    my $self = shift;
    return $self->{data}->{update_time};
}

sub get_expiration_time {
    my $self = shift;
    return $self->{data}->{expiration_time};
}

sub get_id {
    my $self = shift;
    return $self->{id};
}

sub get_user_data {
    my $self = shift;
    return %{$self->{data}->{user_data}};
}

sub set_user_data {
    my $self = shift;
    $self->{data}->{user_data} = shift;
}

sub is_expired {
    my $self = shift;
    return time - $self->{data}->{update_time} > $self->{data}->{expiration_time};
}

return 1;
