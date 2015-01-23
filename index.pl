#!/usr/bin/perl
use feature ':all';
use FindBin;
use lib "$FindBin::Bin/lib/";
use LogHut::Config;
use LogHut::Controller::Panel;
use LogHut::Request;
use LogHut::Server;

my $app = sub {
     my $env = shift;
     $q = LogHut::Request->new(env => $env);
     return [
         LogHut::Controller::Panel->new()->run()
     ];
};

my $server = LogHut::Server->new(app => $app);
$server->run();

