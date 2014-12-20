package LogHut::Tool::File;

use latest;
use FindBin;
use lib "$FindBin::Bin/../../";
use parent 'LogHut::Object';
use Template;
use LogHut::Log;

sub new {
    my $class = shift;
    my %params = @_;
    my $self = $class->SUPER::new(%params);
    $self->{gzip_enabled} = $params{gzip_enabled};
    return $self;
}

sub join_paths {
    my $self = shift;
    my $path1 = shift or confess 'No argument $path1';
    my $path2 = shift or confess 'No argument $path2';

    $path1 =~ s/\/$//;
    $path2 =~ /^\.\// and confess "Wrong argument \$path2($path2)";
    $path2 =~ s/^\///;
    return "$path1/$path2";
}

sub get_directories {
    my $self = shift;
    my %params = @_; undef @_;
    my $local_path = $params{local_path};
    my $filter = $params{filter};
    my @directories;
    opendir my $dh, $local_path or return ();
    while(my $file = readdir $dh) {
        if(-d $self->join_paths($local_path, $file) &&
        (!defined $filter || $filter->test($file)) &&
        $self->no_upwards($file)) {
             $params{join_enabled} and $file = $self->join_paths($local_path, $file);
             push @directories, $file;
        }
    }
    closedir $dh;
    return @directories;
}

sub get_files {
    my $self = shift;
    my %params = @_; undef @_;
    my $local_path = $params{local_path};
    my $filter = $params{filter};
    my @files;
    opendir my $dh, $local_path or return ();
    while(my $file = readdir $dh) {
        $params{join_enabled} and $file = $self->join_paths($local_path, $file);
        ! ($self->{gzip_enabled} && $file =~ /\.gz$/) &&
        (! defined $filter || $filter->test($file)) &&
        $self->no_upwards($file) and push @files, $file;
    }
    close $dh;
    return @files;
}

sub mkdir {
    my $self = shift;
    my $directories = shift or confess 'No argument $directories';
    $directories =~ s/^\.\///;
    my @directories = split '/', $directories;
    $directories =~ /^\// and $directories[0] = '/' . $directories[0];
    my $target = shift @directories;
    mkdir $target;
    for my $directory (@directories){
        $target = "$target/$directory";
        mkdir $target;
    }
}

sub link {
    my $from_path = shift;
    my $to_path = shift;
    link $from_path, $to_path;
}

sub symlink {
    my $from_path = shift;
    my $to_path = shift;
    symlink $from_path, $to_path;
}

sub unlink {
    my $self = shift;
    my $path = shift or confess 'No argument $path';
    unlink $path;
    $self->{gzip_enabled} and unlink "$path.gz";
}

sub rmdir {
    my $self = shift;
    my $directory = shift or confess 'No argument $directory';
    my $filter = shift;
    my @files;
    for my $file ($self->get_files(local_path => $directory, join_enabled => 1)) {
        if(!$self->no_upwards($file)) {
            next;
        }elsif(($self->{gzip_enabled} && $file =~ /\.gz$/) ||
        (defined $filter && !$filter->test($file))) {
            push @files, $file;
        }else {
            return undef;
        }
    }
    for my $file (@files){
        $self->unlink($file) or return undef;
    }
    rmdir $directory or return undef;
}

sub rename {
    my $self = shift;
    my $path = shift or confess 'No argument $path';
    my $new_path = shift or confess 'No argument $new_path';
    rename $path, $new_path;
    $self->{gzip_enabled} and rename "$path.gz", "$new_path.gz";

}

sub compress {
    my $self = shift;
    my $current_path = shift or confess 'No Argument $current_path';
    my $filter = shift;
    my @queue;
    push @queue, $current_path;
    while(@queue) {
        $current_path = shift @queue;
        if(-d $current_path){
            push @queue,
            map{$self->join_paths($current_path, $_)} $self->get_files(local_path => $current_path, filter => $filter);
        }
        elsif(-f $current_path) {
            open my $compressed_file, '>', "$current_path.gz" or confess $!;
            $current_path =~ s/ /\\ /g;
            $compressed_file->print(`gzip -c9 $current_path`);
        }
    }
}

sub process_template {
    my $self = shift;
    my $template_file = shift or confess 'No argument $template_file';
    my $params = shift or confess 'No argument $params';
    my $destination = shift or confess 'No argument $destination';
    $self->{template} or $self->{template} = Template->new({ABSOLUTE => 1, ENCODING => 'utf-8'});
    $self->{template}->process($template_file, $params, $destination) or confess $self->{template}->error();
    $self->{gzip_enabled} && ! ref $destination and $self->compress($destination);
    return 1;
}

sub copy {
    my $self = shift;
    my $from_path = shift or confess 'No argument $from_path';
    my $to_path = shift or confess 'No argument $to_path';
    system('cp', $from_path, $to_path);
    $self->{gzip_enabled} and system 'cp', "$from_path.gz", "$to_path.gz";
    return 1;
}

sub bfs {
    my $self = shift;
    my $current_path = shift or confess 'No Argument $current_path';
    my $filter = shift;
    my @queue;
    my @files;
    push @queue, $current_path;
    while(@queue) {
        $current_path = shift @queue;
        if(-d $current_path) {
            push @queue, $self->get_files(local_path => $current_path, join_enabled => 1);
        }
        elsif(-f $current_path) {
            !($self->{gzip_enabled} && $current_path =~ /\.gz$/) &&
            (!defined $filter || $filter->test($current_path)) &&
            $self->no_upwards($current_path) and push @files, $current_path;
        }
    }
    return @files;
}

sub no_upwards {
    my $self = shift;
    my $path = shift or confess 'No argument $path';
    return !(($path =~ /^\.$/) || ($path =~ /^\.\.$/) || ($path =~ /\/\.$/) || ($path =~ /\/\.\.$/));
}

return 1;

