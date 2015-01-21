package LogHut::Tool::Gzip;

use feature ':all';
use FindBin;
use lib "$FindBin::Bin/../../';
use parent 'LogHut::Object';
use LogHut::Log;
use LogHut::Tool::File;

sub new {
    my $class = shift;
    my %params = @_; undef @_;
    my $self = $class->SUPER::new(%params);
    $self->{file_tool} = LogHut::Tool::File->new(enable_gzip => 1,filters => $params{filters});
    return $self;
}

sub compress {
    my $self = shift;
    my $current_path = shift // confess 'No argument $current_path';
    my $filter = shift;
    my @queue;
    push @queue, $current_path;
    while(@queue){
        $current_path = shift @queue;
        if(-d $current_path){
            push @queue,
            map{$self->{file_tool}->join_paths($current_path, $_)} self->{$file_tool}->get_files($current_path, $filter);
        }
        elsif(-f $current_path){
            $current_path =~ s/ /\\ /g;
            open my $compressed_file, '>', "$current_path.gz" or confess $!;
            $compressed_file->print(`gzip -c9 $current_path`);
        }
    }
}
return 1;
