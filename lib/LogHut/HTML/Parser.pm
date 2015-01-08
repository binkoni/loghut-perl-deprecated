package LogHut::HTML::Parser;

use feature ':all';
use FindBin;
use lib "$FindBin::Bin/../../";
use parent 'LogHut::Object';
use LogHut::Data::TreeNode;
use LogHut::Log;
no warnings;

sub new {
    my $class = shift;
    my %params = @_; undef @_;
    my $self = $class->SUPER::new(%params);
    $self->{debug} = $params{debug};
    $self->{tree} = LogHut::Data::TreeNode->new();
    return $self;
}

sub get_tree {
    my $self = shift;
    return $self->{tree};
}

sub set_tree {
    my $self = shift;
    $self->{tree} = shift;
}

sub parse_file {
    my $self = shift;
    my $path = shift;
    my $root = $self->{tree};
    open my $file, '<:utf8', $path or confess "Failed to open file $path !";
    local $/;
    undef $/;
    $self->{lines} = readline $file;
    close $file;
    return $self->parse($root);
}

sub parse {
    my $self = shift;
    my $root = shift;
    my $root_name = $root->get_value('tag');
    my $root_id = $root->get_value('id');
    my $root_contents;
    my $child;
    my $child_result;
    my $attributes;
    my %attributes;

    while(1) {
        $self->{debug} and sleep 1;
        $self->{debug} and say $root_contents;
        if($self->{lines} =~ m/\G<\/(?<tag>[0-9A-z]+)>/cgi) {
            $self->{debug} and $self->debug("---->multiline closing tag ($+{tag})");
            if($root_name eq $+{tag}) {
                $root->set_value('contents', $root_contents);
                return $root;
            } else {
                return $root_contents;
            }
        }
        elsif($self->{lines} =~ m/\G<!/cgi) {
            $self->{debug} and $self->debug('!');
            $root_contents .= $&;
            if($self->{lines} =~ m/\G--/cgi) {
                $self->{debug} and $self->debug('comment');
                $root_contents .= $&;
                if($self->{lines} =~ m/\G(?<comment_contents>.*?)-->\s*/cgis) {
                    $self->{debug} and $self->debug("---->comment contents ($+{comment_contents}) and comment closed");
                    $root_contents .= $&;
                }
            } elsif($self->{lines} =~ m/\G(?<tag>doctype|entity)(\s+(?<attributes>[^>]*?))?>\s*/cgi) {
                $self->{debug} and $self->debug($+{tag});
                $self->{debug} and $self->debug("---->attributes ($+{attributes}) and ($+{tag}) closed");
                $root_contents .= $&;
            } 
        } elsif($self->{lines} =~ m/\G<(?<tag>[0-9A-z]+)(\s+(?<attributes>[^>]*?))?\/>\s*/cgi) {
            $self->{debug} and $self->debug("---->inline elemnt ($+{tag}), attributes ($+{attributes})");
            $root_contents .= $&;
            $child = LogHut::Data::TreeNode->new();
            $child->set_value('tag', $+{tag});
            $attributes = $+{attributes};
            while(1) {
                if($attributes =~ m/\G(?<attribute_name>\S+?)\s*=\s*(?<q>['"])(?<attribute_value>.+?)\k<q>\s*/cgis) {
                    $self->{debug} and $self->debug("---->attribute_name : ($+{attribute_name}) attribute_value : ($+{attribute_value})");
                    $child->set_value($+{attribute_name}, $+{attribute_value});
                } elsif($attributes =~ m/\G(?<attribute_name>\S+)\s*/cgi) {
                    $child->set_value($+{attribute_name}, undef);
                } else {
                    last;
                }
            }
        } elsif($self->{lines} =~ m/\G<(?<tag>style|script)(\s+(?<attributes>[^>]*?))?>(?<plain_contents>.*?)<\/\k<tag>>\s*/cgis) { 
            
            $self->{debug} and $self->debug("---->multiline tag ($+{tag}), attributes ($+{attributs}) plain contents $+{plain_contents} ");
            $root_contents .= $&;
            $child = LogHut::Data::TreeNode->new();
            $child->set_value('tag', $+{tag});
            $child->set_value('contents', $+{plain_contents});
            $attributes = $+{attributes};
            while(1) {
                if($attributes =~ m/\G(?<attribute_name>\S+?)\s*=\s*(?<q>['"])(?<attribute_value>.+?)\k<q>\s*/cgis) {
                    $self->{debug} and $self->debug("---->attribute_name : ($+{attribute_name}) attribute_value: ($+{attribute_value})");
                    $child->set_value($+{attribute_name}, $+{attribute_value});
                } elsif($attributes =~ m/\G(?<attribute_name>\S+)\s*/cgi) {
                    $child->set_value($+{attribute_name}, undef);
                } else {
                    last;
                }
            }
            $root->add_child($child);
            
        } elsif($self->{lines} =~ m/\G<(?<tag>[0-9A-z]+)(\s+(?<attributes>[^>]*?))?>\s*/cgi) {
            $self->{debug} and $self->debug("---->multiline opening tag ($+{tag}), attributes ($+{attributes})");
            $root_contents .= $&;
            $child = LogHut::Data::TreeNode->new();
            $child->set_value('tag', $+{tag});
            $attributes = $+{attributes};
            while(1) {
                if($attributes =~ m/\G(?<attribute_name>\S+?)\s*=\s*(?<q>['"])(?<attribute_value>.+?)\k<q>\s*/cgis) {
                    $self->{debug} and $self->debug("---->attribute_name : ($+{attribute_name}) attribute_value : ($+{attribute_value})");
                    $child->set_value($+{attribute_name}, $+{attribute_value});
                } elsif($attributes =~ m/\G(?<attribute_name>\S+)\s*/cgi) {
                    $child->set_value($+{attribute_name}, undef);
                } else {
                    last;
                }
            }
            $child_result =  $self->parse($child);
            $root->add_child($child);
            if(ref $child_result) {
                $root_contents .= $child->get_value('contents') . '</' . $child->get_value('tag') . '>';
            } else {
                $root_contents .= $child_result;
                $root->set_value('contents', $root_contents);
                return $root;
            }
        } elsif($self->{lines} =~ m/\G(?<plain_contents>[^<]+)/cgi) {
            $self->{debug} and $self->debug("---->plain contents ($+{plain_contents})");
            $root_contents .= $&;
        } else {
            $root->set_value('contents', $root_contents);
            return $root;
        }
    }
}

sub debug {
    my $self = shift;
    say shift, ' at: ', pos $self->{lines};
}

return 1;
